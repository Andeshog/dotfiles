local M = {}

function M.setup()
	require("catppuccin").setup({
		flavour = "frappe", -- latte, frappe, macchiato, mocha
		transparent_background = false,
		dim_inactive = {
			enabled = true,
			shade = "dark",
			percentage = 0.15,
		},
		integrations = {
			cmp = true,
			gitsigns = true,
			neotree = true,
			treesitter = true,
			telescope = {
				enabled = true,
			},
			fidget = true,
			mason = true,
			dap = true,
			dap_ui = true,
			which_key = true,
			indent_blankline = {
				enabled = true,
				colored_indent_levels = false,
			},
			markdown = true,
			native_lsp = {
				enabled = true,
				virtual_text = {
					errors = { "italic" },
					hints = { "italic" },
					warnings = { "italic" },
					information = { "italic" },
				},
				underlines = {
					errors = { "underline" },
					hints = { "underline" },
					warnings = { "underline" },
					information = { "underline" },
				},
			},
			navic = {
				enabled = true,
				custom_bg = "NONE",
			},
			notify = true,
			semantic_tokens = true,
			treesitter_context = true,
			lsp_trouble = true,
			render_markdown = true,
		},
	})
end

return M
