vim.g.mapleader = " "
vim.g.maplocalleader = "s"

vim.keymap.set("", "s", "<Nop>", { silent = true, noremap = true })

vim.g.have_nerd_font = true

-- oh my god i can make custom profiles
require("skc.keymaps")
require("skc.options")
require("skc.commands")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out,                            "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "moonfly" } },
  spec = {
    { import = "skc/plugins", }
  },
  change_detection = { enabled = false, notify = false },

  ---@diagnostic disable-next-line - i think lazy's setup function leaks its internals by accident
})

-- clipboard shenanigans
vim.o.shellcmdflag = "-c"
vim.o.clipboard = "unnamedplus"

-- for kde
if os.getenv("XDG_CURRENT_DESKTOP") == "KDE" then
  vim.notify("Current clipboard: KDE", vim.log.levels.INFO)

  local function kdeclip()
    local obj = vim.system({"qdbus6", "org.kde.klipper", "/klipper", "getClipboardContents",}, { text = true }):wait()

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

-- for remote servers
-- TODO: CONFIGURE TMUX
if os.getenv("SSH_CONNECTION") then
  vim.notify("Current clipboard: OSC52", vim.log.levels.INFO)

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

-- Lua initialization file
vim.g.moonflyTransparent = true
vim.g.moonflyWinSeparator = 0
vim.cmd.colorscheme("moonfly")
