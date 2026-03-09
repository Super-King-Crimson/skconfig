-- don't forget this trailing slash
local M = {}

local SESSION_DIR = vim.fn.stdpath("data") .. "/autosessions/"

local defaultSessionName = "latest"
local currSession = nil

local LabTools = require("labtools")
local logMsg = LabTools.logMsg
local logDebug = LabTools.logDebug
local tableContains = LabTools.tableContains
local fuzzyFindPrompt = LabTools.fuzzyFindPrompt

local function getFullPathFromSessionName(name)
  return SESSION_DIR .. name .. ".vim"
end

local function getSessionNameFromFullPath(path)
  -- literally just the relative path
  local relPath = string.sub(path, string.len(SESSION_DIR) + 1)
  -- with the file extension removed
  return vim.fn.fnamemodify(relPath, ":r")
end

local function writeAutosession(name)
  if name == nil or name == "" or name == vim.NIL then
    error("provide a session name")
    return
  end

  local sessionPath = getFullPathFromSessionName(name)

  local parentDir = vim.fn.fnamemodify(sessionPath, ":h")
  local dirExists = vim.fn.isdirectory(parentDir) == 1

  if not dirExists then
    logDebug(parentDir .. " doesn't exist, initializing")
    vim.cmd("silent !mkdir -p " .. parentDir)
  end

  vim.cmd("silent mksession! " .. sessionPath)
  logDebug("Wrote session" .. sessionPath, vim.log.levels.INFO)

  return sessionPath
end

local function changeWriteAutoSession(name)
  if name == nil or name == "" or name == vim.NIL then
    vim.notify("provide a valid session name", vim.log.levels.ERROR)
  end

  if name == defaultSessionName and currSession == nil then
    -- unhook from any symlink and treat as a temporary standalone session
    vim.cmd("silent! !rm " .. getFullPathFromSessionName(defaultSessionName))
  end

  currSession = name
  writeAutosession(currSession)
end

local function getAutosessions()
  local sessions = vim.fn.glob(SESSION_DIR .. "**/*.vim", true, true)
  local sessionNames = {}

  for i, sessionPath in ipairs(sessions) do
    sessionNames[i] = getSessionNameFromFullPath(sessionPath)
  end

  return sessionNames
end

local function loadAutosession(sessionName)
  if sessionName == nil or sessionName == "" or sessionName == vim.NIL then
    error("session should not be nil")
  end

  local sessionIsValid = tableContains(getAutosessions(), sessionName)
  if not sessionIsValid then
    error(sessionName .. " is not a valid session name")
  end

  vim.cmd("silent! %bwipeout!")
  vim.cmd("silent! source " .. getFullPathFromSessionName(sessionName))

  currSession = sessionName

  logMsg(string.format("Successfully sourced %s.", sessionName), vim.log.levels.INFO)
end

local function loadAutosessionFromFuzzyFind()
  local sessionList = getAutosessions()

  fuzzyFindPrompt(sessionList, "Session Selection", function(item)
    loadAutosession(item)
  end)
end
vim.keymap.set("n", "<Leader>os", loadAutosessionFromFuzzyFind, { desc = "[O]pen [S]ession" })

local function writeAutosessionFn(args)
  local name = args and args.fargs[1] or nil
  local bang = args and args.bang or nil

  if name == nil or name == "" or name == vim.NIL then
    name = currSession or defaultSessionName
  end

  if bang then
    writeAutosession(name)
  else
    changeWriteAutoSession(name)
  end
end
vim.api.nvim_create_user_command("WriteAutosession", writeAutosessionFn, {
  nargs = "?",
  bang = true,
  desc = "Save an autosession and mark it as current (! to just write it)",
  force = true,
  complete = getAutosessions,
})

local function loadAutosessionFn(args)
  local name = args and args.fargs[1] or nil

  if name == "" or name == nil or name == vim.NIL then
    name = defaultSessionName
  end

  loadAutosession(name)
end





vim.api.nvim_create_user_command("LoadAutosession", loadAutosessionFn, {
  desc = "Load a session that will be written to upon filewrite",
  nargs = "?",
  force = true,
  complete = getAutosessions,
})
vim.keymap.set("n", "<Leader>ol", loadAutosessionFn, { desc = "[O]pen [L]atest session" })




M.whichAutosession = function()
  if currSession == nil then return nil end

  local thisAutosession = currSession

  local isPointer = false
  if thisAutosession == defaultSessionName then
    local path = getFullPathFromSessionName(defaultSessionName)

    local linkTarget = vim.uv.fs_readlink(path)
    if linkTarget ~= nil then
      -- we always set up our links to use full paths, so this should always work
      thisAutosession = getSessionNameFromFullPath(linkTarget)
      isPointer = true
    end
  end

  -- don't worry too much about this it formats output
  return string.format("%s%s", isPointer and defaultSessionName .. " > " or "", thisAutosession)
end

local function whichAutosessionFn()
  local currSession = M.whichAutosession()
  if currSession == nil then return end

  print("Session: " .. currSession)
end
vim.api.nvim_create_user_command("WhichAutosession", whichAutosessionFn, {
  force = true,
  desc = "Output the name of your current session",
})
vim.keymap.set("n", "<Leader>?s", whichAutosessionFn, { desc = "Which [S]ession?" })





local function changeWriteAutoSessionFromInput()
  vim.ui.input({ prompt = "Session name: " }, function(input)
    if input == nil or input == "" then return end

    changeWriteAutoSession(input)
  end)
end
vim.keymap.set("n", "<Leader>ws", changeWriteAutoSessionFromInput, { desc = "[W]rite [S]ession" })



local function editAutosessions()
  vim.cmd("edit " .. SESSION_DIR)
end
vim.api.nvim_create_user_command("EditAutosessions", editAutosessions, {
  desc = "Go to directory of autosessions for easy deletion, renaming, etc.",
})




local augroup = vim.api.nvim_create_augroup("skc-auto-write-session", { clear = true })
vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  group = augroup,
  callback = function()
    changeWriteAutoSession(currSession or defaultSessionName)
  end,
})

vim.api.nvim_create_autocmd({ "VimLeave" }, {
  group = augroup,
  callback = function()
    -- automatically makes symlink to last accessed session
    if currSession and currSession ~= defaultSessionName then
      vim.cmd("silent! !rm " .. getFullPathFromSessionName(defaultSessionName))

      vim.cmd(
        "silent! !ln -sf "
        .. getFullPathFromSessionName(currSession)
        .. " "
        .. getFullPathFromSessionName(defaultSessionName)
      )
    end
  end,
})

return M
