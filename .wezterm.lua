local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.color_scheme = "catppuccin-mocha"
config.font_size = 14.5

config.enable_tab_bar = false
config.enable_scroll_bar = false

config.font = wezterm.font("JetBrainsMono Nerd Font")

config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

return config
