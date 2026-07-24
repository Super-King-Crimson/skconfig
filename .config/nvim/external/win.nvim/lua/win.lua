---@diagnostic disable: assign-type-mismatch
---@diagnostic disable: param-type-mismatch

--#region
local bgHl = vim.api.nvim_get_hl(0, { name = "NormalFloat", link = false })
bgHl.bg = "none"
bgHl.fg = "none"
vim.api.nvim_set_hl(0, "SKCNormalFloat", bgHl)

local borderHl = vim.api.nvim_get_hl(0, { name = "FloatBorder", link = false })
borderHl.fg = "#ffffff"
borderHl.bold = true
vim.api.nvim_set_hl(0, "SKCFloatBorder", borderHl)

local titleHl = vim.api.nvim_get_hl(0, { name = "FloatTitle", link = false })
titleHl.fg = "#ffffff"
titleHl.bg = "none"
titleHl.bold = true
vim.api.nvim_set_hl(0, "SKCFloatTitle", titleHl)
--#endregion

local LabTools = require("labtools")
local logMsg = LabTools.logMsg
local arrFind = LabTools.arrFind

local M = {}

M.wins = {}
M.docked = {}
M.float = nil
M.defaultName = "Scratch"
M._accessList = {}
M._accessListIndex = 0

-- each window must have all these options
-- so that switches can happen seamlessly
M.defaultOptions = {
  -- dock opts
  enterDock = false,
  dockHeight = 0.2,
  dockWidth = 0.2,
  -- makes a top-level split
  relWin = -1,
  split = "below",

  -- floating opts
  floating = true,
  enterFloat = true,

  width = 0.8,
  height = 0.8,
  relative = "editor",
  winstyle = "minimal",
  border = "rounded",
  title_pos = "center",
  winblend = 20,

  createBuf = function()
    return vim.api.nvim_create_buf(false, true)
  end,

  wo = {
    winfixbuf = true,
    winhighlight = "NormalFloat:SKCNormalFloat,FloatBorder:SKCFloatBorder,FloatTitle:SKCFloatTitle",
  },

  keys = {
    ["<C-x><C-s>"] = { mode = { "", "!", "t", }, rhs = function() M.switchWindowType() end, },
    ["<C-x><C-q>"] = { mode = { "", "!", "t", }, rhs = function() M.deleteWindow(M.getNameFromWinid(vim.api.nvim_get_current_win())) end, },
    ["<C-x><C-r>"] = { mode = { "", "!", "t", }, rhs = function() M.renameWindowFromInput() end },
    ["<C-Left>"]   = { mode = { "", "!", "t", }, rhs = function() M.switchToPrevFloat() end, },
    ["<C-Right>"]  = { mode = { "", "!", "t", }, rhs = function() M.switchToNextFloat() end, },
    ["<C-q>"]      = { mode = "t", rhs = function() M.toggleWindow() end, },
  },
}

local function validateName(name)
  if name == nil then error("Please provide a name") end
  if string.find(name, "^[^a-zA-z]") then error("Name must start with a letter of the alphabet") end

  return name
end

-- creates default win opts
local function newWinOpts(name, opts)
  name = validateName(name)

  if not opts then opts = {} end

  local self = vim.tbl_deep_extend("force", M.defaultOptions, opts)

  self.name = name
  self._bufnr = opts._bufnr or -1
  self._winid = -1

  return self
end

local function isWinActive(name)
  if not name or not M.wins[name] then return false end

  return vim.api.nvim_win_is_valid(M.wins[name]._winid)
end

-- returns winname of window if we know about it, if not returns nil
function M.getNameFromWinid(winid)
  if not winid then return nil end

  for winname, _ in pairs(M.wins) do
    if M.wins[winname]._winid == winid then return winname end
  end

  if M.float ~= nil then
    if winid == M.wins[M.float]._winid then
      return M.float
    end
  end

  return nil
end

-- So user can loop through their previously used windows
local function addToAccessList(winName)
  table.insert(M._accessList, winName)
  return #M._accessList
end

local function removeFromAccessList(winname)
  for i, win in ipairs(M._accessList) do
    if winname == win then
      table.remove(M._accessList, i)
      goto END
    end
  end

  error("Couldn't find window " .. winname .. " in window list")

  ::END::
  if M._accessListIndex > #M._accessList then
    M._accessListIndex = #M._accessList > 0 and 1 or 0
  end
end

