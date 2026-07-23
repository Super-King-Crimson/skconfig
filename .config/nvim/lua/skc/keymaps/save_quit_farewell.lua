-- Ctrl-S to save
vim.keymap.set({ "n", "i" }, "<C-s>", "<cmd>w!<CR>")
vim.keymap.set({ "n" }, "<Leader><C-s>", "<cmd>wa<CR>", { desc = "[S]ave all" })

-- Quitting suite (Ctrl-F for farewell)
local function farewell_nosave()
  ---@diagnostic disable-next-line
  _G.FAREWELL = "yes"
  vim.cmd("qa!")
end

-- Quitting suite (Ctrl-F for farewell)
local function farewell()
  -- whether or not we were successful in saving every buffer
  -- (example: some scratch buffer)
  pcall(function()
    vim.cmd("silent! wa!")
  end)

  farewell_nosave()
end

vim.keymap.set({ "", "!", "t" }, "<C-f>d", "<cmd>bdelete<CR>", { desc = "[D]elete the current buffer" })
vim.keymap.set({ "", "!", "t" }, "<C-f>f", "<cmd>q<CR>", { desc = "Quit" })
vim.keymap.set({ "", "!", "t" }, "<C-f>s", "<cmd>wq<CR>", { desc = "[S]ave and quit" })
vim.keymap.set({ "", "!", "t" }, "<C-f>a", farewell_nosave, { desc = "Quit [A]ll" })

vim.keymap.set({ "", "!", "t" }, "<C-f>F", farewell, { desc = "Catch you later! 👋" })
