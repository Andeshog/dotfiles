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
require("plugin.lualine")
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
require("gitlineage").setup()
require("inlinediff").setup({
	colors = {
		InlineDiffAddContext = "#283e00",
		InlineDiffAddChange = "#507800",
		InlineDiffDeleteContext = "#3e0008",
		InlineDiffDeleteChange = "#78000a",
	},
})
require("neogit").setup({})

vim.cmd.colorscheme("catppuccin")
-- TODO: Be able to toggle underlay and ghost text via keymap
vim.diagnostic.config({
	virtual_text = false,
	virtual_lines = { current_line = true },
	signs = true,
	underline = true,
	severity_sort = true,
	float = {
		border = "rounded",
		source = "if_many",
	},
})

vim.lsp.enable({ "clangd" })
