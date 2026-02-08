local ts = require("nvim-treesitter.configs")

ts.setup({
	ensure_installed = {
		"c",
		"cpp",
		"lua",
		"vimdoc",
		"python",
		"cmake",
		"make",
		"bash",
		"json",
		"yaml",
		"markdown",
		"markdown_inline",
		"diff",
		"comment",
		"regex",
	},
	highlight = { enable = true },
	indent = { enable = true },
	auto_install = true,
})
