vim.pack.add({
	{
		src = "https://github.com/nvim-neo-tree/neo-tree.nvim",
		version = vim.version.range("3"),
	},
	-- dependencies
	"https://github.com/nvim-lua/plenary.nvim",
	"https://github.com/MunifTanjim/nui.nvim",
	"https://github.com/nvim-tree/nvim-web-devicons",

	{ src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
	{ src = "https://github.com/folke/which-key.nvim", name = "which-key" },
	--Navigation
	{ src = "https://github.com/matze/vim-move", name = "vim-move" },
	{ src = "https://codeberg.org/knight9114/arc.nvim", name = "arc" },
	-- Editing
	{ src = "https://github.com/windwp/nvim-autopairs", name = "nvim-autopairs" },
	{ src = "https://github.com/tpope/vim-surround", name = "vim-surround" },
	-- UI
	{ src = "https://github.com/luukvbaal/statuscol.nvim", name = "statuscol" },
	{ src = "https://github.com/lukas-reineke/indent-blankline.nvim", name = "indent-blankline" },
	{ src = "https://github.com/j-hui/fidget.nvim", name = "fidget" },
	-- Git
	{ src = "https://github.com/lewis6991/gitsigns.nvim", name = "gitsigns" },
})
