vim.keymap.set("n", "<Leader>?d", '"=getcwd()<CR>p', { desc = "Pastes current working [d]irectory" })
vim.keymap.set("n", "<Leader>?f", [=["=expand('%:p')<CR>p]=], { desc = "Pastes current path of current [f]ile" })
