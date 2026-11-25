---@brief
---
--- https://github.com/JohnnyMorganz/luau-lsp
---
--- Language server for the [Luau](https://luau-lang.org/) language.
---
--- `luau-lsp` can be installed by downloading one of the release assets available at https://github.com/JohnnyMorganz/luau-lsp.
---
--- You might also have to set up automatic filetype detection for Luau files, for example like so:
---
--- ```vim
--- autocmd BufRead,BufNewFile *.luau setf luau
--- ```

-- get type defs here: https://luau-lsp.pages.dev/type-definitions/globalTypes.None.d.luau
-- get docs here: https://luau-lsp.pages.dev/api-docs/en-us.json
---@type vim.lsp.Config
return {
  cmd = {
    'luau-lsp',
    'lsp',
    '--definitions:@roblox=' .. vim.fn.expand("~/src/docs/roblox/globalTypes.d.luau"),
    '--docs=' .. vim.fn.expand("~/src/docs/roblox/globalTypes-en-us.json"),
  },
  settings = {
    ["luau-lsp"] = {
      platform = {
        type = "roblox"
      }
    }
  },
  filetypes = { 'luau' },
  root_markers = { '.git' },
}
