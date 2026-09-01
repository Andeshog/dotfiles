require("copilot").setup({
	suggestion = {
		enabled = true,
		auto_trigger = true,
		debounce = 150,
		keymap = {
			accept = "<C-l>",
			accept_word = "<M-l>",
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