-- can be called safely: does not do anything if window is already closed
function M.closeWindow(name)
  if name == nil or M.wins[name] == nil then return end

  if isWinActive(name) then
    vim.api.nvim_win_hide(M.wins[name]._winid)
  end

  -- this isn't really necessary but im making it clear to myself the window (not the buffer) truly is gone atp
  M.wins[name]._winid = -1

  if name == M.float then M.float = nil end
  M.docked[name] = nil
end

function M.closeAllWindows()
  for name, _ in pairs(M.wins) do
    M.closeWindow(name)
  end
end

local function setupKeys(winopts, bufnr)
  for key, details in pairs(winopts.keys) do
    if details.disabled then goto CONTINUE end
    local mode = details.mode
    local opts = { buffer = bufnr }
    vim.tbl_deep_extend("keep", opts, details.opts or {})

    vim.keymap.set(mode, key, details.rhs, opts)

    ::CONTINUE::
  end
end

local function setupwo(winopts)
  for wo, val in pairs(winopts.wo) do
    -- if its not possible then just don't do it
    pcall(function() vim.wo[winopts._winid][wo] = val end)
  end
end

-- accepts a window with an attached buffer, and creates a floating window for it
local function attachFloatWindow(winopts)
  local lines = math.floor(vim.o.lines * winopts.height)
  local cols = math.floor(vim.o.columns * winopts.width)

  -- Calculate the position to center the window
  local line = math.floor((vim.o.lines - lines) / 2)
  local col = math.floor((vim.o.columns - cols) / 2)

  -- Define window configuration
  local win_config = {
    relative = "editor",
    height = lines,
    width = cols,
    row = line,
    col = col,
    style = "minimal",
    border = winopts.border or "rounded",
    title = "[ " .. winopts.name .. " ]",
    title_pos = "center",
  }

  -- hide any existing windows associated with this one
  if vim.api.nvim_win_is_valid(winopts._winid) then vim.api.nvim_win_hide(winopts._winid) end
  winopts._winid = vim.api.nvim_open_win(winopts._bufnr, winopts.enterFloat, win_config)

  setupwo(winopts)
  setupKeys(winopts, winopts._bufnr)
end

-- like attachFloatWindow, but for dock
local function attachDockWindow(winopts)
  local win_config = {
    win = winopts.relWin,
    split = winopts.split,
    height = math.floor(vim.o.lines * winopts.dockHeight),
    width = math.floor(vim.o.columns * winopts.dockWidth),
  }

  -- undesirable to have multiple of same win open
  if vim.api.nvim_win_is_valid(winopts._winid) then vim.api.nvim_win_hide(winopts._winid) end
  winopts._winid = vim.api.nvim_open_win(winopts._bufnr, winopts.enterDock, win_config)

  setupKeys(winopts, winopts._bufnr)
  setupwo(winopts)
end

-- pure convenience function
-- returns a number if the window was new (which is its index to save computation time)
local function __updateWindow(name, winopts)
  local newWinIndex = nil

  -- if this is a new window, we automatically know the window index is at the end
  if not M.wins[name] then
    newWinIndex = addToAccessList(name)
  end

  -- allow user to pass in configs to change their windows
  M.wins[name] = newWinOpts(name, winopts)
  return newWinIndex
end

function M.toggleFloatWindow(name, winopts)
  if not name then error("Expected name, got nil") return end

  if isWinActive(name) then
    logMsg("closing " .. name)

    local prevFloat = M.float
    M.closeWindow(name)

    if name == prevFloat and not winopts then return end
  end

  if isWinActive(M.float) then
    logMsg("closing previous float " .. M.float)
    M.closeWindow(M.float)
  end

  local newWinIndex = nil
  if not M.wins[name] or winopts ~= nil then
    -- defines M.wins[name]
    newWinIndex = __updateWindow(name, winopts)
  end

  if not M.wins[name]._bufnr or not vim.api.nvim_buf_is_valid(M.wins[name]._bufnr) then
    M.wins[name]._bufnr = M.wins[name].createBuf()
  end

  M.float = name
  attachFloatWindow(M.wins[name])

  if not newWinIndex then
    newWinIndex = arrFind(M._accessList, name)
  end

  if newWinIndex == nil then error("new_win_index should have been added to accessList") end

  M._accessListIndex = newWinIndex
  logMsg("successfully switched to float " .. M.float)
end

