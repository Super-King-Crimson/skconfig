return {
  "folke/which-key.nvim",
  event = "VimEnter", -- Sets the loading event to 'VimEnter'
  opts = {
    -- delay between pressing a key and opening which-key (milliseconds)
    -- this setting is independent of vim.o.timeoutlen
    delay = 0,
    icons = {
      -- set icon mappings to true if you have a Nerd Font
      mappings = vim.g.have_nerd_font,
      -- If you are using a Nerd Font: set icons.keys to an empty table which will use the
      -- default which-key.nvim defined Nerd Font icons, otherwise define a string table
      keys = vim.g.have_nerd_font and {} or {
        Up = "<Up> ",
        Down = "<Down> ",
        Left = "<Left> ",
        Right = "<Right> ",
        C = "<C-…> ",
        M = "<M-…> ",
        D = "<D-…> ",
        S = "<S-…> ",
        CR = "<CR> ",
        Esc = "<Esc> ",
        ScrollWheelDown = "<ScrollWheelDown> ",
        ScrollWheelUp = "<ScrollWheelUp> ",
        NL = "<NL> ",
        BS = "<BS> ",
        Space = "<Space> ",
        Tab = "<Tab> ",
        F1 = "<F1>",
        F2 = "<F2>",
        F3 = "<F3>",
        F4 = "<F4>",
        F5 = "<F5>",
        F6 = "<F6>",
        F7 = "<F7>",
        F8 = "<F8>",
        F9 = "<F9>",
        F10 = "<F10>",
        F11 = "<F11>",
        F12 = "<F12>",
      },
    },

    triggers = {
      { "<LocalLeader>", mode = "n" },
      { "<auto>", mode = "nixsot" },
    },

    -- Document existing key chains
    spec = {
      { "<LocalLeader>j", group = "Previous tab" },
      { "<LocalLeader>k", group = "Next tab" },
      { "<LocalLeader>J", group = "First tab" },
      { "<LocalLeader>K", group = "Last tab" },
      { "<LocalLeader>H", group = "Move tab to first" },
      { "<LocalLeader>h", group = "Move tab left" },
      { "<LocalLeader>l", group = "Move tab right" },
      { "<LocalLeader>L", group = "Move tab to end" },
      { "<LocalLeader>n", group = "New tab" },
      { "<LocalLeader>p", group = "Split tab" },
      { "<LocalLeader>o", group = "Only tab" },
      { "<LocalLeader>x", group = "Close tab" },
      { "<LocalLeader>c", group = "Close Extras" },

      { "<leader>s", group = "[S]earch" },
      { "<leader>t", group = "[T]oggle" },
      { "<leader>o", group = "[O]pen" },
      { "<leader>f", group = "[F]old" },
      { "<leader>w", group = "[W]rite" },
      { "<leader>?", group = "Which[?]" },
      { "<leader>n", group = "Jump to [N]eovim files", mode = { "n" } },
    },
  },
}
