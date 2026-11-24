-- display a status line at the bottom of the screen
vim.o.laststatus = 3
-- don't need this because mode is shown in the status line
vim.o.showmode = false

-- weird terminal options
vim.o.shellcmdflag = "-c"
vim.o.termguicolors = true

-- what saves when you mksession
vim.o.sessionoptions = "buffers,curdir,folds,help,tabpages,winsize"

-- Start all folds unfolded (duh)
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99

-- time before nvim considers your cursor idle (for hold autocommands)
vim.o.updatetime = 250

-- case-insensitive search
vim.o.smartcase = false
vim.o.ignorecase = true

-- make search not wrap around to beginning of file
vim.o.wrapscan = false

-- don't wait for enter before matching searches or substitutions
vim.o.incsearch = true
vim.o.inccommand = "split"

-- line numbers and relative line numbers
vim.o.number = true
vim.o.relativenumber = true

-- this controls:
  -- how many spaces a tab character should be displayed as (tabstop)
  -- how many spaces an indent should be (shiftwidth)
  -- how many spaces pressing tab should insert (softtabstop)
  -- if spaces or tabs are used (expandtab)
-- when softtabstop is negative, shiftwidth is used
-- when shiftwidth is 0, tabstop is used
-- therefore we can easily exit our config with just tabstop and expandtab
vim.o.tabstop = 4
vim.o.shiftwidth = 0
vim.o.softtabstop = -1
vim.o.expandtab = false
vim.o.wrap = false

-- turn on visible whitespace characters
vim.o.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- enables mouse in [a]ll modes
vim.o.mouse = "a"

vim.o.breakindent = true
vim.o.undofile = true

-- Keep signcolumn on by default
vim.o.signcolumn = "yes:1"

-- Configure how split windows should be opened
vim.o.splitright = true
vim.o.splitbelow = true

-- highlight the current line you're on
vim.o.cursorline = true

-- scroll automatically, centering cursor
vim.o.scrolloff = 999

-- Save and restore things to SHAred DAta file (persist after shutdown and on closing vim)
-- ! = save global variables (like g:my_var)
-- %n = store the n most recently opened buffers
-- 'n = store marks for the n most recently opened files
-- /n = store n recently used search pattern items
-- :n = store n most recently executed commands
-- @n = store n most recent items in input line
-- h  = highlight search should not work in a .shada file
-- sn = max size an item can be, in KB
vim.o.shada = "%100,'100,/10,:100,@100,h,s100"

require("skc.options.clipboard")
require("skc.options.diagnostics")
require("skc.options.neovide")
require("skc.options.window_separation")
require("skc.options.window_title")
