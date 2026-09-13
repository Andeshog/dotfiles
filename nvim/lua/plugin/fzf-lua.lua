local fzf = require("fzf-lua")

fzf.setup({
	winopts = {
		preview = {
			layout = "horizontal",
		},
	},
})

fzf.register_ui_select({
	winopts = {
		width = 0.5,
		height = 0.4,
		preview = { hidden = true },
	},
})

local function after_terminal_mode(fn, tries)
	if vim.api.nvim_get_mode().mode ~= "t" or tries == 0 then
		return fn()
	end
	vim.api.nvim_input("<C-\\><C-n>")
	vim.defer_fn(function()
		after_terminal_mode(fn, tries - 1)
	end, 10)
end

local fzf_select = vim.ui.select
vim.ui.select = function(items, opts, on_choice)
	return fzf_select(items, opts, function(...)
		local n, args = select("#", ...), { ... }
		after_terminal_mode(function()
			on_choice(unpack(args, 1, n))
		end, 20)
	end)
end

vim.keymap.set("n", "<leader>ff", fzf.files, { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", fzf.live_grep, { desc = "Live grep" })
vim.keymap.set("n", "<leader>fw", fzf.grep_cword, { desc = "Grep word under cursor" })
vim.keymap.set("n", "<leader>fb", fzf.buffers, { desc = "Buffers" })
vim.keymap.set("n", "<leader>fo", fzf.oldfiles, { desc = "Recent files" })
vim.keymap.set("n", "<leader>f/", fzf.blines, { desc = "Search in buffer" })
vim.keymap.set("n", "<leader>fq", fzf.quickfix, { desc = "Quickfix list" })
vim.keymap.set("n", "<leader>fk", fzf.keymaps, { desc = "Keymaps" })
vim.keymap.set("n", "<leader>fs", fzf.lsp_document_symbols, { desc = "Document symbols" })
vim.keymap.set("n", "<leader>fr", fzf.resume, { desc = "Resume last picker" })
