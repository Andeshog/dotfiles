vim.api.nvim_set_hl(0, "TermiteBorder", { fg = "#a6d189", bold = true })
vim.api.nvim_set_hl(0, "TermiteBorderNC", { fg = "#51576d" })

require("termite").setup({
	height = 0.40,
	position = "bottom",
	border = "heavy",
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
		border_single = "TermiteBorder",
		border_active = "TermiteBorder",
		border_inactive = "TermiteBorderNC",
		winbar = "TermiteWinbar",
	},
})
