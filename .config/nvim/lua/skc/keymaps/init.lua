vim.keymap.set("n", "<Leader>nn", [[<cmd>exe 'e ' ..stdpath('config') ..'/init.lua'<CR>]], { desc = "Edit $MYVIMRC" })

vim.keymap.set({ "", "!", "t" }, "<C-x><C-x>", "<C-\\><C-n>", { desc = "Universal Escape" })

vim.keymap.set("n", "<Leader>.", "<cmd>cd %:h<CR>", { desc = "Set workspace directory to that of current buffer" })
vim.keymap.set("n", "<Leader>|", "<cmd>tcd %:h<CR>", { desc = "Set tab directory to that of current buffer" })

vim.keymap.set("", "c", "\"_c", { desc = "Make c always delete into the black hole register" })
vim.keymap.set("n", "cc", "^\"_c$", { desc = "Make c always delete into the black hole register" })

vim.keymap.set("n", "<Leader>F", "<cmd>wincmd o<CR>", { desc = "[F]ocus current window" })

require("skc.keymaps.diagnostics")
require("skc.keymaps.fold")
require("skc.keymaps.insert_ext")
require("skc.keymaps.macro")
require("skc.keymaps.movement")
require("skc.keymaps.normal_ext")
require("skc.keymaps.open")
require("skc.keymaps.save_quit_farewell")
require("skc.keymaps.tabs")
require("skc.keymaps.terminal_ext")
require("skc.keymaps.visual_ext")
require("skc.keymaps.which")
