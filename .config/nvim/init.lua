vim.g.mapleader = " "
vim.g.maplocalleader = "s"

vim.keymap.set("", "s", "<Nop>", { silent = true, noremap = true })

vim.g.have_nerd_font = true

-- oh my god i can make custom profiles
require("skc.keymaps")
require("skc.options")
require("skc.commands")

-- for remote servers
-- vim.g.clipboard = {
--   name = 'OSC 52',
--   copy = {
--     ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
--     ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
--   },
--   paste = {
--     ['+'] = require('vim.ui.clipboard.osc52').paste('+'),
--     ['*'] = require('vim.ui.clipboard.osc52').paste('*'),
--   },
-- }

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

-- Lua initialization file
vim.g.moonflyTransparent = true
vim.g.moonflyWinSeparator = 0
vim.cmd.colorscheme("moonfly")
