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

local fzf_select = vim.ui.select
vim.ui.select = function(items, opts, on_choice)
	return fzf_select(items, opts, function(...)
		local n, args = select("#", ...), { ... }
		vim.schedule(function()
			if vim.api.nvim_get_mode().mode == "t" then
				vim.cmd("stopinsert")
			end
			on_choice(unpack(args, 1, n))
		end)
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
