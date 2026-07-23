vim.keymap.set("n", "<Leader>?d", "<cmd>pwd<CR>", { desc = "Which [D]irectory?" })
vim.keymap.set("n", "<Leader>?v", "<cmd>version<CR>", { desc = "Which [V]ersion?" })

vim.keymap.set("n", "<Leader>?f", function()
  vim.cmd("messages clear")
  print(vim.fn.expand("%:p"))
  vim.cmd("put =execute('messages')")
end, { desc = "Which [F]ile?" })
