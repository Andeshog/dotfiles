-- ~/.config/nvim/lua/config/telescope.lua
local M = {}

function M.setup()
	local telescope = require("telescope")
	local actions = require("telescope.actions")
	local builtin = require("telescope.builtin")

	telescope.setup({
		defaults = {
			mappings = {
				i = {
					["<Esc>"] = actions.close,
				},
				n = {
					["<Esc>"] = actions.close,
				},
			},
		},

		-- Put extension configs here; extensions you don't use can just be omitted.
		extensions = {
			undo = {
				side_by_side = true,
				layout_strategy = "vertical",
				layout_config = { preview_height = 0.8 },
			},

			-- frecency = { ... },

			cmdline = {
				output_pane = {
					enabled = true,
					min_lines = 5,
				},
			},
		},
	})

	local extensions = {
		"undo",
		"frecency",
		"file_browser",
		"cmdline",
		"directory",
		"projects",
	}

	for _, ext in ipairs(extensions) do
		pcall(telescope.load_extension, ext)
	end
end

return M
