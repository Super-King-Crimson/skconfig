return { -- Collection of various small independent plugins/modules
  "nvim-mini/mini.nvim",
  dependencies = { "rafamadriz/friendly-snippets" },
  version = false,
  config = function()
    require("mini.ai").setup({ n_lines = 500 })
    require("mini.comment").setup()

    require("skc/plugins/miniconfig/files")
    require("skc/plugins/miniconfig/snippets")

    local MiniSurround = require("mini.surround")
    MiniSurround.setup({
      mappings = {
        add = "S",
        highlight = "",
      }
    })

    require("mini.pairs").setup({
      modes = { command = true },
      mappings = {
        ['"'] = false,
        ["'"] = false,
        ["`"] = false,
      },
    })
  end,
}
