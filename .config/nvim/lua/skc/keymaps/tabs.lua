-- switch tabs
local function tabnext()
  for _ = 1, vim.v.count1 do
    vim.cmd("tabn")
  end
end

local function tabprev()
  for _ = 1, vim.v.count1 do
    vim.cmd("tabp")
  end
end

vim.keymap.set("n", "<LocalLeader>J", "<cmd>tabfirst<CR>")
vim.keymap.set("n", "<LocalLeader>j", tabprev)
vim.keymap.set("n", "<LocalLeader>k", tabnext)
vim.keymap.set("n", "<LocalLeader>K", "<cmd>tablast<CR>")

-- move tabs
vim.keymap.set("n", "<LocalLeader>H", "<cmd>tabm0<CR>")
vim.keymap.set("n", "<LocalLeader>h", "<cmd>tabm-<CR>")
vim.keymap.set("n", "<LocalLeader>l", "<cmd>tabm+<CR>")
vim.keymap.set("n", "<LocalLeader>L", "<cmd>tabm<CR>")

vim.keymap.set("n", "<LocalLeader>n", "<cmd>tabe<CR>")
vim.keymap.set("n", "<LocalLeader>p", "<cmd>tab sp<CR>")

vim.keymap.set("n", "<LocalLeader>x", "<cmd>tabc<CR>")

vim.keymap.set("n", "<LocalLeader>ch", "<cmd>0,.-1tabdo tabc<CR>")
vim.keymap.set("n", "<LocalLeader>cl", "<cmd>.+1,$tabdo tabc<CR>")

vim.keymap.set("n", "<LocalLeader>o", ":tabo<CR>")

local altLocalLeader = "<A-" .. vim.g.maplocalleader .. ">"
vim.keymap.set({ "", "!" }, altLocalLeader, "<Esc>g<Tab>")

vim.keymap.set({ "", "!", "t" }, "<A-1>", "<cmd>1tabnext<CR>")
vim.keymap.set({ "", "!", "t" }, "<A-2>", "<cmd>2tabnext<CR>")
vim.keymap.set({ "", "!", "t" }, "<A-3>", "<cmd>3tabnext<CR>")
vim.keymap.set({ "", "!", "t" }, "<A-4>", "<cmd>4tabnext<CR>")
vim.keymap.set({ "", "!", "t" }, "<A-5>", "<cmd>5tabnext<CR>")
vim.keymap.set({ "", "!", "t" }, "<A-6>", "<cmd>6tabnext<CR>")
vim.keymap.set({ "", "!", "t" }, "<A-7>", "<cmd>7tabnext<CR>")
vim.keymap.set({ "", "!", "t" }, "<A-8>", "<cmd>8tabnext<CR>")
vim.keymap.set({ "", "!", "t" }, "<A-9>", "<cmd>9tabnext<CR>")
vim.keymap.set({ "", "!", "t" }, "<A-0>", "<cmd>10tabnext<CR>")
