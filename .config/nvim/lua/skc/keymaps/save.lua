-- Ctrl-S to save
vim.keymap.set({ "n", "i" }, "<C-s>", "<cmd>w!<CR>")
vim.keymap.set({ "n" }, "<Leader><C-s>", "<cmd>wa<CR>", { desc = "[S]ave all" })
