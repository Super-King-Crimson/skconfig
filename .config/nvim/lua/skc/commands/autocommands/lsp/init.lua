local hover_highlight = require("skc.commands.lsp.hover_highlight")
local setup_lsp_keymaps = require("skc.commands.lsp.setup_lsp_keymaps")

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
  callback = function(event)
    hover_highlight(event)
    setup_lsp_keymaps(event)
  end,
})
