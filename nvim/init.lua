vim.g.mapleader = " "
vim.g.maplocalleader = ","
require("options")
require("keymaps")
require("autocmds")
require("plugins")

--Plugins with config
require("plugin.neo-tree")
require("plugin.catppuccin")
require("plugin.treesitter")
require("plugin.statuscol")
require("plugin.indent_blankline")
require("plugin.telescope")
require("plugin.lsp-keymaps")

-- Plugins with default or small config
require("fidget").setup({})
require("which-key").setup({
	delay = 800, -- ms before which-key popup shows
})
require("gitsigns").setup({
	current_line_blame = true,
})
require("nvim-autopairs").setup({ fast_wrap = {}, disable_filetype = { "TelescopePrompt", "vim" } })
require("arc").setup({
	hl_backdrop = "Ignore",
	hl_label = "Search",
})
require("treewalker").setup({})
require("termite").setup({ height = 0.25, position = "bottom", border = "double", winbar = false, shell = "/bin/bash" })
require("zen-mode").setup({
	window = {
		width = 0.8,
	},
})
require("grug-far").setup({})
require("trouble").setup({ focus = true })

vim.cmd.colorscheme("catppuccin")

vim.diagnostic.config({
	virtual_text = {
		prefix = "●",
		source = "if_many",
	},
	signs = true,
	underline = true,
	update_in_insert = true,
	severity_sort = true,
})

vim.lsp.enable({ "clangd" })
