---@brief
---
--- https://github.com/antonk52/cssmodules-language-server
---
--- Language server for autocompletion and go-to-definition functionality for CSS modules.
---
--- You can install cssmodules-language-server via npm:
--- ```sh
--- npm install -g cssmodules-language-server
--- ```

---@type vim.lsp.Config
return {
  -- see typescript-language-server config to see why we have to do this
  cmd = { "cssmodules-language-server" },
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  root_markers = { "package.json" },
}
