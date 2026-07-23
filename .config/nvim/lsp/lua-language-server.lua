local stdconfig = vim.fn.stdpath("config")
local stdconfig_len = string.len(stdconfig)

---@type vim.lsp.Config
return {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  root_markers = {
    '.emmyrc.json',
    '.luarc.json',
    '.luarc.jsonc',
  },

  on_init = function(client)
    if client.workspace_folders then
      local path = client.workspace_folders[1].name

      if path ~= vim.fn.stdpath('config') and (vim.uv.fs_stat(path .. '/.luarc.json')
        or vim.uv.fs_stat(path .. '/.luarc.jsonc'))
        then return end
      end

      local include = {}

      for _, dir in ipairs(vim.api.nvim_get_runtime_file("", true)) do
        if not string.find(string.sub(dir, 1, stdconfig_len), stdconfig, 1, true) then
          table.insert(include, dir)
        end
      end

      table.insert(include, '${3rd}/luv/library')

      ---@diagnostic disable-next-line: param-type-mismatch
      client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
        runtime = {
          version = 'LuaJIT',
          path = {
            'lua/?.lua',
            'lua/?/init.lua',
          },
        },

        workspace = {
          checkThirdParty = false,
          library = include,
          ignoreDir = vim.fs.joinpath(stdconfig, "lsp", "unused")
        },
      })
    end,

    settings = {
      Lua = {
        codeLens = { enable = true },
        hint = { enable = true, semicolon = 'Disable' },
      },
    },
  }
