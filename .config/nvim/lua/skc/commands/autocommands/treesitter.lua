vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup("SKC_NvimTreesitterStart", { clear = true }),
  pattern = { "markdown", "json", "luau", "bash" },
  callback = function()
    vim.treesitter.start()

    vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    vim.wo.foldmethod = 'expr'
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})
