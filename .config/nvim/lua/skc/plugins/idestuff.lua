-- EACH TOOL SHOULD BE EITHER IN ENSURE INSTALLED OR EXTERNAL
-- if something fits into multiple categories, put it in any one it applies to
local FORMATTERS_BY_FT = {
  html = { "superhtml" },
  css = { "prettier" },
}

local AUTOFORMAT_DISABLED_FT = {
  cpp = true,
  lua = true,
}

local ENSURE_INSTALLED = {
  servers = {
    "emmylua_ls",
    "luau-lsp",
    "rust-analyzer",
    "css-variables-language-server",
    "cssmodules-language-server",
    "css-lsp",
    "superhtml",
    "clangd",
    "typescript-language-server",
    "roslyn",
  },

  linters = {},
  formatters = {},
  debuggers = {},
}

local EXTERNAL = {
  servers = {
    "godot",
  },
  debuggers = {},
  formatters = {},
  linters = {},
}

-- only flattens 2D arrays/tables (only flattens the first level)
local function flatten(table2d)
  local t = {}

  for _, maybeTable in pairs(table2d) do
    if type(maybeTable) == "table" then
      for _, v in pairs(maybeTable) do
        table.insert(t, v)
      end
    else
      table.insert(t, maybeTable)
    end
  end

  return t
end

return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>wf",
        function()
          require("conform").format({ async = true, lsp_format = "fallback" })
        end,
        mode = "",
        desc = "[W]rite buffer [F]ormatted",
      },
    },
    opts = {
      formatters_by_ft = FORMATTERS_BY_FT,
      notify_on_error = false,

      format_on_save = function(bufnr)
        if AUTOFORMAT_DISABLED_FT[vim.bo[bufnr].filetype] then
          return nil
        else
          return {
            timeout_ms = 500,
            lsp_format = "fallback",
          }
        end
      end,
    },
  },

  {
    "saghen/blink.cmp",
    dependencies = { 'nvim-mini/mini.snippets' },
    version = '*',
    build = "cargo build --release",
    opts = {
      snippets = { preset = "mini_snippets" },
      keymap = { preset = "default" },
      fuzzy = {
        frecency = {
          enabled = false
        },
        sorts = {
          "exact",
          "score",
          "sort_text",
        },
        implementation = "prefer_rust_with_warning"
      },
      appearance = { nerd_font_variant = 'mono' },
      completion = { documentation = { auto_show = false } },

      sources = {
        default = { "lsp", "snippets", "buffer", "path" },
        providers = {
          snippets = {
            score_offset = 5,
          },
          lsp = {
            score_offset = 0,
          }
        }
      },
    },
  },

  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = {
      { "j-hui/fidget.nvim", opts = {} },
      "mason-org/mason.nvim",
    },

    config = function()
      require("mason").setup({
        registries = {
          "github:mason-org/mason-registry",
          "github:Crashdummyy/mason-registry",
        },
      })

      require("mason-tool-installer").setup({ ensure_installed = flatten(ENSURE_INSTALLED) })

      local allLsp = {}
      vim.list_extend(allLsp, ENSURE_INSTALLED.servers)
      vim.list_extend(allLsp, EXTERNAL.servers)

      vim.lsp.enable(allLsp)
    end,
  },

  -- C# specific lspconfig because its so stupid :sob:
  {
    "seblyng/roslyn.nvim",
    dependencies = {
      { "khoido2003/roslyn-filewatch.nvim", opts = { preset = "unity" } },
    },

    opts = {
      lock_target = true,
      silent = true,

      choose_target = function(targets)
        if #targets == 1 then
          return targets[1]
        end
      end,
    },

    {
      "ray-x/lsp_signature.nvim",
      event = "InsertEnter",
      opts = {
        floating_window = false,
        bind = true,
        handler_opts = {
          border = "rounded"
        }
      },
    },
  },
}
