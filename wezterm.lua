local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.default_domain = "WSL:Ubuntu-22.04"

config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 9
config.color_scheme = "Dark+"
config.enable_tab_bar = true
config.use_fancy_tab_bar = true
config.default_cursor_style = "BlinkingBar"
config.cursor_blink_rate = 400
config.cursor_thickness = "1pt"
-- config.cell_width = 0.8
-- config.line_height = 1.2

config.font_rules = {
	{
		intensity = "Bold",
		italic = false,
		font = wezterm.font("JetBrainsMono Nerd Font", { weight = "Bold" }),
	},
	{
		intensity = "Bold",
		italic = true,
		font = wezterm.font("JetBrainsMono Nerd Font", { weight = "Bold", italic = true }),
	},
	{
		intensity = "Normal",
		italic = true,
		font = wezterm.font("JetBrainsMono Nerd Font", { italic = true }),
	},
	{
		intensity = "Half",
		italic = true,
		font = wezterm.font("JetBrainsMono Nerd Font", { italic = true }),
	},
	{
		intensity = "Half",
		italic = false,
		font = wezterm.font("JetBrainsMono Nerd Font"),
	},
}

config.max_fps = 120
config.front_end = "OpenGL"
config.enable_wayland = false

local act = wezterm.action

config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

config.window_decorations = "RESIZE"

config.keys = {
	{
		key = "t",
		mods = "CTRL|SHIFT",
		action = act({ SpawnCommandInNewTab = { cwd = "~" } }),
	},

	{
		key = "R",
		mods = "CTRL|SHIFT",
		action = act.PromptInputLine({
			description = "Enter new name for tab",
			action = wezterm.action_callback(function(window, _, line)
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},

	{ key = "LeftArrow", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(-1) },
	{ key = "RightArrow", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(1) },
	{ key = "F9", mods = "CTRL|SHIFT", action = act.ShowTabNavigator },
	{ key = "v", mods = "CTRL", action = act.PasteFrom("Clipboard") },
	{ key = "C", mods = "CTRL", action = act.CopyTo("ClipboardAndPrimarySelection") },
	{ key = "q", mods = "CTRL|SHIFT", action = wezterm.action.QuitApplication },
	{
		key = "b",
		mods = "CTRL|SHIFT",
		action = wezterm.action_callback(function(window)
			local overrides = window:get_config_overrides() or {}
			if overrides.enable_tab_bar == false then
				overrides.enable_tab_bar = true
			else
				overrides.enable_tab_bar = false
			end
			window:set_config_overrides(overrides)
		end),
	},
}

return config
