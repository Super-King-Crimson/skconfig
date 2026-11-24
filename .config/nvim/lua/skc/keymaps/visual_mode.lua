-- highlights to end of line
vim.keymap.set("n", "vv", "v$h")

-- replace highlighted on paste and sends the stuff you replaced to black hole register
vim.keymap.set("v", "p", '"_dP')
