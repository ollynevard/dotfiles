local wezterm = require 'wezterm'

return {
  color_scheme = 'catppuccin-mocha',
  default_cursor_style = 'BlinkingBar',
  font = wezterm.font 'JetBrainsMono Nerd Font',
  font_size = 16,
  hide_tab_bar_if_only_one_tab = true,
  line_height = 1.3,
  macos_window_background_blur = 30,
  use_fancy_tab_bar = false,
  window_background_opacity = 0.9,
  window_decorations = 'RESIZE',
  window_padding = {
    left = '20px',
    right = '20px',
    top = '20px',
    bottom = '20px',
  }
}

