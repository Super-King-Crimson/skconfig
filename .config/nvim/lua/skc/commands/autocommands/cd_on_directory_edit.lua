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

  if not success or is_weirdass_uri(path) or vim.fn.isdirectory(path) ~= 1 then
    return
  end

  vim.cmd.cd(path)
  vim.notify("Changed directory to " .. path)
end

local group = vim.api.nvim_create_augroup("SKC_CDOnDirectoryEdit", { clear = true })
vim.api.nvim_create_autocmd("BufEnter", {
  group = group,
  callback = try_change_dir,
  desc = "Change buffers when a directory is edited",
})
