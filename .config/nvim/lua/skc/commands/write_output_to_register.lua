-- this one's kinda weird, its less a command and more a function
-- whatever!
local G = {}
setmetatable(G, G)

-- function hoisting has been implemented.
-- thank you gemini.
G.__index = function(_, key)
  return function(...)
    local v = rawget(G, key)
    return type(v) == "function" and v(...) or v
  end
end
G.__newindex = function(_, key, value)
  rawset(G, key, value)
end

_G.writeOutputToRegister = G.writeOutputToRegister
_G.w = G.writeOutputToRegister

vim.keymap.set("c", "<C-r><C-w>", "<Home>lua writeOutputToRegister([=[<End>]=])<Left>")

function G.writeOutputToRegister(cmd, reg, verbose)
  reg = reg or "+"
  verbose = verbose or true

  local process = vim.api.nvim_exec2(cmd, { output = true })
  local output = process.output

  if verbose then
    print(output)
  end

  vim.fn.setreg(reg, output)
end
