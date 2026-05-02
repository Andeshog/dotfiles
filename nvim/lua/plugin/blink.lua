require("blink.cmp").setup({
	enabled = function()
		return vim.bo.buftype ~= "prompt" and vim.bo.filetype ~= "neo-tree-popup"
	end,
	signature = {
		enabled = true,
	},
	keymap = {
		preset = "none",
		["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
		["<C-e>"] = { "cancel", "fallback" },
		["<CR>"] = { "accept", "fallback" },
		["<Tab>"] = {
			function(cmp)
				if cmp.is_menu_visible() then
					return cmp.select_next()
				end
				if cmp.snippet_active({ direction = 1 }) then
					return cmp.snippet_forward()
				end
			end,
			"fallback",
		},
		["<S-Tab>"] = {
			function(cmp)
				if cmp.is_menu_visible() then
					return cmp.select_prev()
				end
				if cmp.snippet_active({ direction = -1 }) then
					return cmp.snippet_backward()
				end
			end,
			"fallback",
		},
		["<Up>"] = {
			function(cmp)
				if cmp.is_menu_visible() then
					return cmp.select_prev()
				end
			end,
			"fallback",
		},
		["<Down>"] = {
			function(cmp)
				if cmp.is_menu_visible() then
					return cmp.select_next()
				end
			end,
			"fallback",
		},
		["<C-p>"] = { "select_prev", "fallback_to_mappings" },
		["<C-n>"] = { "select_next", "fallback_to_mappings" },
		["<C-b>"] = { "scroll_documentation_up", "fallback" },
		["<C-f>"] = { "scroll_documentation_down", "fallback" },
		["<C-k>"] = { "show_signature", "hide_signature", "fallback" },
	},
	fuzzy = {
		implementation = "prefer_rust",
	},
	completion = {
		list = {
			selection = {
				preselect = true,
				auto_insert = false,
			},
		},
		menu = {
			draw = {
				columns = {
					{ "kind_icon" },
					{ "label", "label_description", gap = 1 },
					{ "source_name" },
				},
			},
		},
	},
	sources = {
		default = { "lsp", "path", "snippets", "buffer" },
		per_filetype = {
			codecompanion = { "codecompanion" },
			codecompanion_input = { "codecompanion" },
		},
		providers = {
			lsp = {
				name = "LSP",
			},
			path = {
				name = "Path",
			},
			buffer = {
				name = "Buffer",
			},
			snippets = {
				name = "Snippet",
			},
			codecompanion = {
				name = "CodeCompanion",
				module = "codecompanion.providers.completion.blink",
				score_offset = 10,
			},
		},
	},
	cmdline = {
		keymap = { preset = "inherit" },
		completion = {
			menu = {
				auto_show = function()
					return vim.fn.getcmdtype() == ":"
				end,
			},
		},
	},
})
