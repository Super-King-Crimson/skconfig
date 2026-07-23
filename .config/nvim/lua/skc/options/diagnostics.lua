vim.diagnostic.config({
  severity_sort = true,
  float = { border = "rounded", source = "if_many" },
  underline = { severity = vim.diagnostic.severity.ERROR },

  signs = not vim.g.have_nerd_font and {} or {
    text = {
      [vim.diagnostic.severity.ERROR] = "󰅚 ",
      [vim.diagnostic.severity.WARN] = "󰀪 ",
      [vim.diagnostic.severity.INFO] = "󰋽 ",
      [vim.diagnostic.severity.HINT] = "󰌶 ",
    },
  },

  virtual_text = {
    source = "if_many",
    spacing = 2,
    format = function(diagnostic)
      local diagnostic_message = {
        [vim.diagnostic.severity.ERROR] = string.format("(%s) %s", diagnostic.code, diagnostic.message),
        [vim.diagnostic.severity.WARN] = string.format("(%s) %s", diagnostic.code, diagnostic.message),
        [vim.diagnostic.severity.INFO] = string.format("(%s) %s", diagnostic.code, diagnostic.message),
        [vim.diagnostic.severity.HINT] = string.format("(%s) %s", diagnostic.code, diagnostic.message),
      }
      return diagnostic_message[diagnostic.severity]
    end,
  },

  -- this sucks ass, don't re-enable it
  -- virtual_lines = {
  --   current_line = false,
  --   severity = {
  --     vim.diagnostic.severity.HINT,
  --     vim.diagnostic.severity.INFO,
  --     vim.diagnostic.severity.WARN,
  --     vim.diagnostic.severity.ERROR,
  --   },
  --   format = function(diagnostic)
  --     return string.format("%s (%s)", diagnostic.message, diagnostic.code)
  --   end,
  -- },
})
