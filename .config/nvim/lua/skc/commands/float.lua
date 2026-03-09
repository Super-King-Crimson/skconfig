local LabTools = require("labtools")

local fuzzyFindPrompt = LabTools.fuzzyFindPrompt
local logMsg = LabTools.logMsg
local trim = LabTools.trim
local arrFind = LabTools.arrFind

local SCRATCH_WIN_NAME = "[Scratch]"

local enum = {
  float = "float",
  docktop = "docktop",
  dockbottom = "dockbottom",
  dockleft = "dockleft",
  dockright = "dockright",
}

local map = {
  docktop    = "above",
  dockbottom = "below",
  dockleft   = "left",
  dockright  = "right"
}

local ALL_WINDOWS = {}

local DOCKED = {}

local ACCESS_LIST = {}
local CURRENT_WINDOW_INDEX = 0

local WINDOW_FLOATING = false
local CURRENT_FLOATING_WINDOW = ""

-- each window must have all these options
-- so that switches can happen seamlessly
local DEFAULT_OPTS = {
  width = 0.8,
  height = 0.8,
  size = 0.2,
  -- this is a weird one tho
  -- i guess if style == enum.float then its a float?
  style = enum.float,
  direction = enum.dockbottom,
}

-- creates default win opts
local function newWinOpts(opts)
  if not opts then opts = {} end

  local self = {
    height = opts.height or DEFAULT_OPTS.height,
    width = opts.width or DEFAULT_OPTS.width,
    size = opts.size or DEFAULT_OPTS.size,

    bufnr = opts.bufnr or -1,
    _winid = -1,

    style = opts.style or DEFAULT_OPTS.style,
    direction = opts.direction or DEFAULT_OPTS.direction,

    -- magnitude is used, greatest positive magnitude will get window focus (if all negative, no winfocus change)
    -- lower number means it will be split earlier than docks of same style
    order = opts.order or 0,
  }

  return self
end

-- increments by one until valid number found
-- needs to exist so that if a dock becomes a floating winow,
-- we're able to make a new one without overriding the dock
local function generateWinTitle()
  local name = SCRATCH_WIN_NAME
  local i = 1

  while ALL_WINDOWS[name] ~= nil do
    name = string.format("%s (%d)", SCRATCH_WIN_NAME, i)
    i = i + 1
  end

  return name
end

local function isWinActive(name)
  if not name or not ALL_WINDOWS[name] then return false end

  return vim.api.nvim_win_is_valid(ALL_WINDOWS[name]._winid)
end

-- returns winname of window if we know about it, if not returns nil
local function isManagedWinid(winid)
  if not winid then return nil end

  for winname, _ in pairs(DOCKED) do
    if ALL_WINDOWS[winname]._winid == winid then return winname end
  end

  if ALL_WINDOWS[CURRENT_FLOATING_WINDOW] then
    if winid == ALL_WINDOWS[CURRENT_FLOATING_WINDOW]._winid then
      return CURRENT_FLOATING_WINDOW
    end
  end

  return nil
end

-- So user can loop through their previously used windows
local function addToAccessList(winName)
  table.insert(ACCESS_LIST, winName)
  return #ACCESS_LIST
end

local function removeFromRecencyList(winname)
  for i, win in ipairs(ACCESS_LIST) do
    if winname == win then
      ACCESS_LIST_LENGTH = ACCESS_LIST_LENGTH + 1
      table.remove(ACCESS_LIST, i)
      goto END
    end
  end

  error("Couldn't find window " .. winname .. " in window list")

  ::END::
end

-- accepts a window with an attached buffer, and creates a floating window for it
local function attachFloatWindow(winopts)
  winopts.style = enum.float

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
    style = "minimal", -- No borders or extra UI elements
    border = "rounded",
  }

  -- hide any existing windows associated with this one
  if vim.api.nvim_win_is_valid(winopts._winid) then vim.api.nvim_win_hide(winopts._winid) end
  winopts._winid = vim.api.nvim_open_win(winopts.bufnr, true, win_config)
end

