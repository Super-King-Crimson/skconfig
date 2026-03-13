-- Options --
vim.o.termguicolors = true
vim.o.laststatus = 3

-- Use treesitter to work out our folds
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99

vim.o.sessionoptions = "buffers,curdir,folds,help,tabpages,winsize"

-- Use treesitter to work out our indents
vim.o.indentexpr = 'v:lua.require("nvim-treesitter").indentexpr()'

vim.o.wrap = false
vim.o.updatetime = 250

vim.o.timeout = true
vim.o.timeoutlen = 5000

-- case-insensitive search
vim.o.smartcase = false
vim.o.ignorecase = true

vim.o.wrapscan = false
vim.o.incsearch = true

vim.o.number = true
vim.o.relativenumber = true

-- when softtabstop is negative, shiftwidth is used
-- when shiftwidth is 0, tabstop is used
-- therefore we can easily exit our config with just tabstop and expandtab
vim.o.tabstop = 4
vim.o.shiftwidth = 0
vim.o.softtabstop = -1
vim.o.expandtab = false

vim.o.mouse = "a"
vim.o.showmode = false

vim.schedule(function()
  vim.o.clipboard = "unnamedplus"
end)

vim.o.breakindent = true
vim.o.undofile = true

-- Keep signcolumn on by default
vim.o.signcolumn = "yes:1"

-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

vim.o.inccommand = "split"
vim.o.cursorline = true

vim.o.scrolloff = 999
vim.o.confirm = true

-- Save and restore things to SHAred DAta file (persist after shutdown and on closing vim) !  = global variables
-- %n = store the n most recently opened buffers
-- 'n = store marks for the n most recently opened files
-- /n = store n recently used search pattern items
-- :n = store n most recently executed commands
-- @n = store n most recent items in input line
-- h  = highlight search does not work in a .shada file
-- sn = max size an item can be, in KB
vim.o.shada = "'10,/0,:100,@100,h,s100"

require("skc.options.diagnostics")
require("skc.options.neovide")
require("skc.options.highlight")
require("skc.options.wintitle")
