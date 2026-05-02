local mc = require("multicursor-nvim")
mc.setup()

local set = vim.keymap.set

-- Add/skip cursor matching word or selection (ctrl+n like vim-visual-multi)
set({ "n", "x" }, "<C-n>", function()
	mc.matchAddCursor(1)
end)
set({ "n", "x" }, "<C-p>", function()
	mc.matchAddCursor(-1)
end)
set({ "n", "x" }, "<C-x>", function()
	mc.matchSkipCursor(1)
end)

-- Match all occurrences in document
set({ "n", "x" }, "<leader>ma", mc.matchAllAddCursors)

-- Toggle cursor at main cursor position
set({ "n", "x" }, "<C-q>", mc.toggleCursor)

-- Delete the main cursor
set({ "n", "x" }, "<leader>mx", mc.deleteCursor)

-- Rotate between cursors
set({ "n", "x" }, "<M-n>", mc.nextCursor)
set({ "n", "x" }, "<M-p>", mc.prevCursor)

-- Mouse support
set("n", "<c-leftmouse>", mc.handleMouse)
set("n", "<c-leftdrag>", mc.handleMouseDrag)
set("n", "<c-leftrelease>", mc.handleMouseRelease)

set("n", "<esc>", function()
	if not mc.cursorsEnabled() then
		mc.enableCursors()
	elseif mc.hasCursors() then
		mc.clearCursors()
	end
	vim.cmd("nohlsearch | echon ''")
end)

local hl = vim.api.nvim_set_hl
hl(0, "MultiCursorCursor", { link = "Cursor" })
hl(0, "MultiCursorVisual", { link = "Visual" })
hl(0, "MultiCursorSign", { link = "SignColumn" })
hl(0, "MultiCursorMatchPreview", { link = "Search" })
hl(0, "MultiCursorDisabledCursor", { link = "Visual" })
hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
hl(0, "MultiCursorDisabledSign", { link = "SignColumn" })
