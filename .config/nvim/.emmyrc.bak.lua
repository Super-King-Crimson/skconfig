local emmysettings = {
  ["$schema"] = "https://raw.githubusercontent.com/EmmyLuaLs/emmylua-analyzer-rust/refs/heads/main/crates/emmylua_code_analysis/resources/schema.json",
  completion = {
    callSnippet = false,
    enable = true
  },
  diagnostics = {
    disable = { "invert-if", "deprecated", "discard-returns", "inject-field", "missing-fields", "missing-global-doc", "need-check-nil", "param-type-not-match", "redefined-local", "unreachable-code" },
    severity = {
      ["access-invisible"] = "error",
      ["return-type-mismatch"] = "error",
      unused = "warning"
    }
  },
  runtime = {
    extensions = { ".lua" },
    requirePattern = { "lua/?.lua", "lua/?/init.lua" },
    version = "LuaJIT"
  },
  workspace = {
    ignoreDir = { "after", "snippets", "lsp" },
    library = { "/tmp/.mount_nvimKAEgjH/usr/share/nvim/runtime", "/home/skc/.local/share/nvim/lazy/blink.cmp", "/home/skc/.local/share/nvim/lazy/conform.nvim", "/home/skc/.local/share/nvim/lazy/fidget.nvim", "/home/skc/.local/share/nvim/lazy/friendly-snippets", "/home/skc/.local/share/nvim/lazy/lazy.nvim", "/home/skc/.local/share/nvim/lazy/lsp_signature.nvim", "/home/skc/.local/share/nvim/lazy/mason-tool-installer.nvim", "/home/skc/.local/share/nvim/lazy/mason.nvim", "/home/skc/.local/share/nvim/lazy/mini.nvim", "/home/skc/.local/share/nvim/lazy/mini.snippets", "/home/skc/.local/share/nvim/lazy/moonfly", "/home/skc/.local/share/nvim/lazy/nvim-notify", "/home/skc/.local/share/nvim/lazy/nvim-origami", "/home/skc/.local/share/nvim/lazy/nvim-treesitter", "/home/skc/.local/share/nvim/lazy/nvim-web-devicons", "/home/skc/.local/share/nvim/lazy/plenary.nvim", "/home/skc/.local/share/nvim/lazy/render-markdown.nvim", "/home/skc/.local/share/nvim/lazy/roslyn.nvim", "/home/skc/.local/share/nvim/lazy/telescope-fzf-native.nvim", "/home/skc/.local/share/nvim/lazy/telescope-ui-select.nvim", "/home/skc/.local/share/nvim/lazy/telescope.nvim", "/home/skc/.local/share/nvim/lazy/toggleterm.nvim", "/home/skc/.local/share/nvim/lazy/tokyonight.nvim", "/home/skc/.local/share/nvim/lazy/which-key.nvim" }
  }
}