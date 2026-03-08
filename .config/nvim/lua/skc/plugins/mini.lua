return { -- Collection of various small independent plugins/modules
  "nvim-mini/mini.nvim",
  dependencies = { "rafamadriz/friendly-snippets" },
  version = false,
  config = function()
    require("mini.ai").setup({ n_lines = 500 })
    require("mini.comment").setup()

    local MiniNotify = require("mini.notify")
    MiniNotify.setup({ lsp_progress = { enable = false }, })
    MiniNotify.make_notify()
    vim.api.nvim_create_user_command("Notifs", function() MiniNotify.show_history() end, { desc = "Show notification history" })

    require("skc/plugins/miniconfig/hipatterns")
    require("skc/plugins/miniconfig/files")
    require("skc/plugins/miniconfig/snippets")

    local MiniSurround = require("mini.surround")
    MiniSurround.setup({})

    require("mini.pairs").setup({
      modes = { command = true },
      mappings = {
        ['"'] = false,
        ["'"] = false,
        ["`"] = false,
      },
    })

    local statusline = require("mini.statusline")
    statusline.setup({ use_icons = vim.g.have_nerd_font })
    statusline.section_location = function() return "%2l:%-2v" end
  end,
}
