-- Making macros easier to use
vim.keymap.set("n", "<leader>m", "@q", { desc = "Execute contents of [m]acro" })
vim.keymap.set("v", "<leader>m", ":norm! @q<CR>", { desc = "Execute contents of [m]acro" })
vim.keymap.set("n", "<leader>M", "qq", { desc = "Start recording macro" })
