-- Backspacing and undos
vim.keymap.set("!", "<C-h>", "<C-w>")
vim.keymap.set("t", "<C-BS>", "<C-h>")
vim.keymap.set("i", "<C-h>", "<C-g>u<C-w>")

vim.keymap.set("!", "<C-BS>", "<C-w>")
vim.keymap.set("i", "<C-BS>", "<C-g>u<C-w>")

-- buffer signature expansion for lsp
vim.keymap.set("i", "<C-j>", "")
vim.keymap.set("i", "<C-k>", vim.lsp.buf.signature_help)
