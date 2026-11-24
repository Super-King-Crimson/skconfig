-- syncs nvim register with computer clipboard
vim.o.clipboard = "unnamedplus"

local function kdeclip()
  local obj = vim.system({ "qdbus6", "org.kde.klipper", "/klipper", "getClipboardContents", }, { text = true }):wait()

  if obj.code ~= 0 then
    vim.notify(string.format("fail: %s", obj.stderr), vim.log.levels.ERROR)
  end

  local lines = {}
  for line in string.gmatch(obj.stdout, "([^\n]*)\n") do
    table.insert(lines, line)
  end

  -- insert mode by default
  local pastemode = "v"

  -- block mode if we grab a lot of lines
  if #lines > 1 then
    pastemode = "V"
  end

  ---@diagnostic disable-next-line
  return { lines, pastemode }
end

if os.getenv("XDG_CURRENT_DESKTOP") == "KDE" then
  -- vim.notify("Current clipboard: KDE", vim.log.levels.INFO)

  vim.g.clipboard = {
    name = 'KDE',
    copy = {
      ["+"] = "xclip -selection clipboard",
      ["*"] = "xclip -selection primary",
    },
    paste = {
      ["+"] = kdeclip,
      ["*"] = kdeclip,
    },
    cache_enabled = 0,
  }
end

if os.getenv("SSH_CONNECTION") then
  -- vim.notify("Current clipboard: OSC52", vim.log.levels.INFO)

  vim.g.clipboard = {
    name = 'OSC52',
    copy = {
      ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
      ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
    },
    paste = {
      ['+'] = require('vim.ui.clipboard.osc52').paste('+'),
      ['*'] = require('vim.ui.clipboard.osc52').paste('*'),
    },
  }
end
