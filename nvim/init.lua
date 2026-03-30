vim.g.mapleader = " "
require("options")
require("keymaps")
require("autocmds")
require("plugins")

--Plugins
require("plugin.neo-tree")
require("plugin.catppuccin")
require("plugin.treesitter")
require("plugin.lsp-keymaps")

require("fidget").setup({})

vim.cmd.colorscheme("catppuccin")

vim.lsp.enable({ "clangd" })
