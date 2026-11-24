local hi = vim.cmd.hi

vim.o.fillchars = 'vert:┃,horiz:━,vertleft:┫,vertright:┣,verthoriz:╋,horizdown:┳,horizup:┻'

local augroup = vim.api.nvim_create_augroup("SKC_WindowSeparator", { clear = true })
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "moonfly",
  callback = function()
    hi("WinSeparator guifg=#444444 guibg=NONE")
  end,
  group = augroup,
})
