local MiniSnippets = require("mini.snippets")

local snippet_path = vim.fn.stdpath("config") .. "/snippets"
local global_snippets = snippet_path .. "/global.json"

local function loadSnippets(context)
  local lang = context.lang
  local lang_snippet_path = snippet_path .. "/" .. lang

  local snippets = {}

  if vim.fn.isdirectory(lang_snippet_path) == 0 then return end

  for _, file in ipairs(vim.fn.readdir(lang_snippet_path)) do
    table.insert(snippets, MiniSnippets.read_file(vim.fs.joinpath(lang_snippet_path, file)))
  end

  return snippets
end

require("mini.snippets").setup({
  snippets = {
    loadSnippets,
    MiniSnippets.gen_loader.from_file(global_snippets)
  },

  mappings = {
    expand = "",
    jump_next = "<C-n>",
    jump_prev = "<C-p>",
    stop = "<C-c>",
  }
})
