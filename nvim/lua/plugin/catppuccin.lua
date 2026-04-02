require("catppuccin").setup({
	flavour = "frappe",
	transparent_background = false,
	dim_inactive = {
		enabled = true,
		shade = "dark",
		percentage = 0.05,
	},
	integrations = {
		gitsigns = true,
		neotree = true,
		treesitter = true,
		telescope = { enabled = true },
		fidget = true,
		mason = true,
		dap = true,
		neotest = true,
		which_key = true,
		indent_blankline = {
			enabled = true,
			colored_indent_levels = false,
		},
		markdown = true,
		semantic_tokens = true,
		treesitter_context = true,
		render_markdown = true,
	},
	custom_highlights = function(colors)
		return {
			-- ===== TYPES =====
			-- LSP type-kind differentiation (defaults have no bold/color split)
			["@lsp.type.class.cpp"] = { fg = colors.green, bold = true },
			["@lsp.type.struct.cpp"] = { fg = colors.teal, bold = true },
			["@lsp.type.enum.cpp"] = { fg = colors.yellow, bold = true },
			["@lsp.type.interface.cpp"] = { fg = colors.sapphire, bold = true },
			["@lsp.type.typeParameter.cpp"] = { fg = colors.mauve, italic = true },
			["@type.builtin.cpp"] = { fg = colors.peach }, -- default: mauve

			-- ===== NAMESPACE =====
			["@lsp.type.namespace.cpp"] = { fg = colors.blue }, -- default: yellow italic
			["@module.cpp"] = { fg = colors.blue },

			-- ===== PREPROCESSOR =====
			["@lsp.type.macro.cpp"] = { fg = colors.yellow }, -- default: mauve
			["@constant.macro.cpp"] = { fg = colors.yellow },
			["@keyword.directive.cpp"] = { fg = colors.yellow }, -- default: pink

			-- ===== FUNCTIONS =====
			-- Methods distinguished from free functions (sky vs default blue)
			["@lsp.type.method.cpp"] = { fg = colors.sky },
			["@function.method.cpp"] = { fg = colors.sky },
			["@function.method.call.cpp"] = { fg = colors.sky },

			-- ===== PARAMETERS =====
			["@lsp.type.parameter.cpp"] = { fg = colors.flamingo, italic = true }, -- default: maroon
			["@variable.parameter.cpp"] = { fg = colors.flamingo, italic = true },

			-- ===== VARIABLES =====
			["@lsp.type.variable.cpp"] = { fg = colors.lavender }, -- default: text
			["@variable.cpp"] = { fg = colors.lavender },

			-- ===== CONSTANTS =====
			["@lsp.type.enumMember.cpp"] = { fg = colors.yellow, italic = true }, -- default: teal
			["@constant.cpp"] = { fg = colors.peach },

			-- ===== KEYWORDS =====
			["@keyword.operator.cpp"] = { fg = colors.overlay1 }, -- default: mauve
			["@keyword.storage.cpp"] = { fg = colors.lavender },
			["@keyword.import.cpp"] = { fg = colors.blue }, -- catppuccin cpp default: yellow

			-- ===== OPERATORS & PUNCTUATION =====
			["@operator.cpp"] = { fg = colors.overlay1 }, -- default: sky
			["@punctuation.delimiter.cpp"] = { fg = colors.overlay1 }, -- default: overlay2
			["@punctuation.special.cpp"] = { fg = colors.overlay1 }, -- default: pink

			-- ===== COMMENTS =====
			["@comment.cpp"] = { fg = colors.overlay1, italic = true }, -- default: overlay2

			-- ===== SPECIAL =====
			["@constructor.cpp"] = { fg = colors.sapphire }, -- default: yellow

			-- ===== DIAGNOSTICS =====
			DiagnosticUnderlineError = { undercurl = true, sp = colors.red },
			DiagnosticUnderlineWarn = { undercurl = true, sp = colors.yellow },
			DiagnosticUnderlineInfo = { undercurl = true, sp = colors.sky },
			DiagnosticUnderlineHint = { undercurl = true, sp = colors.teal },

			-- ===== CODECOMPANION =====
			CodeCompanionBorder = { fg = colors.sapphire, bg = colors.base, bold = true },
			CodeCompanionWinBar = { fg = colors.base, bg = colors.sapphire, bold = true },
			CodeCompanionWinBarNC = { fg = colors.text, bg = colors.surface0, bold = true },
			CodeCompanionChatHeader = { fg = colors.blue, bg = colors.surface0, bold = true },
			CodeCompanionChatSeparator = { fg = colors.surface2 },
			CodeCompanionVirtualText = { fg = colors.overlay1, italic = true },
			CodeCompanionTokens = { fg = colors.sapphire, italic = true },

			-- ===== LSP MODIFIERS =====
			["@lsp.mod.readonly.cpp"] = { italic = true },
			["@lsp.mod.static.cpp"] = { underline = true },
			["@lsp.mod.abstract.cpp"] = { italic = true },
		}
	end,
})
