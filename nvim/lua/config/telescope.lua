-- ~/.config/nvim/lua/config/telescope.lua
local M = {}

local function grep_in_directory(prompt_bufnr)
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")
	local current_input = action_state.get_current_line()
	actions.close(prompt_bufnr)

	require("telescope").extensions.directory.directory({
		attach_mappings = function(dir_prompt_bufnr)
			actions.select_default:replace(function()
				local entry = action_state.get_selected_entry()
				actions.close(dir_prompt_bufnr)
				if entry then
					require("telescope.builtin").live_grep({
						search_dirs = { entry.value or entry[1] },
					})
					vim.defer_fn(function()
						vim.api.nvim_feedkeys(current_input, "i", false)
					end, 50)
				end
			end)
			return true
		end,
	})
end

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

		pickers = {
			live_grep = {
				mappings = {
					i = {
						["<C-f>"] = grep_in_directory,
					},
					n = {
						["<C-f>"] = grep_in_directory,
					},
				},
			},
			buffers = {
				sort_mru = true,
				mappings = {
					i = {
						["<C-d>"] = actions.delete_buffer,
					},
					n = {
						["d"] = actions.delete_buffer,
					},
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
