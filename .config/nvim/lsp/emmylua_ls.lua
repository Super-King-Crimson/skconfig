---@diagnostic disable: need-check-nil
---@diagnostic disable: undefined-global
---@diagnostic disable: unnecessary-if

-- NOTE: you can load your nvim emmyrc into another project by creating a .loademmy file in the the project root

local schema =
"https://raw.githubusercontent.com/EmmyLuaLs/emmylua-analyzer-rust/refs/heads/main/crates/emmylua_code_analysis/resources/schema.json"

-- toggle this if the messages get annoying
local silent_mode = true
local debug_mode = true

-- alternatively, just disable backups
local backup = true

local stdconfig = vim.fn.stdpath("config")
local emmyrc_tail = "/.emmyrc.json"
local emmylua_tail = "/.emmyrc.bak.lua"

-- individual plugins that contain a lua directory
local include = { vim.env.VIMRUNTIME }

-- make sure each individual plugin within these directories has its own lua directory or it won't be loaded
local package_paths = { vim.fn.stdpath("data") .. "/lazy", }

-- if this isn't working, you can also do this, i wouldn't really recommend it though
-- for _, path in ipairs(vim.api.nvim_get_runtime_file("", true)) do
--   table.insert(plugpaths, path)
--   table.insert(lib, path)
-- end

local library = include

for _, packpath in ipairs(package_paths) do
  for _, plug in ipairs(vim.fn.readdir(packpath)) do
    table.insert(library, packpath .. "/" .. plug)
  end
end

-- all settings can be found at https://github.com/EmmyLuaLs/emmylua-analyzer-rust/blob/main/docs/config/emmyrc_json_EN.md
local emmy_settings = {
  ['$schema'] = schema,
  workspace = {
    library = library,
    ignoreDir = {
      "after",
      "snippets",
      "lsp",
    },
  },

  runtime = {
    version = "LuaJIT",
    extensions = { ".lua" },
    requirePattern = {
      "lua/?.lua",
      "lua/?/init.lua",
    },
  },

  completion = {
    enable = true,
    callSnippet = false,
    autoRequireNamingConvention = falsefalse,
  },

  diagnostics = {
    disable = {
      "invert-if",
      "deprecated",
      "discard-returns",
      "inject-field",
      "missing-fields",
      "missing-global-doc",
      "need-check-nil",
      "param-type-not-match",
      "redefined-local",
      "unreachable-code",
    },

    severity = {
      ["access-invisible"] = "error",
      ["return-type-mismatch"] = "error",
      ["unused"] = "warning",
    },
  },
}


-- optional: tell emmylua about vim.uv
-- make a place to store external libraries (i chose stdpath("data")/after/lsp/3rd)
-- if it isn't in your nvim config, you'll have to tell emmyls where it is by adding it as a packpath
-- copy this file into that path: https://github.com/Bilal2453/luvit-meta/blob/8bf02dcd176479ef148849ffceb58b6e8a41b05d/library/uv.lua


-- LOGIC


local function vimnotify(msg, loglevel)
  if silent_mode then return end
  if loglevel == nil then loglevel = vim.log.levels.DEBUG end
  if not debug_mode and loglevel == vim.log.levels.DEBUG then return end
  vim.notify(msg, loglevel)
end

