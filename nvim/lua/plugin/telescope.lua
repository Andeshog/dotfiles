local telescope = require("telescope")
local themes = require("telescope.themes")

telescope.setup({
	defaults = {
		sorting_strategy = "ascending",
		layout_config = {
			horizontal = { prompt_position = "top" },
		},
	},
	extensions = {
		fzf = {
			fuzzy = true,
			override_generic_sorter = true,
			override_file_sorter = true,
			case_mode = "smart_case",
		},
		["ui-select"] = themes.get_dropdown({
			previewer = false,
		}),
		live_grep_args = {
			auto_quoting = false,
		},
	},
})

for _, extension in ipairs({ "fzf", "ui-select", "live_grep_args" }) do
	pcall(telescope.load_extension, extension)
end

local builtin = require("telescope.builtin")
local lga = require("telescope-live-grep-args.shortcuts")

vim.keymap.set("n", "<leader>fg", function()
	require("telescope").extensions.live_grep_args.live_grep_args()
end, { desc = "Live grep (with args)" })
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "Diagnostics" })
vim.keymap.set("n", "<leader>fr", builtin.resume, { desc = "Resume last picker" })
vim.keymap.set("n", "<leader>fw", lga.grep_word_under_cursor, { desc = "Grep word under cursor" })
vim.keymap.set("n", "<leader>fs", builtin.lsp_document_symbols, { desc = "Document symbols" })
vim.keymap.set("n", "<leader>fS", builtin.lsp_workspace_symbols, { desc = "Workspace symbols" })
