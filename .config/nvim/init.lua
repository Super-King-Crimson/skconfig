vim.g.mapleader = " "
vim.g.maplocalleader = "s"
vim.keymap.set("", "s", "<Nop>", { silent = true, noremap = true })
vim.keymap.set("n", "<Leader>nn", [[<cmd>exe 'e ' ..stdpath('config') ..'/init.lua'<CR>]], { desc = "Edit $MYVIMRC" })

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
  install = { colorscheme = { "habamax" } },
  import = "skc/plugins",
  change_detection = { enabled = true, notify = false, },

---@diagnostic disable-next-line - i think lazy's setup function leaks its internals by accident
})

-- Lua initialization file
vim.g.moonflyTransparent = true
vim.cmd.colorscheme("moonfly")
