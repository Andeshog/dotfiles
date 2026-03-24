local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.default_domain = "WSL:Ubuntu-22.04"

config.font = wezterm.font("JetBrainsMonoNL Nerd Font Mono")
config.font_size = 11
config.color_scheme = "Dark+"

local act = wezterm.action

config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

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
}

return config
