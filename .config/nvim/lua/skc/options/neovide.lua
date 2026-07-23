if vim.g.neovide then
  local scale = 0.5
  vim.g.neovide_fullscreen = true

  vim.o.guifont = "FiraCode Nerd Font Mono Ret:h18:w-0.4"
  vim.g.neovide_scale_factor = scale
  vim.g.neovide_scroll_animation_length = 0.2

  vim.opt.guicursor =
  "n-v-c:block-blinkwait200-blinkoff500-blinkon500,i-ci-ve:ver25-blinkwait200-blinkoff500-blinkon500,r-cr:hor20-blinkwait200-blinkoff500-blinkon500"

  vim.g.neovide_cursor_animation_length = 0.05
  vim.g.neovide_cursor_trail_size = 0.3
  vim.g.neovide_cursor_animate_in_insert_mode = false
  vim.g.neovide_cursor_smooth_blink = true

  local function toggleFullScreen()
    vim.g.neovide_fullscreen = not vim.g.neovide_fullscreen
  end

  local function resetScale()
    vim.g.neovide_scale_factor = scale
  end

  local function increaseScale()
    vim.g.neovide_scale_factor = vim.g.neovide_scale_factor + 0.05
  end

  local function decreaseScale()
    vim.g.neovide_scale_factor = vim.g.neovide_scale_factor - 0.05
  end

  vim.keymap.set("!", "<C-S-V>", "<C-r>+", { silent = true })

  vim.keymap.set({ "", "!", "t" }, "<F11>", toggleFullScreen, { silent = true })
  vim.keymap.set({ "", "!", "t" }, "<C-=>", increaseScale, { silent = true })
  vim.keymap.set({ "", "!", "t" }, "<C-->", decreaseScale, { silent = true })
  vim.keymap.set({ "", "!", "t" }, "<C-0>", resetScale, { silent = true })
end
