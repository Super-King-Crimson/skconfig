local MiniSnippets = require("mini.snippets")

local DEFAULT_KEY = "disabled"
local languageFilters = {
  disabled = { " .json", " .lua", " /**/*.json", " /**/*.lua" },
  luau = { "", "lua" },

  -- this is valid, it will map out the paths one time and link them correctly
  cs = { "", "csharp" },
  csharp = { "", "cs" },
}

local global_snippets = vim.fn.stdpath("config") .. "/snippets/global.json"

-- where to find snippets
local searchDirs = { vim.fn.stdpath("config") .. "/snippets", }
local ignorePaths = { "disabled" }



local function getChildrenAbs(path, wildignore)
  if not wildignore then wildignore = false end

  -- convert to absolute path by prefixing a / if not already done
  if string.sub(path, 1, 1) ~= "/" then path = "/" .. path end

  -- return nil if path wasn't real
  if vim.fn.glob(path) == "" then return nil end

  -- adds tailing slash if not already there
  if string.sub(path, string.len(path) - 1, 1) ~= "/" then path = path .. "/" end

  local children = vim.fn.glob(path .. "*", wildignore, true)

  return children
end


local function isPathIgnored(path, ignores)
  for _, ignore in ipairs(ignores) do
    -- Escape special characters in the ignore string
    local pattern = string.gsub(ignore, "[%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%1")

    -- Check if it matches as a full path component
    if string.find("/" .. path .. "/", "/" .. pattern .. "/") ~= nil then return true end
  end

  return false
end

-- appends path str to the beginning, makes sure output is valid path (if given reasonable path)
local function gsubAndNormalize(str, sub)
  if string.sub(str, 1, 1) ~= "/" then str = "/" .. str end

  local safeSub = string.gsub(sub, "[%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%1")

  return (string.gsub(str, " ", safeSub))
end

-- fix the filters in a specific language so it replaces the space with the language name and so it catenates each rootDir behind it
local function normalizeFilter(langname, langfilters, rootdirs, doubleQuoteSubstitution)
  if langname == nil then error("Language name cannot be null") end

  ---@diagnostic disable-next-line
  -- "" is a shortcut for including the default configuration with your langname (i.e. langname.json, langname.lua...).
  if langfilters == nil then langfilters = { "" } end

  local normalized = {}

  ---@diagnostic disable-next-line
  for _, pat in ipairs(langfilters) do
    -- if we find a "", substitute it with default config
    if pat == "" then
      for _, defaultFilter in ipairs(doubleQuoteSubstitution) do
        for _, rootdir in ipairs(rootdirs) do
          table.insert(normalized, rootdir .. gsubAndNormalize(defaultFilter, langname))
        end
      end
    else
      for _, rootdir in ipairs(rootdirs) do
        table.insert(normalized, rootdir .. gsubAndNormalize(pat, langname))
      end
    end
  end

  return normalized
end

local function syncFiltersFromLoadedFilters(unloadedSettings, loadedFilters, rootdirOrRootdirs, doubleQuoteSubstitution)
  -- generate filters for languages you do have configuration options for, that at this point shouldn't have been loaded yet
  for langname, filters in pairs(unloadedSettings) do
    local strippedFilters = {}
    local syncedFilters = {}

    for _, v in ipairs(filters) do
      -- i know this is bad but im lowk so braindead rn so this is how its gonna be
      -- we generate from the files first to load configs that might not exist yet
      -- after that, we load filters that do exist to override any other options
      -- since we have already loaded the default settings (i.e. simply expansions of the paths that already exist)
      -- if we remove the elements in the table that have been added due to that we can get the extra configs
      -- and since this is true for all configs, we can go one level deeper and grab dependencies
      -- the whole reason we're doing this is so we don't get scuffed paths in each config
      if not loadedFilters[v] then
        -- if we didn't know about the value, then its a new path and we should load it in (even when its stripped, its included)
        table.insert(strippedFilters, v)
      else
        -- otherwise load the contents in to sync and NOT into stripped
        for _, otherFilter in ipairs(loadedFilters[v]) do
          table.insert(syncedFilters, otherFilter)
        end
      end
    end

    -- use the stripped filter to normalize everything that isn't to be synced
    local newFilterPaths = normalizeFilter(
      langname,
      strippedFilters,
      rootdirOrRootdirs,
      doubleQuoteSubstitution
    )

    -- then combine the two tables, which at this point has the correctly synced data
    for _, otherFilter in ipairs(newFilterPaths) do
      table.insert(syncedFilters, otherFilter)
    end

    loadedFilters[langname] = syncedFilters
  end

  -- modfifies the contents, but also returns them
  return loadedFilters
end

local function generateNormalizedFiltersFromConfig(languageFilters, searchDirectories, ignore)
  local normalizedFilters = {}

  -- generate default configuration options
  -- do this first so linking works as intended (generate defaults from language > sync based on that)
  for _, dir in ipairs(searchDirectories) do
    local alreadyAddedPaths = {}

    for _, child in ipairs(getChildrenAbs(dir)) do
      local langname = ""

      if isPathIgnored(child, ignore) then goto CONTINUE end

      if vim.fn.isdirectory(child) == 1 then
        langname = vim.fn.fnamemodify(child, ":t")
      else
        langname = vim.fn.fnamemodify(child, ":t:r")
      end

      local newNormalizedFilters = normalizeFilter(
        langname,
        languageFilters[langname],
        searchDirectories,
        languageFilters[DEFAULT_KEY]
      )

      if not normalizedFilters[langname] then normalizedFilters[langname] = {} end

      for _, f in ipairs(newNormalizedFilters) do
        if alreadyAddedPaths[f] then goto NEXTPATH end
        alreadyAddedPaths[f] = true
        table.insert(normalizedFilters[langname], f)
        ::NEXTPATH::
      end

      ::CONTINUE::
    end
  end

  -- this function will modify the filters, updating them to be normalized
  syncFiltersFromLoadedFilters(languageFilters, normalizedFilters, searchDirectories, languageFilters[DEFAULT_KEY])
  return normalizedFilters
end

local function loadSnippets(context)
  local res, snippetGlobs = pcall(function()
    return generateNormalizedFiltersFromConfig(languageFilters, searchDirs, ignorePaths)
  end)

  if not res then
    vim.notify("Failed to load snippets: " .. snippetGlobs, vim.log.levels.ERROR)
    return {}
  end

  local globs = snippetGlobs[context.lang] or {}
  local rawSnippets = {}

  ---@diagnostic disable-next-line: param-type-mismatch
  for _, glob in ipairs(globs) do
    local matches = vim.fn.glob(glob, false, true)

    for _, path in ipairs(matches) do
      ---@diagnostic disable-next-line: param-type-mismatch
      local rawSnippet = MiniSnippets.read_file(path)
      table.insert(rawSnippets, rawSnippet)
    end
  end

  return rawSnippets
end

require("mini.snippets").setup({
  snippets = {
    loadSnippets,
    MiniSnippets.gen_loader.from_file(global_snippets)
  },

  mappings = {
    expand = "",
    jump_next = "<C-n>",
    jump_prev = "<C-p>",
    stop = "<C-c>",
  }
})
