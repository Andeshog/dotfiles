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

	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("colorschemes.tokyonight").setup()
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
		"stevearc/dressing.nvim",
		event = "VeryLazy",
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
		"Isrothy/neominimap.nvim",
		version = "v3.*", -- follow v3 releases
		lazy = false, -- recommended by the plugin author
		init = function()
			-- Recommended when using layout = "float"
			vim.opt.wrap = false
			vim.opt.sidescrolloff = 36

			---@type Neominimap.UserConfig
			vim.g.neominimap = {
				-- Show minimap by default
				auto_enable = false,

				-- VSCode-like behavior: floating window on the right of each window
				layout = "float",

				-- Don't show minimap for these filetypes
				exclude_filetypes = {
					"help",
					"neo-tree",
					"NvimTree",
					"TelescopePrompt",
					"Trouble",
					"gitcommit",
				},

				-- Don't show minimap for these buftypes
				exclude_buftypes = {
					"nofile",
					"nowrite",
					"quickfix",
					"terminal",
					"prompt",
				},

				-- Floating minimap settings
				float = {
					minimap_width = 16, -- a bit slimmer than default 20
					max_minimap_height = nil, -- no vertical limit
					margin = {
						right = 0, -- stick to the right edge
						top = 0,
						bottom = 0,
					},
					z_index = 1,
					window_border = "single",
					persist = true,
				},

				-- show whole file (current line at its % in the file)
				current_line_position = "percent",

				-- Compression (how much code is squashed into the minimap)
				x_multiplier = 4,
				y_multiplier = 1,

				sync_cursor = true,
				click = {
					enabled = true,
					auto_switch_focus = false,
				},

				-- Enable diagnostics / git / search / treesitter, like VSCode’s minimap
				diagnostic = {
					enabled = true,
					mode = "icon",
				},
				git = {
					enabled = true,
					mode = "sign",
					priority = 6,
					icon = {
						add = "+",
						change = "~",
						delete = "-",
					},
				},
				search = {
					enabled = true,
					mode = "line",
				},
				treesitter = {
					enabled = true,
					priority = 200,
				},

				fold = {
					enabled = true,
				},
			}
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
			"rcarriga/nvim-dap-ui",
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
		event = "VeryLazy",
		config = function()
			vim.g.copilot_no_tab_map = true
			vim.g.copilot_assume_mapped = true
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
		"olimorris/codecompanion.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			-- optional but useful markdown rendering in chat
			{ "MeanderingProgrammer/render-markdown.nvim" },
		},
		config = function()
			require("codecompanion").setup({
				strategies = {
					chat = { adapter = { name = "copilot", model = "claude-sonnet-4.5" } },
					inline = { adapter = { name = "copilot", model = "claude-sonnet-4.5" } },
					cmd = { adapter = { name = "copilot", model = "claude-sonnet-4.5" } },
				},
			})
		end,
	},

	{
		"coder/claudecode.nvim",
		dependencies = { "folke/snacks.nvim" },
		config = function()
			require("claudecode").setup()

			-- Make Claude Code terminal respect catppuccin dim_inactive
			vim.api.nvim_create_autocmd("TermOpen", {
				pattern = "*",
				callback = function()
					-- Check if this is a Claude Code terminal
					local bufname = vim.api.nvim_buf_get_name(0)
					if bufname:match("claude") then
						-- Clear any winhighlight overrides so NormalNC can work
						vim.wo.winhighlight = ""
					end
				end,
			})
		end,
	},

	----------------------------------------------------------
	---------------------- Markdown --------------------------
	----------------------------------------------------------

	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		ft = { "markdown" },
		build = function()
			vim.fn["mkdp#util#install"]()
		end,
	},

	{
		"ellisonleao/glow.nvim",
		branch = "main",
		config = function()
			require("config.glow")
		end,
	},

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
		"esensar/nvim-dev-container",
		config = function()
			require("config.devcontainer")
		end,
	},

	{
		"folke/persistence.nvim",
		event = "BufReadPre",
		opts = {},
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
}
