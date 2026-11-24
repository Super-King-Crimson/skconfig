local function wipe_missing_files()
  local buffers = vim.api.nvim_list_bufs()
  local deleted_buffers = {}

  for _, bufnr in ipairs(buffers) do
    local success, path = pcall(function()
      return vim.api.nvim_buf_get_name(bufnr)
    end)

    if not success then
      path = ""
    end

    if path ~= "" and vim.uv.fs_stat(path) == nil then
      if vim.bo[bufnr].buftype == "" then
        vim.api.nvim_buf_delete(bufnr, { force = true })
        table.insert(deleted_buffers, path)
      end
    end
  end

  if #deleted_buffers > 0 then
    -- local message = "Deleted " .. vim.fn.fnamemodify(deleted_buffers[1], ":t")
    local message = "Deleted " .. deleted_buffers[1]

    if #deleted_buffers > 1 then
      message = message .. " and " .. #deleted_buffers - 1 .. " other"

      if #deleted_buffers > 2 then
        message = message .. "s"
      end
    end

    -- for _, v in ipairs(deleted_buffers) do
    --   vim.notify(v .. " deleted", vim.log.levels.INFO)
    -- end

    -- vim.notify(message, vim.log.levels.INFO)
  end
end

local group = vim.api.nvim_create_augroup("SKC_BWipeoutOnDelete", { clear = true })
vim.api.nvim_create_autocmd({ "TabEnter" }, {
  group = group,
  callback = wipe_missing_files,
  desc = "Wipeout buffers that have been deleted",
})
