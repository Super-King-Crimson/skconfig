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
if not (vim.uv or vim.loop).fs_stat(lazypath) then
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

---@diagnostic disable missing-parameter
require("lazy").setup({
  spec = {
    { import = "skc/plugins" },
  },

  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },

  -- automatically check for plugin updates
  change_detection = { enabled = false, notify = false, },
  checker = { enabled = false },
})

vim.cmd.colorscheme("moonfly")