-- similar to toggleFloatWindow but instead creates a docked window
-- if passed a winname that is floating, will transform it into a docked window using its direction property
function M.toggleDockWindow(name, winopts)
  if name == nil then error("Expected name, got nil") end

  if isWinActive(name) then
    M.closeWindow(name)

    -- if no additional configuration added, then we're done here (user just wanted to close window)
    if not winopts then return end
  end

  local newWinIndex = nil
  if not M.wins[name] or winopts ~= nil then
    newWinIndex = __updateWindow(name, winopts)
  end

  if not vim.api.nvim_buf_is_valid(M.wins[name]._bufnr) then
    M.wins[name]._bufnr = M.wins[name].createBuf()
  end

  -- insert into list of docked windows so other functions get proper info
  M.docked[name] = true
  attachDockWindow(M.wins[name])

  if not newWinIndex then
    newWinIndex = arrFind(M._accessList, name)
    if newWinIndex == nil then error("new_win_index should have been added to M._accessList") end
  end

  M._accessListIndex = newWinIndex
  M.docked[name] = true
  logMsg("successfully switched to dock " .. name)
end

function M.getWindowAt(index)
  if index == nil or index == 0 then index = M._accessListIndex end

  if index < 1 or index > #M._accessList then
    error("No window at index " .. index)
  end

  return M.wins[M._accessList[index]]
end

function M.deleteWindow(name)
  if name == nil then error("Expected name, got nil") end
  if M.wins[name] == nil then error(name .. " is not a valid window; failed to delete") end

  M.closeWindow(name)
  removeFromAccessList(name)
  M.wins[name] = nil
  M.docked[name] = nil

  if M.float == name then M.float = nil end
end

function M.toggleWindow(name, winopts)
  -- make new default window if none exist
  if name == nil or name == "" then
    if #M._accessList == 0 then
      name = M.defaultName
    else
      name = M.getWindowAt().name
    end
  end

  local isFloat

  if winopts and winopts.floating ~= nil then
    isFloat = winopts.floating
  elseif M.wins[name] and M.wins[name].floating ~= nil then
    isFloat = M.wins[name].floating
  else
    isFloat = M.defaultOptions.floating
  end

  if isFloat then M.toggleFloatWindow(name, winopts) else M.toggleDockWindow(name, winopts) end
end

function M.renameWindow(prevName, nextName)
  nextName = validateName(nextName)

  for name, _ in pairs(M.wins) do
    if name == nextName and name ~= prevName then
      vim.notify("Window " .. nextName .. " already exists!", vim.log.levels.ERROR)
      return
    end
  end

  local details = M.wins[prevName]
  details.name = nextName

  local activate = isWinActive(prevName)

  M.deleteWindow(prevName)
  M.toggleWindow(nextName, details)

  if not activate then
    M.toggleWindow(nextName)
  end
end

function M.renameWindowFromInput()
  local winid = vim.api.nvim_get_current_win()
  local win = M.getNameFromWinid(winid)

  if not win then
    vim.notify("You're not in a win!", vim.log.levels.WARN)
    return
  end

  vim.ui.input({ prompt = "New name: "}, function(input)
    if input == nil or input == "" then return end

    M.renameWindow(win, input)
  end)
end

