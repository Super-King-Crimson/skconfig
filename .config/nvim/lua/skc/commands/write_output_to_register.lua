-- this one's kinda weird, its less a command and more a function
-- whatever!
local function writeOutputToRegister(cmd, reg, tee)
  reg = reg or "+"

  -- also print
  tee = tee or true

  local process = vim.api.nvim_exec2(cmd, { output = true })
  local output = process.output

  if tee then
    print(output)
  end

  vim.fn.setreg(reg, output)
end

_G.writeOutputToRegister = writeOutputToRegister
vim.keymap.set("c", "<C-r><C-w>", "<Home>lua writeOutputToRegister([=[<End>]=])<Left>")

-- weird function hoisting prototype, thank you gemini
-- local G = {}
-- setmetatable(G, G)
--
-- G.__index = function(_, key)
--   return function(...)
--     local v = rawget(G, key)
--     return type(v) == "function" and v(...) or v
--   end
-- end
--
-- G.__newindex = function(_, key, value)
--   rawset(G, key, value)
-- end

