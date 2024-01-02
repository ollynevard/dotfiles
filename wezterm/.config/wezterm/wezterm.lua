local wezterm = require 'wezterm'

local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.font = wezterm.font 'MonoLisa Nerd Font Mono'
config.font_size = 16
config.line_height = 1.4
config.default_cursor_style = 'BlinkingBar'
config.color_scheme = 'catppuccin-mocha'
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.window_background_opacity = 0.9
config.window_decorations = 'RESIZE'
config.window_padding = {
  left = '40px',
  right = '40px',
  top = '40px',
  bottom = '40px',
}

return config

