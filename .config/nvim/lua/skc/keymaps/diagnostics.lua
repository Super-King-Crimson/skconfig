-- Diagnostic keymaps
vim.keymap.set("n", "<Leader>dg", vim.diagnostic.setqflist, { desc = "[D]iagnostic [G]lobal (to qflist)" })
vim.keymap.set("n", "<Leader>dl", vim.diagnostic.setloclist, { desc = "[D]iagnostic [L]ocal (to loclist)" })
vim.keymap.set("n", "<Leader>D", vim.diagnostic.open_float, { desc = "[D]iagnostic at cursor" })
