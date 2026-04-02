require("catppuccin").setup({
	flavour = "frappe",
	transparent_background = false,
	dim_inactive = {
		enabled = true,
		shade = "dark",
		percentage = 0.15,
	},
	lsp_styles = {
		virtual_text = {
			errors = { "italic" },
			hints = { "italic" },
			warnings = { "italic" },
			information = { "italic" },
		},
		underlines = {
			errors = { "undercurl" },
			hints = { "undercurl" },
			warnings = { "undercurl" },
			information = { "undercurl" },
		},
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
			["@lsp.type.class.cpp"] = { fg = colors.green, style = { "bold" } },
			["@lsp.type.struct.cpp"] = { fg = colors.teal, style = { "bold" } },
			["@lsp.type.enum.cpp"] = { fg = colors.yellow, style = { "bold" } },
			["@lsp.type.interface.cpp"] = { fg = colors.sapphire, style = { "bold" } },
			["@lsp.type.typeParameter.cpp"] = { fg = colors.mauve, style = { "italic" } },

			["@type.cpp"] = { fg = colors.green },
			["@type.builtin.cpp"] = { fg = colors.peach },
			["@type.qualifier.cpp"] = { fg = colors.mauve, style = { "bold" } },
			["@type.keyword.cpp"] = { fg = colors.mauve, style = { "bold" } },
			["@keyword.import.cpp"] = { fg = colors.pink, style = { "bold" } },

			-- ===== NAMESPACE =====
			["@lsp.type.namespace.cpp"] = { fg = colors.blue, style = { "bold" } },
			["@namespace.cpp"] = { fg = colors.blue, style = { "bold" } },

			-- ===== PREPROCESSOR =====
			["@lsp.type.macro.cpp"] = { fg = colors.peach, style = { "bold" } },
			["@constant.macro.cpp"] = { fg = colors.peach, style = { "bold" } },
			["@preproc.cpp"] = { fg = colors.pink },

			-- ===== FUNCTIONS =====
			["@lsp.type.function.cpp"] = { fg = colors.blue },
			["@lsp.type.method.cpp"] = { fg = colors.sky },
			["@function.cpp"] = { fg = colors.blue },
			["@function.method.cpp"] = { fg = colors.sky },
			["@function.call.cpp"] = { fg = colors.blue },
			["@function.method.call.cpp"] = { fg = colors.sky },

			-- ===== PARAMETERS =====
			["@lsp.type.parameter.cpp"] = { fg = colors.flamingo, style = { "italic" } },
			["@parameter.cpp"] = { fg = colors.flamingo, style = { "italic" } },

			-- ===== VARIABLES =====
			["@lsp.type.variable.cpp"] = { fg = colors.lavender },
			["@lsp.type.property.cpp"] = { fg = colors.sky },
			["@variable.cpp"] = { fg = colors.lavender },
			["@variable.member.cpp"] = { fg = colors.sky },
			["@property.cpp"] = { fg = colors.sky },

			-- ===== CONSTANTS =====
			["@lsp.type.enumMember.cpp"] = { fg = colors.yellow, style = { "italic" } },
			["@constant.cpp"] = { fg = colors.peach },
			["@constant.builtin.cpp"] = { fg = colors.peach },

			-- ===== KEYWORDS =====
			["@keyword.cpp"] = { fg = colors.mauve, style = { "italic" } },
			["@keyword.function.cpp"] = { fg = colors.mauve, style = { "bold" } },
			["@keyword.return.cpp"] = { fg = colors.mauve, style = { "bold" } },
			["@keyword.operator.cpp"] = { fg = colors.sky },
			["@keyword.type.cpp"] = { fg = colors.mauve, style = { "bold" } },
			["@keyword.storage.cpp"] = { fg = colors.lavender },
			["@keyword.repeat.cpp"] = { fg = colors.mauve },
			["@keyword.conditional.cpp"] = { fg = colors.mauve },

			-- ===== OPERATORS =====
			["@operator.cpp"] = { fg = colors.sky },

			-- ===== PUNCTUATION =====
			["@punctuation.delimiter.cpp"] = { fg = colors.lavender },
			["@punctuation.bracket.cpp"] = { fg = colors.overlay2 },
			["@punctuation.special.cpp"] = { fg = colors.sky },

			-- ===== STRINGS & NUMBERS =====
			["@string.cpp"] = { fg = colors.green },
			["@character.cpp"] = { fg = colors.teal },
			["@number.cpp"] = { fg = colors.peach },
			["@boolean.cpp"] = { fg = colors.peach },

			-- ===== COMMENTS =====
			["@comment.cpp"] = { fg = colors.overlay0, style = { "italic" } },

			-- ===== SPECIAL =====
			["@constructor.cpp"] = { fg = colors.sapphire, style = { "bold" } },
			["@label.cpp"] = { fg = colors.sapphire },

			DiagnosticUnderlineError = { undercurl = true, sp = colors.red },
			DiagnosticUnderlineWarn = { undercurl = true, sp = colors.yellow },
			DiagnosticUnderlineInfo = { undercurl = true, sp = colors.sky },
			DiagnosticUnderlineHint = { undercurl = true, sp = colors.teal },

			CodeCompanionChatHeader = { fg = colors.blue, bg = colors.surface0, bold = true },
			CodeCompanionChatSeparator = { fg = colors.surface2 },
			CodeCompanionVirtualText = { fg = colors.overlay1, italic = true },
			CodeCompanionTokens = { fg = colors.sapphire, italic = true },

			-- ===== LSP MODIFIERS =====
			["@lsp.mod.readonly.cpp"] = { style = { "italic" } },
			["@lsp.mod.static.cpp"] = { style = { "underline" } },
			["@lsp.mod.abstract.cpp"] = { style = { "italic" } },
		}
	end,
})