-- courtesy of gemini
-- you can replace this with your own json formatter, or just return json_str to output as one line
local function format_json(json_str)
  local indent = 0
  local result = ""
  local is_quoted = false
  local escaped = false
  local indent_size = "  " -- Use 2 spaces

  for i = 1, #json_str do
    local char = json_str:sub(i, i)

    -- Handle string escaping (don't flip is_quoted if the quote is escaped)
    if char == "\\" then
      escaped = not escaped
    elseif char == '"' and not escaped then
      is_quoted = not is_quoted
      escaped = false
    else
      escaped = false
    end

    if is_quoted then
      result = result .. char
    else
      if char == "{" or char == "[" then
        indent = indent + 1
        result = result .. char .. "\n" .. string.rep(indent_size, indent)
      elseif char == "}" or char == "]" then
        indent = indent - 1
        result = result .. "\n" .. string.rep(indent_size, indent) .. char
      elseif char == "," then
        result = result .. char .. "\n" .. string.rep(indent_size, indent)
      elseif char == ":" then
        result = result .. char .. " "
      else
        result = result .. char
      end
    end
  end
  return result
end

-- returns true if changes were made
local function overwrite_previous_config(dir)
  local emmyrc = dir .. emmyrc_tail

  -- if exists, will be saved
  if vim.fn.filereadable(emmyrc) == 1 then
    local file = io.open(emmyrc, "r")

    -- reads whole file (must use *a or only reads one line)
    local contents = file:read("*a") or ""
    file:close()

    local result, file_settings = pcall(vim.json.decode, contents, { luanil = { object = true, array = true } })

    -- file had invalid json
    if result == false then
      vimnotify("Couldn't create backup: " .. emmyrc .. " had bad json", vim.log.levels.WARN)
      goto AFTER_LUA_WRITE
    end

    if vim.deep_equal(file_settings, emmy_settings) then
      vimnotify("Config is up to date. Exiting.", vim.log.levels.DEBUG)
      return false
    end

    if not backup then
      vimnotify("Backup not requested, skipping to after backup")
      goto AFTER_BACKUP
    end

    -- make scope for writing lua backup so we can goto over it
    do
      -- write previous .emmyrc.json to a lua representation in case they want to save it to this file
      local stringified = "local emmysettings = " .. vim.inspect(file_settings)
      local luarep = io.open(dir .. emmylua_tail, "w+")
      luarep:write(stringified)
      luarep:close()
    end

    ::AFTER_LUA_WRITE::
    local bak = io.open(emmyrc .. ".bak", "w+")
    bak:write(contents)
    bak:close()
  end

  ::AFTER_BACKUP::
  local encode = vim.json.encode(emmy_settings)
  encode = format_json(encode)

  local file = io.open(emmyrc, "w+")
  file:write(encode)
  file:close()

  return true
end

-- modify client config before init
local function update_emmyrc(root)
  local backed_up = backup and vim.fn.filereadable(vim.fs.joinpath(root, emmyrc_tail)) == 1
  local success, updated = pcall(overwrite_previous_config, root)

  if success == true and updated == false then return end

  if success == true and updated == true then
    if backed_up then
      vimnotify("Successfully overwrote previous .emmyrc.json.", vim.log.levels.INFO)
      vimnotify(string.format("Previous settings at %s and %s.bak.", path .. emmylua_tail, path .. emmyrc_tail), vim.log.levels.INFO)
      vimnotify("Please copy them over to your lspconfig if you prefer them.", vim.log.levels.INFO)
    else
      vimnotify("Successfully created .emmyrc.json.", vim.log.levels.INFO)
    end
  else
    vim.notify("Attempted to create a new .emmyrc.json, but it failed.", vim.log.levels.ERROR)
    vim.notify("error: " .. updated, vim.log.levels.ERROR)
  end
end

local root_markers = {
  '.emmyrc.json',
  '.luarc.json',
  '.git',
}

---@type vim.lsp.Config
return {
  cmd = { 'emmylua_ls' },

  root_dir = function(bufnr, on_dir)
    local root = vim.fs.root(bufnr, root_markers)
    -- stall stdconfig, we have to load our emmyrc
    -- allow automatic loading of emmyrc with .loademmy in same directory as .emmyrc.json
    if root ~= nil and root ~= stdconfig and not vim.uv.fs_stat(vim.fs.joinpath(root, ".loademmy")) then
      return on_dir(root)
    end

    local bufname = vim.api.nvim_buf_get_name(bufnr)
    if string.find(bufname, stdconfig) then
      root = stdconfig
    else
    -- if current buffer is not a child of stdconfig, then give up and just activate with no .emmyrc.json
      return on_dir(vim.fn.getcwd())
    end

    -- otherwise, update emmyrc before we start
    update_emmyrc(root)
    on_dir(root)
  end,

  filetypes = { 'lua' },
}
