local whichAutosession = require("skc.commands.autosession").whichAutosession

function generateWinTitle()
  local buffer_name = vim.api.nvim_buf_get_name(0)
  local cut_buffer_name = ""
  if string.find(buffer_name, "[][(){}]") then
    cut_buffer_name = ""
  else
    -- what the hell lua doesn't have string.split???
    local split = vim.split(buffer_name, "/")
    if #split == 1 then
      cut_buffer_name = split[1]
    else
      cut_buffer_name = split[#split-1] .. '/' .. split[#split]
    end
  end

  local readonly = vim.bo.readonly and " (read-only)" or ""

  local modified = vim.bo.modified
  local unsaved = ""
  if modified then unsaved = "*" end

  local raw_session = whichAutosession()
  local session = ""

  if raw_session ~= nil and raw_session ~= "none" then
    -- handle the 'latest > some_session' case
    local trimmed = string.gsub(raw_session, ".*>.", "")
    if trimmed == "" then
      session = ""
    else
      session = string.format(" (%s)", trimmed)
    end
  end

  local intermediate = session .. " - " .. cut_buffer_name
  if intermediate == " - " then intermediate = "" end
  return "neovim" .. intermediate .. unsaved .. readonly
end

vim.o.title = true
vim.o.titlestring = "%{v:lua.generateWinTitle()}"
