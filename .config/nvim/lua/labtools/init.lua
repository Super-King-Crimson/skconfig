-- VIM.FS.NORMALIZE()
-- VIM.FS.FIND()
local LabTools = {}

local silent = false
local debugMode = false

function LabTools.arrFind(haystack, needle)
  for i, hay in ipairs(haystack) do
    if hay == needle then return i end
  end

  return nil
end

-- obeys wildignore and returns list
function LabTools.getChildrenAbs(path, wildignore)
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

function LabTools.logMsg(msg, logLevel)
  if silent then
    return
  end

  vim.notify(msg, logLevel or vim.log.levels.INFO)
end

function LabTools.logDebug(debugMsg, logLevel)
  if debugMode then
    LabTools.logMsg("DEBUG: " .. debugMsg, logLevel)
  end
end

function LabTools.isPathIgnored(path, ignoreOrIgnores)
  local ignores = ignoreOrIgnores

  if type(ignoreOrIgnores) == "string" then
    ignores = { ignoreOrIgnores }
  elseif type(ignoreOrIgnores) ~= "table" then
    error("Expected string for paths to ignore, got " .. type(ignoreOrIgnores))
  end

  for _, ignore in ipairs(ignores) do
    -- Escape special characters in the ignore string
    local pattern = string.gsub(ignore, "[%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%1")

    -- Check if it matches as a full path component
    if string.find("/" .. path .. "/", "/" .. pattern .. "/") ~= nil then return true end
  end

  return false
end

-- checks nil, "", and {}
function LabTools.isEmpty(value)
  if type(value) == "table" then
    return next(value) == nil
  end

  return value == nil or value == ""
end

function LabTools.matches(str, ...)
  if LabTools.isEmpty(str) then return false end

  local pats = { ... }
  for _, pat in ipairs(pats) do
    if string.find(str, pat) then return false end
  end

  return true
end

function LabTools.trim(s)
  return string.match(s, "^%s*(.-)%s*$")
end

function LabTools.tableContains(tab, val)
  for _, value in ipairs(tab) do
    if value == val then
      return true
    end
  end

  return false
end

local pickers
local finders
local conf
local actions

local action_state
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyLoad",
  callback = function(event)
    if event.data == "telescope.nvim" then
      pickers = require("telescope.pickers")
      finders = require("telescope.finders")
      conf = require("telescope.config").values
      actions = require("telescope.actions")
      action_state = require("telescope.actions.state")
    end
  end,
})

function LabTools.fuzzyFindPrompt(items, wintitle, callback)
  if #items == 0 then
    LabTools.logMsg("No elements found.", vim.log.levels.ERROR)
    return false
  end

  if not pickers then
    vim.notify("You must have telescope installed to fuzzy find.", vim.log.levels.ERROR)
    return false
  end

  LabTools.logDebug("options: " .. table.concat(items, " | "), vim.log.levels.INFO)

  local opts = {
    prompt_title = wintitle,
    finder = finders.new_table({
      results = items,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, _)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()

        if selection then
          callback(items[selection.index])
        end
      end)

      return true
    end,
  }

  pickers.new({}, opts):find()
  return true
end

return LabTools
