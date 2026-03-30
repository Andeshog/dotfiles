vim.g.mapleader = " "
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
require("plugin.lsp-keymaps")

-- Plugins with default or small config
require("fidget").setup({})
require("which-key").setup({})
require("gitsigns").setup({
	current_line_blame = true,
})
require("nvim-autopairs").setup({ fast_wrap = {}, disable_filetype = { "TelescopePrompt", "vim" } })
require("arc").setup({
	hl_backdrop = "Ignore",
	hl_label = "Search",
})

vim.cmd.colorscheme("catppuccin")

vim.lsp.enable({ "clangd" })
