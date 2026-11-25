---@type vim.lsp.Config
return {
  cmd = { "vscode-json-language-server", "--stdio" },
  filetypes = { "json" },
  init_options = { provideFormatter = true }, -- needed to enable formatting capabilities
  root_markers = { "package.json", ".git" },
  settings = {
    json = { validate = true },
  },
}
