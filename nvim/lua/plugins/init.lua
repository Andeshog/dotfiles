-- ~/.config/nvim/lua/plugins/init.lua
return {
	----------------------------------------------------------
	---------------------- Colorschemes ----------------------
	----------------------------------------------------------
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = false,
		priority = 1000,
		config = function()
			require("colorschemes.catppuccin").setup()
		end,
	},

	----------------------------------------------------------
	--------------------- Core Dependencies ------------------
	----------------------------------------------------------

	"nvim-lua/plenary.nvim",
	"nvim-tree/nvim-web-devicons",
	"MunifTanjim/nui.nvim",

	----------------------------------------------------------
	--------------------- UI Enhancements --------------------
	----------------------------------------------------------

	{
		"luukvbaal/statuscol.nvim",
		config = function()
			local builtin = require("statuscol.builtin")
			require("statuscol").setup({
				relculright = true,
				segments = {
					-- Git signs (gitsigns) in a separate column
					{
						sign = { namespace = { "gitsigns" }, maxwidth = 1, colwidth = 1 },
						click = "v:lua.ScSa",
					},
					-- Line numbers
					{
						text = { builtin.lnumfunc, " " },
						click = "v:lua.ScLa",
					},
				},
			})
		end,
	},

	{
		"rcarriga/nvim-notify",
		config = function()
			vim.notify = require("notify")
		end,
	},

	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		event = { "BufReadPost", "BufNewFile" },

		opts = {
			indent = {
				char = "│",
			},
			scope = {
				enabled = true,
				show_start = true,
				show_end = false,
			},
			exclude = {
				filetypes = { "dashboard" },
			},
		},

		config = function(_, opts)
			local hooks = require("ibl.hooks")
			hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_space_indent_level)
			require("ibl").setup(opts)
		end,
	},

	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {},
	},

	{
		"nvim-lualine/lualine.nvim",
		lazy = false,
		priority = 900,
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			vim.api.nvim_create_autocmd("UIEnter", {
				callback = function()
					require("config.lualine").setup()
				end,
				once = true,
			})
		end,
	},

	{
		"nvimdev/dashboard-nvim",
		lazy = false,
		dependencies = { "nvim-tree/nvim-web-devicons" },
		init = function()
			local argc = vim.fn.argc()

			-- If launched with exactly one argument and it's a directory:
			-- cd into it, remove it from the arglist, then show dashboard.
			if argc == 1 then
				local arg0 = vim.fn.argv(0)
				if vim.fn.isdirectory(arg0) == 1 then
					local dir = vim.fn.fnamemodify(arg0, ":p"):gsub("/+$", "")
					vim.cmd("cd " .. vim.fn.fnameescape(dir))
					vim.cmd("argdelete *") -- prevent file explorers/netrw from taking over

					vim.api.nvim_create_autocmd("VimEnter", {
						once = true,
						callback = function()
							pcall(vim.cmd, "Dashboard")
						end,
					})

					return
				end
			end

			-- If launched with NO args: show dashboard
			if argc == 0 then
				vim.api.nvim_create_autocmd("VimEnter", {
					once = true,
					callback = function()
						pcall(vim.cmd, "Dashboard")
					end,
				})
			end

			-- If launched with FILE args: do nothing (let the file open normally)
		end,
		config = function()
			require("config.dashboard").setup()
		end,
	},

	{
		"folke/zen-mode.nvim",
		opts = {},
	},

	----------------------------------------------------------
	------------- Navigation & File Management ---------------
	----------------------------------------------------------

	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
		},
		config = function()
			require("config.neotree")
		end,
	},

	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"debugloop/telescope-undo.nvim",
			"nvim-telescope/telescope-frecency.nvim",
			"nvim-telescope/telescope-file-browser.nvim",
			"jonarrien/telescope-cmdline.nvim",
			"fbuchlak/telescope-directory.nvim",
			"nvim-telescope/telescope-live-grep-args.nvim",
		},
		config = function()
			require("config.telescope").setup()
		end,
	},

	{
		"rmagatti/goto-preview",
		dependencies = { "rmagatti/logger.nvim" },
		event = "BufEnter",
		config = true, -- necessary as per https://github.com/rmagatti/goto-preview/issues/88
	},

	{
		"aaronik/treewalker.nvim",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("treewalker").setup({})
		end,
	},

	"matze/vim-move",

	{
		"https://codeberg.org/knight9114/arc.nvim",
		opts = {
			hl_backdrop = "Ignore",
			hl_label = "Search",
		},
	},

	{
		"rmagatti/auto-session",
		lazy = false,
		keys = {
			{ "<leader>wr", "<cmd>AutoSession search<CR>", desc = "Session search" },
			{ "<leader>wS", "<cmd>AutoSession save<CR>", desc = "Save session" },
			{ "<leader>wa", "<cmd>AutoSession toggle<CR>", desc = "Toggle autosave" },
		},
		opts = {
			bypass_save_filetypes = { "dashboard" },
		},
	},

	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local harpoon = require("harpoon")
			harpoon:setup()

			vim.keymap.set("n", "<leader>h", "<nop>", { desc = "Harpoon" })
			-- Add file to harpoon
			vim.keymap.set("n", "<leader>ha", function()
				harpoon:list():add()
			end, { desc = " add file" })

			-- Toggle quick menu
			vim.keymap.set("n", "<leader>he", function()
				harpoon.ui:toggle_quick_menu(harpoon:list())
			end, { desc = " quick menu" })

			-- Navigate to files 1-4
			vim.keymap.set("n", "<leader>hh", function()
				harpoon:list():select(1)
			end, { desc = "select file 1" })
			vim.keymap.set("n", "<leader>hj", function()
				harpoon:list():select(2)
			end, { desc = "select file 2" })
			vim.keymap.set("n", "<leader>hk", function()
				harpoon:list():select(3)
			end, { desc = "select file 3" })
			vim.keymap.set("n", "<leader>hl", function()
				harpoon:list():select(4)
			end, { desc = "select file 4" })

			-- Cycle through files
			-- TODO: set these
			vim.keymap.set("n", "<C-S-P>", function()
				harpoon:list():prev()
			end)
			vim.keymap.set("n", "<C-S-N>", function()
				harpoon:list():next()
			end)
		end,
	},

	{
		"ruicsh/termite.nvim",
		opts = {
			height = 0.25,
			position = "bottom",
			border = "double",
			winbar = false,
		},
	},

	----------------------------------------------------------
	--------------- Editing & Text Manipulation --------------
	----------------------------------------------------------

	"tpope/vim-surround",

	{
		"numToStr/Comment.nvim",
		opts = {
			mappings = {
				basic = true,
				extra = false,
			},
		},
	},

	{
		"mg979/vim-visual-multi",
		branch = "master",
		init = function()
			vim.g.VM_mouse_mappings = 1
			vim.g.VM_theme = "iceblue"
		end,
	},

	"famiu/bufdelete.nvim",

	{
		"nvim-pack/nvim-spectre",
		dependencies = { "nvim-lua/plenary.nvim" },
		cmd = "Spectre",
		config = function()
			require("spectre").setup({
				live_update = true,
				highlight = {
					search = "SpectreSearch",
					replace = "SpectreReplace",
				},
			})
		end,
	},

	{
		"Sang-it/fluoride",
		config = function()
			require("fluoride").setup()
		end,
	},

	----------------------------------------------------------
	------------------- Git Integration ----------------------
	----------------------------------------------------------

	"tpope/vim-fugitive",

	{
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup({
				current_line_blame = true,
			})
		end,
	},

	{
		"NeogitOrg/neogit",
		lazy = true,
		dependencies = {
			"nvim-lua/plenary.nvim", -- required
			"sindrets/diffview.nvim", -- optional - Diff integration

			-- Only one of these is needed.
			"nvim-telescope/telescope.nvim", -- optional
			--"ibhagwan/fzf-lua", -- optional
			--"nvim-mini/mini.pick", -- optional
			--"folke/snacks.nvim", -- optional
		},
		cmd = "Neogit",
	},

	{
		"lionyxml/gitlineage.nvim",
		dependencies = {
			"sindrets/diffview.nvim",
		},
		event = "BufEnter",
		config = function()
			require("gitlineage").setup()
		end,
	},

	{
		"YouSame2/inlinediff-nvim",
		lazy = true,
		cmd = "InlineDiff",
		opts = {
			colors = {
				InlineDiffAddContext = "#283e00",
				InlineDiffAddChange = "#507800",
				InlineDiffDeleteContext = "#3e0008",
				InlineDiffDeleteChange = "#78000a",
			},
		},
		keys = {
			{
				"<leader>gd",
				function()
					require("inlinediff").toggle()
				end,
				desc = "Toggle inline diff",
			},
		},
	},

	----------------------------------------------------------
	-------------------- Treesitter --------------------------
	----------------------------------------------------------

	{
		"nvim-treesitter/nvim-treesitter",
		branch = "master",
		build = ":TSUpdate",
		config = function()
			require("config.treesitter")
		end,
	},

	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
	},

	{
		"nvim-treesitter/nvim-treesitter-context",
		config = function()
			require("treesitter-context").setup({
				max_lines = 1,
				multiline_threshold = 4,
				mode = "cursor",
				trim_scope = "outer",
			})
		end,
	},

	----------------------------------------------------------
	----------------- LSP &  Completion ----------------------
	----------------------------------------------------------

	{
		"williamboman/mason.nvim",
		build = ":MasonUpdate",
		config = function()
			require("mason").setup()
		end,
	},

	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = {
			"williamboman/mason.nvim",
			"neovim/nvim-lspconfig",
		},
		config = function()
			local mason_lspconfig = require("mason-lspconfig")

			mason_lspconfig.setup({
				ensure_installed = {
					"clangd",
					-- "gopls",
					"pyright",
					"bashls",
				},
				automatic_installation = true,
			})
		end,
	},

	{
		"neovim/nvim-lspconfig",
		config = function()
			require("config.lspconfig")
		end,
	},

	{
		"SmiteshP/nvim-navic",
		dependencies = { "neovim/nvim-lspconfig" },
		opts = {
			highlight = true,
			separator = " > ",
		},
	},

	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			{
				"L3MON4D3/LuaSnip",
				dependencies = "rafamadriz/friendly-snippets",
				opts = { history = true, updateevents = "TextChanged,TextChangedI" },
				config = function(_, opts)
					require("luasnip").config.set_config(opts)
					require("config.luasnip")
				end,
			},
			{
				"windwp/nvim-autopairs",
				opts = {
					fast_wrap = {},
					disable_filetype = { "TelescopePrompt", "vim" },
				},
				config = function(_, opts)
					require("nvim-autopairs").setup(opts)
					local cmp_autopairs = require("nvim-autopairs.completion.cmp")
					require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done())
				end,
			},
			{
				"saadparwaiz1/cmp_luasnip",
				"hrsh7th/cmp-nvim-lua",
				"hrsh7th/cmp-nvim-lsp",
				"hrsh7th/cmp-buffer",
				"hrsh7th/cmp-nvim-lsp-signature-help",
				--"https://codeberg.org/FelipeLema/cmp-async-path.git",
			},
		},
		opts = function()
			return require("config.cmp")
		end,
	},

	{
		"j-hui/fidget.nvim",
		tag = "legacy",
		event = "LspAttach",
		opts = {
			-- LSP progress settings (mostly defaults)
			progress = {
				suppress_on_insert = false,
			},

			-- Notification window (where the little box lives)
			notification = {
				window = {
					normal_hl = "Comment",
					winblend = 0, -- no transparency (easier to read)
					border = "none",
					zindex = 45,

					-- >>> placement bits <<<
					relative = "editor", -- position relative to the whole editor
					align = "bottom", -- stick to bottom edge
					y_padding = 0, -- 0 lines above bottom
					x_padding = 18, -- distance from *right* edge (16-wide minimap + 2 cols gap)
					-- if you want it tighter / further, tweak this number
				},
			},
		},
	},

	{
		"danymat/neogen",
		dependencies = "nvim-treesitter/nvim-treesitter",
		opts = {
			snippet_engine = "luasnip",
			languages = {
				cpp = {
					template = {
						annotation_convention = "doxygen",
					},
				},
				c = {
					template = {
						annotation_convention = "doxygen",
					},
				},
			},
		},
		keys = {
			{
				"<leader>ng",
				function()
					require("neogen").generate()
				end,
				desc = "Generate doc comment",
			},
			{
				"<leader>nf",
				function()
					require("neogen").generate({ type = "func" })
				end,
				desc = "Generate function doc",
			},
			{
				"<leader>nc",
				function()
					require("neogen").generate({ type = "class" })
				end,
				desc = "Generate class doc",
			},
			{
				"<leader>nt",
				function()
					require("neogen").generate({ type = "type" })
				end,
				desc = "Generate type doc",
			},
			{
				"<leader>nF",
				function()
					require("neogen").generate({ type = "file" })
				end,
				desc = "Generate file doc",
			},
		},
	},

	----------------------------------------------------------
	--------------------- Debugging --------------------------
	----------------------------------------------------------

	{
		"jay-babu/mason-nvim-dap.nvim",
		dependencies = { "williamboman/mason.nvim" },
		config = function()
			require("mason-nvim-dap").setup({
				ensure_installed = { "codelldb" },
			})
		end,
	},

	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"igorlfs/nvim-dap-view",
			"theHamsta/nvim-dap-virtual-text",
		},
		config = function()
			require("config.dap")
		end,
	},

	----------------------------------------------------------
	---------------------- Testing ---------------------------
	----------------------------------------------------------

	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-neotest/nvim-nio",
			"nvim-lua/plenary.nvim",
			"antoinemadec/FixCursorHold.nvim",
			"nvim-treesitter/nvim-treesitter",
			"alfaix/neotest-gtest",
			"fredrikaverpil/neotest-golang",
			"nvim-neotest/neotest-python",
		},
		config = function()
			require("config.neotest")
		end,
	},

	----------------------------------------------------------
	----------------- Linting & Formatting -------------------
	----------------------------------------------------------

	-- Linter
	{
		"mfussenegger/nvim-lint",
		config = function()
			local lint = require("lint")
			local parser = require("lint.parser")
			local has_zb = vim.fn.executable("zb_flake8") == 1
				and vim.fn.executable("zb_mypy") == 1
				and vim.fn.executable("zb_yamllint") == 1
				and vim.fn.executable("zb_pep257") == 1

			if not has_zb then
				return
			end

			lint.linters.zb_flake8 = {
				cmd = "zb_flake8",
				stdin = false,
				append_fname = true,
				args = {},
				ignore_exitcode = true,

				parser = parser.from_errorformat("%f:%l:%c: %m", {
					severity = vim.diagnostic.severity.WARN,
					source = "zb_flake8",
				}),
			}

			lint.linters.zb_mypy = {
				cmd = "zb_mypy",
				stdin = false,
				append_fname = true,
				args = {},
				ignore_exitcode = true,
				parser = parser.from_errorformat("%f:%l: %m", {
					severity = vim.diagnostic.severity.WARN,
					source = "zb_mypy",
				}),
			}
			lint.linters.zb_yamllint = {
				cmd = "zb_yamllint",
				stdin = false,
				append_fname = true,
				args = {},
				ignore_exitcode = true,
				parser = parser.from_errorformat("%f:%l:%c: %m", {
					severity = vim.diagnostic.severity.WARN,
					source = "zb_yamllint",
				}),
			}
			lint.linters.zb_pep257 = {
				cmd = "zb_pep257",
				stdin = false,
				append_fname = true,
				args = {},
				ignore_exitcode = true,
				parser = parser.from_errorformat("%f:%l: %m", {
					severity = vim.diagnostic.severity.WARN,
					source = "zb_pep257",
				}),
			}
			lint.linters_by_ft = {
				python = { "zb_flake8", "zb_mypy", "zb_pep257" },
				yaml = { "zb_yamllint" },
				sh = { "shellcheck" },
			}

			vim.api.nvim_create_autocmd("BufWritePost", {
				callback = function()
					require("lint").try_lint()
				end,
			})
		end,
	},

	-- Formatter
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre", "BufReadPre" },

		opts = {
			formatters_by_ft = {
				c = { "clang_format" },
				cpp = { "clang_format" },
				lua = { "stylua" },
				go = { "goimports", "gofmt" },
				sh = { "shfmt" },
				bash = { "shfmt" },
			},

			formatters = {
				clang_format = {
					command = "clang-format",
					stdin = true,
					args = function(_, ctx)
						local args = {}

						local local_cfg =
							vim.fs.find({ ".clang-format", "_clang-format" }, { path = ctx.filename, upward = true })[1]

						if local_cfg ~= nil then
							table.insert(args, "--style=file")
						else
							table.insert(args, "--style=google")
						end

						table.insert(args, "--assume-filename")
						table.insert(args, ctx.filename)

						return args
					end,
				},
			},

			format_on_save = function(bufnr)
				-- Skip formatting while vim-visual-multi cursors are active
				if vim.b.visual_multi then
					return
				end
				local ft = vim.bo[bufnr].filetype
				if ft == "c" or ft == "cpp" or ft == "lua" or ft == "go" or ft == "sh" then
					return { timeout_ms = 2000, lsp_fallback = (ft == "go") }
				end
				-- return nil to disable for other filetypes
			end,
		},
	},

	----------------------------------------------------------
	-------------------- Diagnostics -------------------------
	----------------------------------------------------------

	{
		"folke/todo-comments.nvim",
		event = { "BufReadPost", "BufNewFile" },
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {
			search = {
				command = "rg",
				args = {
					"--color=never",
					"--no-heading",
					"--with-filename",
					"--line-number",
					"--column",
					"--hidden",

					-- ignore build directories
					"--glob=!build",
					"--glob=!**/build/**",
				},
			},
		},
	},

	{
		"folke/trouble.nvim",
		opts = {
			focus = true,
		},
		cmd = "Trouble",
	},

	----------------------------------------------------------
	-------------------- AI/Copilot --------------------------
	----------------------------------------------------------

	{
		"github/copilot.vim",
		event = "BufReadPre",
		config = function()
			vim.g.copilot_no_tab_map = true
			vim.g.copilot_assume_mapped = true
			vim.g.copilot_idle_delay = 150
			vim.g.copilot_filetypes = {
				["*"] = true,
			}

			vim.keymap.set("i", "<C-l>", 'copilot#Accept("\\<CR>")', {
				silent = true,
				expr = true,
				replace_keycodes = false,
			})
			vim.keymap.set("i", "<C-k>", "<Plug>(copilot-accept-word)")

			vim.keymap.set("i", "<M-]>", "<Plug>(copilot-next)", { silent = true })
			vim.keymap.set("i", "<M-[>", "<Plug>(copilot-previous)", { silent = true })
			vim.keymap.set("i", "<C-]>", "<Plug>(copilot-dismiss)", { silent = true })
		end,
	},

	{
		"coder/claudecode.nvim",
		dependencies = { "folke/snacks.nvim" },
		config = function()
			require("claudecode").setup()
		end,
	},

	{
		"folke/sidekick.nvim",
		event = "VeryLazy",
		dependencies = { "folke/snacks.nvim" },
		opts = {
			cli = {
				win = {
					-- Clear winhighlight so catppuccin dim_inactive works correctly.
					-- Default is "Normal:SidekickChat,NormalNC:SidekickChat" which
					-- maps both states to the same group, preventing dimming.
					wo = { winhighlight = "" },
				},
				tools = {
					copilot = {
						cmd = { "copilot", "--alt-screen" },
					},
				},
			},
		},
		keys = {
			{
				"<tab>",
				function()
					if not require("sidekick").nes_jump_or_apply() then
						return "<Tab>"
					end
				end,
				expr = true,
				desc = "Goto/Apply Next Edit Suggestion",
			},
			{
				"<c-.>",
				function()
					require("sidekick.cli").toggle()
				end,
				desc = "Sidekick Toggle",
				mode = { "n", "t", "i", "x" },
			},
			{
				"<leader>aa",
				function()
					require("sidekick.cli").toggle()
				end,
				desc = "Sidekick Toggle CLI",
			},
			{
				"<leader>as",
				function()
					require("sidekick.cli").select()
				end,
				desc = "Sidekick Select CLI",
			},
			{
				"<leader>at",
				function()
					require("sidekick.cli").send({ msg = "{this}" })
				end,
				mode = { "x", "n" },
				desc = "Sidekick Send This",
			},
			{
				"<leader>af",
				function()
					require("sidekick.cli").send({ msg = "{file}" })
				end,
				desc = "Sidekick Send File",
			},
			{
				"<leader>av",
				function()
					require("sidekick.cli").send({ msg = "{selection}" })
				end,
				mode = { "x" },
				desc = "Sidekick Send Visual Selection",
			},
			{
				"<leader>ap",
				function()
					require("sidekick.cli").prompt()
				end,
				mode = { "n", "x" },
				desc = "Sidekick Select Prompt",
			},
			{
				"<leader>aC",
				function()
					require("sidekick.cli").toggle({ name = "copilot", focus = true })
				end,
				desc = "Sidekick Toggle Copilot",
			},
		},
	},

	----------------------------------------------------------
	---------------------- Markdown --------------------------
	----------------------------------------------------------

	{
		"MeanderingProgrammer/render-markdown.nvim",
		ft = { "markdown", "codecompanion" },
		opts = {
			render_modes = true,
			sign = { enabled = false },
		},
	},

	----------------------------------------------------------
	----------------------- Misc -----------------------------
	----------------------------------------------------------

	{
		"meatballs/notebook.nvim",
		config = function()
			require("notebook").setup()
		end,
	},

	{
		"folke/noice.nvim",
		event = "VeryLazy",
		opts = {},
		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
		},
		config = function()
			require("noice").setup({
				lsp = {
					-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
					override = {
						["vim.lsp.util.convert_input_to_markdown_lines"] = true,
						["vim.lsp.util.stylize_markdown"] = true,
						["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
					},
				},
				-- you can enable a preset for easier configuration
				presets = {
					bottom_search = true, -- use a classic bottom cmdline for search
					command_palette = true, -- position the cmdline and popupmenu together
					long_message_to_split = true, -- long messages will be sent to a split
					inc_rename = false, -- enables an input dialog for inc-rename.nvim
					lsp_doc_border = false, -- add a border to hover docs and signature help
				},
			})
		end,
	},

	----------------------------------------------------------
	---------------------- ROS2 Tools ------------------------
	----------------------------------------------------------

	{
		name = "ros2-build",
		dir = vim.fn.stdpath("config") .. "/lua/custom_plugins",
		config = function()
			require("custom_plugins.build_package").setup({
				keys = {
					build = "<leader>cb",
					test = "<leader>ct",
					close = "<leader>cc",
				},
				show_output = true,
				keep_output_on_success = true,
			})
		end,
	},

	----------------------------------------------------------
	------------------------ CMake ---------------------------
	----------------------------------------------------------

	{
		"Civitasv/cmake-tools.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {},
	},
}
