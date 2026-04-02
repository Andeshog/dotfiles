require("termite").setup({
	height = 0.40,
	position = "bottom",
	border = "light",
	winbar = false,
	shell = "/bin/bash",
	keymaps = {
		next = "<C-l>",
		prev = "<C-h>",
	},
	wo = {
		signcolumn = "yes:1",
		winhighlight = table.concat({
			"NormalFloat:Normal",
			"Normal:Normal",
			"NormalNC:Normal",
		}, ","),
	},
	highlights = {
		border_single = "TermiteBorderSingle",
		border_active = "TermiteBorder",
		border_inactive = "TermiteBorderNC",
		winbar = "TermiteWinbar",
	},
})
