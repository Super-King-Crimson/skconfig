-- Opens line below/above but stays in normal mode
vim.keymap.set("n", "<A-o>", 'o<Esc>"_cc<Esc>')
vim.keymap.set("n", "<A-O>", 'O<Esc>"_cc<Esc>')

-- Clicking esc also turns off any macros and clears search highlights
vim.keymap.set("n", "<Esc>", "<Esc>q<Esc><cmd>noh<CR>")

