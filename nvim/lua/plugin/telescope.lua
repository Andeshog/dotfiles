vim.cmd.packadd("telescope-fzf-native.nvim")
vim.cmd.packadd("telescope-ui-select.nvim")

-- Check if the fzf extension is installed and build it if necessary
local fzf_path = vim.fn.globpath(vim.o.packpath, "pack/*/opt/telescope-fzf-native.nvim", false, true)[1]
if fzf_path and vim.fn.filereadable(fzf_path .. "/build/libfzf.so") == 0 then
	vim.fn.system({ "make", "-C", fzf_path })
end

local telescope = require("telescope")
local lga_actions = require("telescope-live-grep-args.actions")
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

telescope.load_extension("fzf")
telescope.load_extension("ui-select")
telescope.load_extension("live_grep_args")

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
