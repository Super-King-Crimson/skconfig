local fuzzyFindPrompt = require("labtools").fuzzyFindPrompt

return {
  dir = vim.fs.joinpath(vim.fn.stdpath("config"), "external", "win.nvim"),

  config = function()
    local win = require("win")

    local shortcuts = {
      ["New Scratch"] = function()
        vim.ui.input({ prompt = "Window name: " }, function(input)
          if input == nil then return end
          if input == "" then input = win.generateUniqueWinName() end

          win.toggleWindow(input)
        end)
      end,
      ["New Terminal"] = function()
        win.toggleWindow(win.generateUniqueWinName("Terminal"), {
          enter = true,
          createBuf = function()
            local buf = vim.api.nvim_create_buf(false, true)
            vim.api.nvim_buf_call(buf, function() vim.cmd("term!") end)

            vim.api.nvim_create_autocmd("BufEnter", {
              buffer = buf,
              callback = function()
                vim.cmd("startinsert")
              end,
            })

            vim.cmd("norm i")

            return buf
          end
        })
      end,
    }

    local function toggleWindowFromFuzzy()
      local wins = vim.tbl_keys(win.wins)

      for key, _ in pairs(shortcuts) do
        table.insert(wins, "* " .. key)
      end

      fuzzyFindPrompt(wins, "Pick a window", function(item)
        if string.sub(item, 1, 1) == "*" then
          local key = string.sub(item, 3)
          shortcuts[key]()
          return
        end

        win.toggleWindow(item)
      end)
    end

    vim.keymap.set("n", "<Leader>O", win.toggleWindow, { desc = "[O]pen last float" })
    vim.keymap.set("n", "<Leader>on", shortcuts["New Scratch"], { desc = "[O]pen [N]ew Scratch" })
    vim.keymap.set("n", "<Leader>of", toggleWindowFromFuzzy, { desc = "[O]pen [F]loat menu" })
    vim.keymap.set("n", "<Leader>oa", win.toggleAllDocks, { desc = "[O]pen [A]ll Docks" })
    vim.keymap.set("n", "<Leader>ot", shortcuts["New Terminal"], { desc = "[O]pen [T]erminal" })

    vim.keymap.set("n", "<Leader>oh", function()
      win.toggleWindow(win.generateUniqueWinName("Help"), {
        keys = {
          ["<C-o>"] = { disabled = true },
          ["<C-i>"] = { disabled = true },
        },
        wo = {
          winfixbuf = false,
          conceallevel = 2,
          concealcursor = "nc",
        },
        floating = false,
        createBuf = function()
          local buf = vim.api.nvim_create_buf(false, true)
          vim.bo[buf].buftype = "help"

          vim.api.nvim_buf_call(buf, function() vim.cmd("h") end)

          return buf
        end
      })
    end, { desc = "[O]pen [H]elp" })
  end
}
