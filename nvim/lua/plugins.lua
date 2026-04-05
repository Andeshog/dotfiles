vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(ev)
		local name = ev.data.spec.name
		local kind = ev.data.kind

		if name == "nvim-treesitter" and kind == "update" then
			if not ev.data.active then
				vim.cmd.packadd("nvim-treesitter")
			end
			vim.cmd("TSUpdate")
		end

		if name == "mason.nvim" and kind == "update" then
			if not ev.data.active then
				vim.cmd.packadd("mason.nvim")
			end
			vim.cmd("MasonUpdate")
		end

		if name == "telescope-fzf-native.nvim" and (kind == "install" or kind == "update") then
			local path = vim.fs.find("telescope-fzf-native.nvim", {
				path = vim.fn.stdpath("data") .. "/site/pack",
				type = "directory",
			})[1]
			if path then
				vim.fn.system({ "make", "-C", path })
			end
		end

		if name == "blink.cmp" and (kind == "install" or kind == "update") then
			local path = vim.fs.find("blink.cmp", {
				path = vim.fn.stdpath("data") .. "/site/pack",
				type = "directory",
			})[1]
			if path and vim.fn.executable("cargo") == 1 then
				vim.system({ "cargo", "build", "--release" }, { cwd = path }):wait()
			end
		end
	end,
})

vim.pack.add({
	{ src = "https://github.com/nvim-neo-tree/neo-tree.nvim", version = vim.version.range("3") },
	-- dependencies
	"https://github.com/nvim-lua/plenary.nvim",
	"https://github.com/MunifTanjim/nui.nvim",
	"https://github.com/nvim-tree/nvim-web-devicons",

	{ src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
	{ src = "https://github.com/folke/which-key.nvim", name = "which-key" },
	--Navigation and files
	{ src = "https://github.com/matze/vim-move", name = "vim-move" },
	{ src = "https://codeberg.org/knight9114/arc.nvim", name = "arc" },
	{ src = "https://github.com/aaronik/treewalker.nvim", name = "treewalker" },
	{ src = "https://github.com/nvim-telescope/telescope.nvim", name = "telescope" },
	{ src = "https://github.com/nvim-telescope/telescope-fzf-native.nvim", name = "telescope-fzf-native" },
	{ src = "https://github.com/nvim-telescope/telescope-live-grep-args.nvim", name = "telescope-live-grep-args" },
	{ src = "https://github.com/nvim-telescope/telescope-ui-select.nvim", name = "telescope-ui-select.nvim" },
	{ src = "https://github.com/rmagatti/auto-session", name = "auto-session" },
	{ src = "https://github.com/williamboman/mason.nvim", name = "mason.nvim" },
	-- Editing
	{ src = "https://github.com/windwp/nvim-autopairs", name = "nvim-autopairs" },
	{ src = "https://github.com/tpope/vim-surround", name = "vim-surround" },
	{ src = "https://github.com/MagicDuck/grug-far.nvim", name = "grug-far" },
	{ src = "https://github.com/mg979/vim-visual-multi", name = "vim-visual-multi" },
	{ src = "https://github.com/Sang-it/fluoride", name = "fluoride" },
	{ src = "https://github.com/stevearc/conform.nvim", name = "conform" },
	{ src = "https://github.com/mfussenegger/nvim-lint", name = "nvim-lint" },
	-- UI
	{ src = "https://github.com/luukvbaal/statuscol.nvim", name = "statuscol" },
	{ src = "https://github.com/lukas-reineke/indent-blankline.nvim", name = "indent-blankline" },
	{ src = "https://github.com/folke/zen-mode.nvim", name = "zen-mode" },
	{ src = "https://github.com/nvim-lualine/lualine.nvim", name = "lualine" },
	{ src = "https://github.com/Saghen/blink.cmp", name = "blink.cmp", version = vim.version.range("1") },
	-- Git
	{ src = "https://github.com/lewis6991/gitsigns.nvim", name = "gitsigns" },
	{ src = "https://github.com/NeogitOrg/neogit", name = "neogit" },
	{ src = "https://github.com/sindrets/diffview.nvim", name = "diffview" },
	{ src = "https://github.com/lionyxml/gitlineage.nvim", name = "gitlineage" },
	{ src = "https://github.com/YouSame2/inlinediff-nvim", name = "inlinediff" },
	-- Misc
	{ src = "https://github.com/ruicsh/termite.nvim", name = "termite" },
	-- Markdown
	{ src = "https://github.com/MeanderingProgrammer/render-markdown.nvim", name = "render-markdown" },
	-- AI/Copilot
	{ src = "https://github.com/zbirenbaum/copilot.lua", name = "copilot.lua" },
	{ src = "https://github.com/olimorris/codecompanion.nvim", name = "codecompanion" },
	-- DAP
	{ src = "https://github.com/mfussenegger/nvim-dap", name = "nvim-dap" },
	{ src = "https://github.com/igorlfs/nvim-dap-view", name = "dap-view" },
	{ src = "https://github.com/theHamsta/nvim-dap-virtual-text", name = "nvim-dap-virtual-text" },
	-- Testing
	{ src = "https://github.com/nvim-neotest/neotest", name = "neotest" },
	{ src = "https://github.com/nvim-neotest/nvim-nio", name = "nvim-nio" },
	{ src = "https://github.com/Andeshog/neotest-gtest", name = "neotest-gtest" },
	{ src = "https://github.com/fredrikaverpil/neotest-golang", name = "neotest-golang" },
})
