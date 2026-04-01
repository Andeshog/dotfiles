vim.g.mapleader = " "
vim.g.maplocalleader = ","

vim.cmd("packadd nvim.undotree")
vim.keymap.set("n", "<leader>u", require("undotree").open)

require("options")
require("keymaps")
require("autocmds")
require("plugins")

--Plugins with config
require("plugin.neo-tree")
require("plugin.catppuccin")
require("plugin.mason")
require("plugin.conform")
require("plugin.lint")
require("plugin.auto-session")
require("plugin.treesitter")
require("plugin.statuscol")
require("plugin.indent_blankline")
require("plugin.telescope")
require("plugin.lualine")
require("plugin.lsp-keymaps")
require("plugin.copilot")
require("plugin.dap")
require("plugin.neotest")

-- Plugins with default or small config
require("fidget").setup({
	notification = {
		override_vim_notify = true,
	},
})
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
require("fluoride").setup()

vim.cmd.colorscheme("catppuccin")
-- TODO: Be able to toggle underlay and ghost text via keymap
vim.diagnostic.config({
	virtual_text = false,
	virtual_lines = { current_line = true },
	underline = true,
	severity_sort = true,
	float = {
		border = "rounded",
		source = "if_many",
	},
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "",
			[vim.diagnostic.severity.WARN] = "",
			[vim.diagnostic.severity.INFO] = "",
			[vim.diagnostic.severity.HINT] = "",
		},
	},
})

vim.lsp.enable({ "clangd", "gopls", "bashls", "pyright" })
