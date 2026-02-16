require("neo-tree").setup({
	close_if_last_window = true,
	popup_border_style = "rounded",
	enable_git_status = true,
	enable_diagnostics = true,

	default_component_configs = {
		name = {
			use_git_status_colors = true,
			highlight = "NeoTreeFileName",
		},
		git_status = {
			symbols = {
				added = "",
				modified = "",
				deleted = "",
				renamed = "",
				untracked = "",
				ignored = "",
				unstaged = "",
				staged = "",
				conflict = "",
			},
		},
	},

	filesystem = {
		filtered_items = {
			hide_dotfiles = false, -- show dotfiles
			hide_gitignored = true,
			hide_by_name = {
				"node_modules",
			},
			hide_by_pattern = {
				"**/.git/*",
			},
		},
		follow_current_file = {
			enabled = true, -- sync with current file
		},
		hijack_netrw_behavior = "disabled", -- replace netrw

		window = {
			mappings = {
				["u"] = "navigate_up", -- go to parent dir
				["."] = "set_root", -- set root to dir under cursor
			},
		},
	},

	window = {
		position = "float",
		mappings = {
			["<space>"] = "none", -- free <space> for leader
		},
	},
})
