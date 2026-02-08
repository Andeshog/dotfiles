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
		custom_highlights = function(colors)
			return {
				-- ===== TYPES =====
				-- LSP (when available)
				["@lsp.type.class.cpp"] = { fg = colors.green, style = { "bold" } },
				["@lsp.type.struct.cpp"] = { fg = colors.teal, style = { "bold" } },
				["@lsp.type.enum.cpp"] = { fg = colors.yellow, style = { "bold" } },
				["@lsp.type.interface.cpp"] = { fg = colors.sapphire, style = { "bold" } },
				["@lsp.type.typeParameter.cpp"] = { fg = colors.mauve, style = { "italic" } },

				-- Tree-sitter fallbacks for types
				["@type.cpp"] = { fg = colors.green },
				["@type.builtin.cpp"] = { fg = colors.peach }, -- int, double, void, etc
				["@type.qualifier.cpp"] = { fg = colors.mauve, style = { "bold" } }, -- const, volatile
				["@type.keyword.cpp"] = { fg = colors.mauve, style = { "bold" } }, -- namespace, class, struct, enum
				["@keyword.import.cpp"] = { fg = colors.pink, style = { "bold" } }, -- #include

				-- ===== NAMESPACE =====
				-- LSP
				["@lsp.type.namespace.cpp"] = { fg = colors.blue, style = { "bold" } },
				-- Tree-sitter fallback
				["@namespace.cpp"] = { fg = colors.blue, style = { "bold" } },

				-- ===== PREPROCESSOR =====
				-- LSP
				["@lsp.type.macro.cpp"] = { fg = colors.peach, style = { "bold" } },
				-- Tree-sitter fallbacks
				["@constant.macro.cpp"] = { fg = colors.peach, style = { "bold" } },
				["@preproc.cpp"] = { fg = colors.pink }, -- #include, #define, etc

				-- ===== FUNCTIONS =====
				-- LSP
				["@lsp.type.function.cpp"] = { fg = colors.blue },
				["@lsp.type.method.cpp"] = { fg = colors.sky },
				-- Tree-sitter fallbacks
				["@function.cpp"] = { fg = colors.blue },
				["@function.method.cpp"] = { fg = colors.sky },
				["@function.call.cpp"] = { fg = colors.blue },
				["@function.method.call.cpp"] = { fg = colors.sky },

				-- ===== PARAMETERS =====
				-- LSP
				["@lsp.type.parameter.cpp"] = { fg = colors.flamingo, style = { "italic" } },
				-- Tree-sitter fallback
				["@parameter.cpp"] = { fg = colors.flamingo, style = { "italic" } },

				-- ===== VARIABLES =====
				-- LSP
				["@lsp.type.variable.cpp"] = { fg = colors.lavender },
				["@lsp.type.property.cpp"] = { fg = colors.sky },
				-- Tree-sitter fallbacks
				["@variable.cpp"] = { fg = colors.lavender },
				["@variable.member.cpp"] = { fg = colors.sky },
				["@property.cpp"] = { fg = colors.sky },

				-- ===== CONSTANTS =====
				["@lsp.type.enumMember.cpp"] = { fg = colors.yellow, style = { "italic" } },
				["@constant.cpp"] = { fg = colors.peach },
				["@constant.builtin.cpp"] = { fg = colors.peach },

				-- ===== KEYWORDS =====
				["@keyword.cpp"] = { fg = colors.mauve, style = { "italic" } },
				["@keyword.function.cpp"] = { fg = colors.mauve, style = { "bold" } }, -- return
				["@keyword.return.cpp"] = { fg = colors.mauve, style = { "bold" } },
				["@keyword.operator.cpp"] = { fg = colors.sky }, -- sizeof, new, delete
				["@keyword.type.cpp"] = { fg = colors.mauve, style = { "bold" } }, -- const, volatile
				["@keyword.storage.cpp"] = { fg = colors.lavender }, -- static, extern
				["@keyword.repeat.cpp"] = { fg = colors.mauve }, -- for, while
				["@keyword.conditional.cpp"] = { fg = colors.mauve }, -- if, else

				-- ===== OPERATORS =====
				["@operator.cpp"] = { fg = colors.sky },

				-- ===== PUNCTUATION =====
				["@punctuation.delimiter.cpp"] = { fg = colors.lavender }, -- :: scope resolution operator
				["@punctuation.bracket.cpp"] = { fg = colors.overlay2 }, -- () [] {}
				["@punctuation.special.cpp"] = { fg = colors.sky }, -- ::

				-- ===== STRINGS & NUMBERS =====
				["@string.cpp"] = { fg = colors.green },
				["@character.cpp"] = { fg = colors.teal },
				["@number.cpp"] = { fg = colors.peach },
				["@boolean.cpp"] = { fg = colors.peach },

				-- ===== COMMENTS =====
				["@comment.cpp"] = { fg = colors.overlay0, style = { "italic" } },

				-- ===== SPECIAL =====
				["@constructor.cpp"] = { fg = colors.sapphire, style = { "bold" } },
				["@label.cpp"] = { fg = colors.sapphire }, -- goto labels

				-- ===== LSP MODIFIERS =====
				["@lsp.mod.readonly.cpp"] = { style = { "italic" } },
				["@lsp.mod.static.cpp"] = { style = { "underline" } },
				["@lsp.mod.abstract.cpp"] = { style = { "italic" } },
			}
		end,
	})
end

return M
