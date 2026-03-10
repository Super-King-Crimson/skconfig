-- NOTE: you can load your nvim emmyrc into another project by creating a .loademmy file in the the project root
local schema = "https://raw.githubusercontent.com/EmmyLuaLs/emmylua-analyzer-rust/refs/heads/main/crates/emmylua_code_analysis/resources/schema.json"

-- toggle this if the messages get annoying
local silent_mode = false
local debug_mode = false

-- alternatively, just disable backups
local backup = true
-- and to manually change it in the .emmyrc.json, set this to false
local auto_update = true

local stdconfig = vim.fn.stdpath("config") --[[@as string]]
local emmyrc_tail = ".emmyrc.json"
local emmylua_tail = ".emmyrc.bak.lua"

-- load all directories across the runtime files
local include = {}

-- but not our config directory
local stdconfig_len = string.len(stdconfig)
local dirs = vim.api.nvim_get_runtime_file("", true)
table.sort(dirs)

for _, dir in ipairs(dirs) do
  if not string.find(string.sub(dir, 1, stdconfig_len), stdconfig, 1, true) then
    table.insert(include, dir)
  end
end

-- optional: tell emmylua about vim.uv
-- make a place to store external libraries (i chose stdpath("config")/lsp/3rd)
-- if it isn't in your nvim config, you'll have to tell emmyls where it is by adding it as a packpath
-- copy this file into that path: https://github.com/Bilal2453/luvit-meta/blob/8bf02dcd176479ef148849ffceb58b6e8a41b05d/library/uv.lua
table.insert(include, vim.fs.joinpath(stdconfig, "lsp/3rd"))


-- all settings can be found at https://github.com/EmmyLuaLs/emmylua-analyzer-rust/blob/main/docs/config/emmyrc_json_EN.md
local emmy_settings = {
  ['$schema'] = schema,
  workspace = {
    library = include,
    ignoreDir = {
      -- put all lspconfigs you're not using here!
      "./lsp/unused",
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
    callSnippet = true,
    -- suggests a lot of garbage, wouldn't recommend
    autoRequire = false,
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
local function overwrite_previous_config(dir, config)
  -- 0: successful file overwrite, 1: file overwrite skipped, 2: file overwrite failed
  local exit_code = 0

  local emmyrc = vim.fs.joinpath(dir, emmyrc_tail)

  -- if exists, will be saved
  if vim.fn.filereadable(emmyrc) == 1 then
    local file = io.open(emmyrc, "r")

    -- reads whole file (must use *a or only reads one line)
    local contents = file:read("*a")
    file:close()

    local result, file_settings = pcall(function()
      return vim.json.decode(contents, { luanil = { object = true, array = true } })
    end)

    -- file had invalid json
    if result == false and backup == true then
      vimnotify("Couldn't create lua backup: " .. emmyrc .. " had bad json", vim.log.levels.WARN)
      exit_code = 2
      goto AFTER_LUA_WRITE
    end

    if vim.deep_equal(file_settings, config) then
      vimnotify("Config is up to date. Exiting.", vim.log.levels.DEBUG)
      return 1
    end

    if backup == false then
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
  local encode = vim.json.encode(config)
  encode = format_json(encode)

  local file = io.open(emmyrc, "w+")
  file:write(encode)
  file:close()

  return exit_code
end

-- modify client config before init
local function update_emmyrc(root)
  if not auto_update then return end

  local config = vim.deepcopy(emmy_settings)

  -- 0: successful file overwrite, 1: file overwrite skipped, 2: file overwrite failed
  local success, exit_code = pcall(function() return overwrite_previous_config(root, config) end)

  if success == false then
    vim.notify("Attempted to create a new .emmyrc.json, but it failed.", vim.log.levels.ERROR)
    vim.notify("error: " .. exit_code, vim.log.levels.ERROR)
    return
  end

  if exit_code == 0 and backup == true then
    vimnotify("Successfully overwrote previous .emmyrc.json.", vim.log.levels.INFO)
    vimnotify(string.format("Previous settings at %s and %s.bak.", vim.fs.joinpath(root, emmylua_tail), vim.fs.joinpath(root, emmyrc_tail)), vim.log.levels.INFO)
  elseif exit_code == 2 then
    vimnotify("Successfully updated .emmyrc.json, but unable to create backup files.", vim.log.levels.WARN)
    vimnotify("To ignore this message permanently, please explicitly disable backups.", vim.log.levels.WARN)
  elseif exit_code ~= 1 then
    vimnotify("Successfully updated .emmyrc.json.", vim.log.levels.INFO)
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
  filetypes = { 'lua' },

  root_dir = function(bufnr, on_dir)
    local root = vim.fs.root(bufnr, root_markers)

    -- stall stdconfig, we have to load our emmyrc
    -- allow automatic loading of emmyrc with .loademmy in same directory as .emmyrc.json
    if root ~= nil and root ~= stdconfig and not vim.uv.fs_stat(vim.fs.joinpath(root, ".loademmy")) then
      on_dir(root) 
      return root
    end

    local bufname = vim.api.nvim_buf_get_name(bufnr)
    if string.find(string.sub(bufname, 1, string.len(stdconfig)), stdconfig, 1, true) then
      root = stdconfig
    else
      -- if current buffer is not a child of stdconfig, then give up and just activate with no .emmyrc.json
      on_dir(vim.fn.getcwd())
      return vim.fn.getcwd()
    end

    -- otherwise, update emmyrc before we start
    update_emmyrc(root)
    on_dir(root)
    return root
  end,
}
