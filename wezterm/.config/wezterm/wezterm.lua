local wezterm = require('wezterm');
local act = wezterm.action;

return {
  color_scheme = 'catppuccin-mocha',
  default_cursor_style = 'BlinkingBar',
  font = wezterm.font('JetBrainsMono Nerd Font'),
  font_size = 16,
  hide_tab_bar_if_only_one_tab = true,
  keys = {
    {
      mods = 'CTRL',
      key = 'f',
      action = act.ToggleFullScreen
    }
  },
  line_height = 1.3,
  macos_window_background_blur = 30,
  scrollback_lines = 10000,
  use_fancy_tab_bar = false,
  window_background_opacity = 0.9,
  window_decorations = 'RESIZE',
  window_padding = {
    left = '2cell',
    right = '2cell',
    top = '0.7cell',
    bottom = '0.7cell'
  }
};
