vim.keymap.set("!", "<A-n>", "<C-Right>")
vim.keymap.set("!", "<A-p>", "<C-Left>")

vim.keymap.set("i", "<A-n>", "<Esc>ea")
vim.keymap.set("i", "<A-p>", "<Esc><BS>bi")

-- Backspacing and undos
vim.keymap.set("!", "<C-h>", "<C-w>")
vim.keymap.set("i", "<C-h>", "<C-g>u<C-w>")

vim.keymap.set("!", "<C-BS>", "<C-w>")
vim.keymap.set("i", "<C-BS>", "<C-g>u<C-w>")

-- buffer signature expansion for lsp
vim.keymap.set("i", "<C-j>", "")
vim.keymap.set("i", "<C-k>", vim.lsp.buf.signature_help)