-- can be called safely: does not do anything if window is already closed
local function closeWindow(name)
  if name == nil or ALL_WINDOWS[name] == nil or isWinActive(name) == false then return end

  vim.api.nvim_win_hide(ALL_WINDOWS[name]._winid)
  -- this isn't really necessary but im making it clear to myself the window (not the buffer) truly is gone atp
  ALL_WINDOWS[name]._winid = -1

  if name == CURRENT_FLOATING_WINDOW then WINDOW_FLOATING = false end
  DOCKED[name] = nil
end

-- if passed a winname that is docked, will transform it into a floating window
-- empty string or null defaults to current floating window
-- if no current floating window, will make a new valid one
-- places the window buffer last in recency list
-- optionally accepts buffer to place into window (if not provided will make an empty one)


-- pure convenience function
-- returns a number if the window was new (which is its index to save computation time)
local function __updateWindow(name, winopts)
  local new_win_index = nil

  -- if this is a new window, we automatically know the window index is at the end
  if not ALL_WINDOWS[name] then
    new_win_index = addToAccessList(name)
  end

  -- allow user to pass in configs to change their windows
  ALL_WINDOWS[name] = newWinOpts(winopts)
  return new_win_index
end


-- TODO: GET HIPATTERNS WORKING AGAIN... ):
-- BUT ACTUALLY ALLOW USER TO PASS CUSTOM OPTIONS
local function toggleFloatWindow(name, winopts)
  if not name then error("Expected name, got nil") return end
  logMsg("closing " .. CURRENT_FLOATING_WINDOW)

  if isWinActive(CURRENT_FLOATING_WINDOW) then
    closeWindow(CURRENT_FLOATING_WINDOW)

    if name == CURRENT_FLOATING_WINDOW and not winopts then return end
  end

  local new_win_index = nil

  if not ALL_WINDOWS[name] or winopts ~= nil then
    new_win_index = __updateWindow(name, winopts)
  end

  if not vim.api.nvim_buf_is_valid(ALL_WINDOWS[name].bufnr) then
    -- TODO: allow user to pass a function that generates a default buffer if one not found
    ALL_WINDOWS[name].bufnr = vim.api.nvim_create_buf(false, true)
  end

  attachFloatWindow(ALL_WINDOWS[name])
  CURRENT_FLOATING_WINDOW = name
  WINDOW_FLOATING = true

  if not new_win_index then
    new_win_index = arrFind(ACCESS_LIST, name)
    if new_win_index == nil then error("new_win_index should have been added to ACCESS_LIST") end
  end

  CURRENT_WINDOW_INDEX = new_win_index
  logMsg("successfully switched to float " .. CURRENT_FLOATING_WINDOW)
end

-- like attachFloatWindow, but for dock
-- TODO: LEARN HOW SPLITS WORK SO YOU CAN FIGURE OUT WHAT ARGUMENTS THIS SHOULD ACCEPT
local function attachDockWindow(winopts)
  if not winopts.style then error("winopts should include a style element") end

  local win_config = {
    -- TODO: find out do we need a window to split from? or can we split relative to the whole screen?
    win = -1,
    split = map[winopts.style]
  }

  -- undesirable to have multiple windows of same buffer open
  if vim.api.nvim_win_is_valid(winopts._winid) then vim.api.nvim_win_hide(winopts._winid) end
  winopts._winid = vim.api.nvim_open_win(winopts.bufnr, false, win_config)
end

-- similar to toggleFloatWindow but instead creates a docked window
-- if passed a winname that is floating, will transform it into a docked window using its direction property
local function toggleDockWindow(name, winopts)
  if name == nil then error("Expected name, got nil") end

  if isWinActive(name) then
    closeWindow(name)

    -- if no additional configuration added, then we're done here
    if not winopts then return end
  end

  local new_win_index = nil
  if not ALL_WINDOWS[name] or winopts ~= nil then
    new_win_index = __updateWindow(name, winopts)
  end

  if not vim.api.nvim_buf_is_valid(ALL_WINDOWS[name].bufnr) then
    ALL_WINDOWS[name].bufnr = vim.api.nvim_create_buf(false, true)
  end

  attachDockWindow(ALL_WINDOWS[name])
  DOCKED[name] = true

  if not new_win_index then
    new_win_index = arrFind(ACCESS_LIST, name)
    if new_win_index == nil then error("new_win_index should have been added to ACCESS_LIST") end
  end

  CURRENT_WINDOW_INDEX = new_win_index
  logMsg("successfully switched to dock " .. CURRENT_FLOATING_WINDOW)
