return function(event)
  local map = function(keys, func, desc, mode)
    mode = mode or "n"
    vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
  end

  map("grn", vim.lsp.buf.rename, "[R]e[n]ame")
  map("gra", vim.lsp.buf.code_action, "[G]oto Code [A]ction", { "n", "x" })
  map("grr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
  map("gri", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
  map("grd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
  map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
  map("gO", require("telescope.builtin").lsp_document_symbols, "Open Document Symbols")
  map("grt", require("telescope.builtin").lsp_type_definitions, "[G]oto [T]ype Definition")

  local client = vim.lsp.get_client_by_id(event.data.client_id)
  if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
    map("<leader>th", function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
    end, "[T]oggle Inlay [H]ints")
  end
end
