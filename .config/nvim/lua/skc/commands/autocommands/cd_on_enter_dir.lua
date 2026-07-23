local function is_weirdass_uri(uri)
  -- Remember at some point we will be in the directory itself so ignore any other weird buffers opening up
  if string.match(uri, "//") then
    return true
  else
    return false
  end
end

local function try_change_dir(args)
  local success, path = pcall(function()
    return vim.api.nvim_buf_get_name(args.buf)
  end)

  if not success then
    return
  end

  if is_weirdass_uri(path) then
    return
  end

  if vim.fn.isdirectory(path) ~= 1 then
    return
  end

  local clients = vim.lsp.get_clients({ bufnr = args.buf })
  if #clients > 0 then
    -- Don't mess with lsp autocommands.
    return
  end

  vim.cmd.cd(path)
  vim.notify("Changed directory to " .. (path or "not found"))
end

local group = vim.api.nvim_create_augroup("SKC_CdOnEnterDir", { clear = true })
vim.api.nvim_create_autocmd("BufEnter", {
  group = group,
  callback = try_change_dir,
  desc = "Attempt to change buffers when a directory is entered (many caveats)",
})