end

local function closeAllWindows()
  for name, _ in pairs(ALL_WINDOWS) do
    closeWindow(name)
  end
end

-- hey export this one too
local function deleteWindow(name)
  if name == nil then error("Expected name, got nil") end
  if ALL_WINDOWS[name] == nil then error(name .. " is not a valid window; failed to delete") end

  closeWindow(name)
  removeFromRecencyList(name)
  ALL_WINDOWS[name] = nil
  DOCKED[name] = nil

  -- TODO: DO THIS IN YOUR REMVOE FROM RECENCY LIST FUNC 
  if CURRENT_FLOATING_WINDOW == name then CURRENT_FLOATING_WINDOW = "" end
end

local function toggleWindow(name, winopts)
  if name == "" or name == nil then error("Cannot activate a window with no name") end

  local isFloat = DEFAULT_OPTS.style == enum.float
  if ALL_WINDOWS[name] then
    isFloat = ALL_WINDOWS[name].style == enum.float
  end

  if isFloat then toggleFloatWindow(name, winopts) else toggleDockWindow(name, winopts) end
end

local function toggleWindowFromInput()
  vim.ui.input({ prompt = "Window name: " }, function(input)
    if input == nil then return end

    input = trim(input)
    if input == "" then input = generateWinTitle() end

    if string.find(input, "^[^a-zA-z]") == nil then
      vim.notify("Please provide a valid window name (must start with a letter)", vim.log.levels.ERROR)
      return
    end

    toggleWindow(input)
  end)
end

local function toggleWindowFromFuzzy()
  local floaters = vim.tbl_keys(ALL_WINDOWS)
  local newwin = "* Add New Window"
  table.insert(floaters, newwin)

  fuzzyFindPrompt(floaters, "Pick a window", function(item)
    if item == newwin then
      toggleWindowFromInput()
      return
    end

    toggleWindow(item)
  end)
end

---@diagnostic disable
local function swapWindowType()
  local name = isManagedWinid(vim.api.nvim_get_current_win())

  if name == nil then
    vim.notify("you are not in a float!", vim.log.levels.WARN)
    return
  end

  local winopts = ALL_WINDOWS[name]

  if winopts.style == enum.float then
    -- don't screw over the user if they pass bad winopts
    if winopts.direction == enum.float then
      vim.notify("Passed invalid winopts data (direction), returning to defaults", vim.log.levels.WARN)
      winopts.direction = DEFAULT_OPTS.direction
    end

    winopts.style = winopts.direction
  else
    winopts.style = enum.float
  end

  toggleWindow(name, winopts)
end
---@diagnostic enable

vim.keymap.set("n", "<Leader>O", function()
  toggleWindow(ACCESS_LIST[CURRENT_WINDOW_INDEX] or generateWinTitle())
end, { desc = "[O]pen last floater" })

local augroup = vim.api.nvim_create_augroup("SKC_FloatLifecycle", { clear = true })
vim.api.nvim_create_autocmd({ "WinResized" }, {
  group = augroup,
  desc = "Allows split windows to persist across tabs",

  callback = function()
    ---@diagnostic disable-next-line: param-type-mismatch
    for _, winid in ipairs(vim.v.event.windows) do
      local name = isManagedWinid(winid)

      if name then
        logMsg(string.format("Managed window %s resized to %d", name, vim.api.nvim_win_get_width(winid)))
      end
    end
  end
})

-- vim.api.nvim_create_autocmd({ "WinExit" }, {
--   group = augroup,
--   desc = "Allows split windows to persist across tabs",
--
--   callback = function()
--     ---@diagnostic disable-next-line: param-type-mismatch
--     for _, winid in ipairs(vim.v.event.windows) do
--       local name = isManagedWinid(winid)
--
--       if name then
--         logMsg(string.format("Managed window %s resized to %d", name, vim.api.nvim_win_get_width(winid)))
--       end
--     end
--   end
-- })
