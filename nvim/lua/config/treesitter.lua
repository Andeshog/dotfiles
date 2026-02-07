local ts = require("nvim-treesitter.configs")

ts.setup({
	ensure_installed = { "c", "cpp", "lua", "vimdoc", "python" },
	highlight = { enable = true },
	indent = { enable = true },
})
