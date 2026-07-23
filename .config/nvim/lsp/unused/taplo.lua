---@brief
---
--- https://taplo.tamasfe.dev/cli/usage/language-server.html
---
--- Language server for Taplo, a TOML toolkit.
---
--- `taplo-cli` can be installed via `cargo`:
--- ```sh
--- cargo install --features lsp --locked taplo-cli
--- ```

---@type vim.lsp.Config
return {
  cmd = { 'taplo', 'lsp', 'stdio' },
  filetypes = { 'toml' },
  settings = {
    evenBetterToml = {
      schema = {
        -- add additional schemas
        associations = {
          ['example\\.toml$'] = 'https://json.schemastore.org/example.json',
        }
      }
    }
  },
  root_markers = { '.taplo.toml', 'taplo.toml', '.git' },
}
