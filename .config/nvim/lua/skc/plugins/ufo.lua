return {
  'kevinhwang91/nvim-ufo',
  dependencies = {'kevinhwang91/promise-async'},
  config = function()
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.textDocument.foldingRange = {
      dynamicRegistration = false,
      lineFoldingOnly = true
    }

    require("ufo").setup({
      provider_selector = function(bufnr)
        if #vim.lsp.get_clients({ bufnr = bufnr }) > 0 then
          return {"lsp", "indent"}
        end

        return {"treesitter", "indent"}
      end
    })
  end
}
