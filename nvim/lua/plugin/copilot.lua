require("copilot").setup({
	suggestion = {
		enabled = true,
		auto_trigger = true,
		debounce = 150,
		keymap = {
			accept = "<C-l>",
			accept_word = "<C-k>",
			next = "<M-]>",
			prev = "<M-[>",
			dismiss = "<C-]>",
		},
	},
	panel = { enabled = false },
	filetypes = {
		["*"] = true,
	},
})
