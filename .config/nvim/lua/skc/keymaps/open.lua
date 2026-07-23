local BROWSER = "firefox"
local COLORPICKER = "gcolor3"

vim.keymap.set("n", "<leader>ob", function()
  vim.cmd(string.format("!%s %s", BROWSER, vim.api.nvim_buf_get_name(0)))
end, { desc = "[O]pen in [B]rowser" })

local function openColorPicker()
  local obj = vim.system({ COLORPICKER }, { text = true }):wait()

  local color = string.match(obj.stdout or "", ".*(#%x+)")

  if not color or color == "" then
    vim.notify("No color detected", vim.log.levels.WARN)
    return
  end

  local lineText = vim.fn.getline(".")

  local cursor = vim.fn.getcursorcharpos()
  local line = cursor[2]
  local col = cursor[3]

  -- string can be at most 7 long
  local replace = false

  ---@diagnostic disable-next-line: param-type-mismatch
  local starti, endi = string.find(lineText, "#%x+", math.max(col - 7, 1))

  while starti ~= nil and starti < col do
    if starti <= col and endi >= col then
      replace = true
      break
    end

    starti, endi = string.find(lineText, "#%x+", endi + 1)
  end

  -- remove matched text
  if replace then
    vim.api.nvim_win_set_cursor(0, { line, starti })
    ---@diagnostic disable-next-line: param-type-mismatch
    vim.api.nvim_buf_set_text(0, line - 1, starti - 1, line - 1, endi, {})
  end

  vim.api.nvim_put({color}, "c", false, true)
end

vim.keymap.set("n", "<leader>oc", openColorPicker, { desc = "[O]pen [C]olor Picker" })
