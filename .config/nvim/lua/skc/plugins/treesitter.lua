return { -- Highlight, edit, and navigate code
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    require('nvim-treesitter').install({
      "rust",
      "javascript",
      "c",
      "json",
      "lua",
      "luau",
      "markdown",
      "json",
      "bash",
    })
  end,
}
