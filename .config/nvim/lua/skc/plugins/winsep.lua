return {
  "nvim-zh/colorful-winsep.nvim",
  opts = {
    border = "bold",
    highlight = "#ffffff",
    excluded_ft = { "lazy", "TelescopePrompt", "mason" },
    animate = { enabled = false },
  },
  event = { "WinLeave" },
}
