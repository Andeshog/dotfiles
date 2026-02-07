local M = {}

function M.setup()
	require("tokyonight").setup({
		style = "night",
		on_highlights = function(hl, c)
			-- Get the NIGHT palette without changing the main style
			local night = require("tokyonight.colors").setup({
				style = "night",
				transform = true,
			})

			local storm = require("tokyonight.colors").setup({
				style = "storm",
				transform = true,
			})

			-- Basic Neo-tree background + foreground from NIGHT
			hl.NeoTreeNormal = { bg = night.bg, fg = night.fg }
			hl.NeoTreeNormalNC = { bg = night.bg, fg = night.fg }
			hl.NeoTreeEndOfBuffer = { bg = night.bg, fg = night.bg }

			-- Borders/separators
			hl.NeoTreeWinSeparator = { bg = night.bg, fg = night.border }

			-- Directory / root name
			hl.NeoTreeRootName = { fg = storm.blue, bold = true }
			hl.NeoTreeDirectoryName = { fg = storm.blue }

			-- Git status inside Neo-tree, using night palette
			hl.NeoTreeGitAdded = { fg = storm.green }
			hl.NeoTreeGitModified = { fg = storm.orange }
			hl.NeoTreeGitDeleted = { fg = storm.red }
			hl.NeoTreeGitIgnored = { fg = storm.comment }
		end,
	})
end

return M