function M.switchToPrevFloat()
  if M.float == nil then return end

  local currIndex = M._accessListIndex
  if currIndex < 1 or currIndex > #M._accessList then return end

  -- i don't want to crash my computer.
  for i = currIndex - 2, -1, currIndex - 64 do
    local mod = (i % #M._accessList) + 1

    if mod == currIndex then return end

    local win = M.getWindowAt(mod)
    if win.floating then
      M.toggleWindow(win.name)
      return
    end
  end
end

function M.switchToNextFloat()
  if M.float == nil then return end

  local currIndex = M._accessListIndex
  if currIndex < 1 or currIndex > #M._accessList then return end

  -- i don't want to crash my computer.
  for i = currIndex, currIndex + 64 do
    local mod = (i % #M._accessList) + 1

    if mod == currIndex then return end

    local win = M.getWindowAt(mod)
    if win.floating then
      M.toggleWindow(win.name)
      return
    end
  end
end

function M.switchWindowType()
  local name = M.getNameFromWinid(vim.api.nvim_get_current_win())

  if name == nil then
    vim.notify("you are not in a win!", vim.log.levels.WARN)
    return
  end

  M.wins[name].floating = not M.wins[name].floating
  if M.float == name then M.float = nil end

  M.toggleWindow(name, M.wins[name])
end

function M.generateUniqueWinName(name)
  if not name then name = M.defaultName end

  local i = 1
  local newName = name

  while M.wins[newName] ~= nil do
    newName = string.format("%s (%d)", name, i)
    i = i + 1
  end

  return newName
end

function M.toggleAllDocks()
  local docks = {}
  local toggle = next(M.docked) == nil and true or false

  for name, info in pairs(M.wins) do
    if info.floating == false then
      if info.__true then
        table.insert(docks, 1, name)
      else
        table.insert(docks, name)
      end

      M.closeWindow(name)
    end
  end

  if not toggle then return end

  for _, name in ipairs(docks) do
    M.toggleWindow(name)
  end
end

local augroup = vim.api.nvim_create_augroup("SKC_WindowLifecycle", { clear = true })
vim.api.nvim_create_autocmd("WinLeave", {
  group = augroup,
  desc = "Close floating windows on exit",
  callback = function()
    if M.float ~= nil and M.getNameFromWinid(vim.api.nvim_get_current_win()) == M.float then
      M.closeWindow(M.float)
    end
  end
})

vim.api.nvim_create_autocmd("BufEnter", {
  group = augroup,
  desc = "Change the internal buffer of any win that switches buffers",
  callback = function()
    local name = M.getNameFromWinid(vim.api.nvim_get_current_win())
    if name == nil then return end

    M.wins[name]._bufnr = vim.api.nvim_get_current_buf()
  end
})

vim.api.nvim_create_autocmd("VimResized", {
  group = augroup,
  desc = "Resize windows to always maintain their ratio",
  callback = function()
    for _, winopts in pairs(M.wins) do
      if winopts.floating then
        local lines = math.floor(vim.o.lines * winopts.height)
        local cols = math.floor(vim.o.columns * winopts.width)
        local line = math.floor((vim.o.lines - lines) / 2)
        local col = math.floor((vim.o.columns - cols) / 2)
        vim.api.nvim_win_set_config(winopts._winid, {
          relative = "editor",
          height = lines,
          width = cols,
          row = line,
          col = col,
        })
      else
        vim.api.nvim_win_set_width(winopts._winid, math.floor(winopts.dockWidth * vim.o.columns))
        vim.api.nvim_win_set_height(winopts._winid, math.floor(winopts.dockHeight * vim.o.lines))
      end
    end
  end
})

local __prevcols = vim.o.columns
local __prevlines = vim.o.lines
vim.api.nvim_create_autocmd("WinResized", {
  group = augroup,
  desc = "Internally keep track of the state of docked windows",

  callback = function()
    for _, winid in ipairs(vim.v.event.windows) do
      local name = M.getNameFromWinid(winid)

      if name and not M.wins[name].floating then
        if vim.o.columns ~= __prevcols or vim.o.lines ~= __prevlines then
          logMsg("ah ha! resize.")
          __prevcols = vim.o.columns
          __prevlines = vim.o.lines
          return
        end

        M.wins[name].dockWidth = vim.api.nvim_win_get_width(winid) / vim.o.columns
        M.wins[name].dockHeight = vim.api.nvim_win_get_height(winid) / vim.o.lines

        -- essentially guessing lmao
        local pos = vim.api.nvim_win_get_position(winid) -- line, col
        local topmost = pos[1] == 0
        local leftmost = pos[2] == 0
        local deep = pos[1] + vim.api.nvim_win_get_height(winid) > (0.9 * vim.o.lines)
        local far = pos[2] + vim.api.nvim_win_get_width(winid) > (0.9 * vim.o.columns)

        if topmost and leftmost then
          if far then
            M.wins[name].split = "above"
          else
            M.wins[name].split = "left"
          end
          M.wins[name].__true = true
        elseif leftmost then
          M.wins[name].split = "below"
          M.wins[name].__true = true
        elseif deep and far then
          M.wins[name].split = "right"
          M.wins[name].__true = true
        else
          M.wins[name].__true = nil
        end

        logMsg("you are a " .. M.wins[name].split .. " dock")
      end
    end
  end
})

-- 'sync' windows between tabpages
vim.api.nvim_create_autocmd({ "WinClosed", "TabEnter" }, {
  group = augroup,
  desc = "Refresh window state for windows",
  callback = function()
    for winname, win in pairs(M.wins) do
      if not vim.api.nvim_win_is_valid(win._winid) then
        M.closeWindow(winname)
        goto CONTINUE
      end

      local tab = vim.api.nvim_get_current_tabpage()
      local wintab = vim.api.nvim_win_get_tabpage(win._winid)

      if tab ~= wintab then
        M.closeWindow(winname)
      end

      ::CONTINUE::
    end
  end
})

return M
