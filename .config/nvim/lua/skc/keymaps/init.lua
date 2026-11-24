vim.keymap.set("n", "<Leader>nn", [[<cmd>exe 'e ' ..stdpath('config') ..'/init.lua'<CR>]], { desc = "Edit $MYVIMRC" })

vim.keymap.set({ "", "!", "t" }, "<C-x><C-x>", "<C-\\><C-n>", { desc = "Universal Escape" })

vim.keymap.set("n", "<Leader>.", "<cmd>cd %:h<CR>", { desc = "Set workspace directory to that of current buffer" })

-- If you delete text with c, it will not overwrite the default register
vim.keymap.set("", "c", "\"_c")
vim.keymap.set("n", "cc", "^\"_c$")

require("skc.keymaps.diagnostics")
require("skc.keymaps.fold")
require("skc.keymaps.insert_mode")
require("skc.keymaps.macro")
require("skc.keymaps.movement")
require("skc.keymaps.normal_mode")
require("skc.keymaps.save")
require("skc.keymaps.tabs")
require("skc.keymaps.visual_mode")
require("skc.keymaps.which")
