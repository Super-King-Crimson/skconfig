local MiniSnippets = require("mini.snippets")

local snippet_path = vim.fn.stdpath("config") .. "/snippets"
local global_snippets = snippet_path .. "/global.json"

local function loadSnippetsFromLang(context)
  if context.lang == "" or context.lang == nil then return end

  local lang_snippet_path = snippet_path .. "/" .. context.lang

  if vim.fn.isdirectory(lang_snippet_path) == 0 then return end

  local snippets = {}

  for _, file in ipairs(vim.fn.readdir(lang_snippet_path)) do
    table.insert(snippets, MiniSnippets.read_file(vim.fs.joinpath(lang_snippet_path, file)))
  end

  return snippets
end

require("mini.snippets").setup({
  snippets = {
    loadSnippetsFromLang,
    MiniSnippets.gen_loader.from_file(global_snippets)
  },

  mappings = {
    expand = "",
    jump_next = "<C-n>",
    jump_prev = "<C-p>",
    stop = "<C-c>",
  }
})
