-- [J]ump around text faster
vim.keymap.set("n", "<Leader>h", "[q", { desc = "Quickfix list prev", remap = true })
vim.keymap.set("n", "<Leader>l", "]q", { desc = "Quickfix list next", remap = true })
vim.keymap.set("n", "H", "[l", { desc = "Location list prev", remap = true })
vim.keymap.set("n", "L", "]l", { desc = "Location next next", remap = true })

vim.keymap.set("", "<leader>j", "}", { desc = "Jump down to empty line" })
vim.keymap.set("", "<leader>k", "{", { desc = "Jump up to empty line" })

-- Better jk (spans wrapped lines)
vim.keymap.set("", "j", "gj")
vim.keymap.set("", "k", "gk")
-- Not in operator pending mode (i like my dj) (spans wrapped lines)
vim.keymap.del("o", "j")
vim.keymap.del("o", "k")

-- in case for some reason you WANT to skip a long ass line
vim.keymap.set("", "gj", "j")
vim.keymap.set("", "gk", "k")

vim.keymap.set("", "gh", "g^", { desc = "[G]o to beginning of line" })
vim.keymap.set("", "gl", "g$", { desc = "[G]o to end of line" })

vim.keymap.set("", "<C-j>",  "3gj")
vim.keymap.set("", "<C-k>", "3gk")
