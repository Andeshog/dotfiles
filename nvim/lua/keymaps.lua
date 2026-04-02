local map = vim.keymap.set
local diagnostics = require("diagnostics")

local function open_grug_far(options)
	require("grug-far").open(options or {})
end

local function open_grug_far_current_file(options)
	options = options or {}
	options.prefills = vim.tbl_extend("force", options.prefills or {}, {
		paths = vim.fn.expand("%"),
	})
	open_grug_far(options)
end

map("n", "<Esc>", "<cmd>nohlsearch | echon ''<cr>", { desc = "Clear search highlight + command line" })
-- Neo-tree
map("n", "<leader>o", "<cmd>Neotree reveal<cr>", { desc = "Reveal in Neo-tree", silent = true })

-- Treewalker
map({ "n", "v" }, "<C-k>", "<cmd>Treewalker Up<cr>", { desc = "Treewalker up", silent = true })
map({ "n", "v" }, "<C-j>", "<cmd>Treewalker Down<cr>", { desc = "Treewalker down", silent = true })
map({ "n", "v" }, "<C-h>", "<cmd>Treewalker Left<cr>", { desc = "Treewalker left", silent = true })
map({ "n", "v" }, "<C-l>", "<cmd>Treewalker Right<cr>", { desc = "Treewalker right", silent = true })
map("n", "<C-S-k>", "<cmd>Treewalker SwapUp<cr>", { desc = "Treewalker swap up", silent = true })
map("n", "<C-S-j>", "<cmd>Treewalker SwapDown<cr>", { desc = "Treewalker swap down", silent = true })
map("n", "<C-S-h>", "<cmd>Treewalker SwapLeft<cr>", { desc = "Treewalker swap left", silent = true })
map("n", "<C-S-l>", "<cmd>Treewalker SwapRight<cr>", { desc = "Treewalker swap right", silent = true })

-- Save
map("n", "<C-S>", "<cmd>w<cr>", { desc = "Save", silent = true })
map("i", "<C-S>", "<cmd>w<cr>", { desc = "Save", silent = true })

-- Quit
map("n", "q", "<cmd>q<cr>", { desc = "Quit window" })
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })
map("n", "<leader>qQ", "<cmd>qa!<cr>", { desc = "Quit all (force)" })

-- Delete to black hole register (don't pollute clipboard)
map({ "n", "v" }, "d", '"_d', { desc = "Delete to black hole" })
map({ "n", "v" }, "D", '"_D', { desc = "Delete to EOL (black hole)" })
map({ "n", "v" }, "c", '"_c', { desc = "Change to black hole" })
map({ "n", "v" }, "C", '"_C', { desc = "Change to EOL (black hole)" })

-- Yank without moving cursor
map("x", "y", function()
	local cur = vim.api.nvim_win_get_cursor(0)
	vim.cmd("normal! y")
	vim.api.nvim_win_set_cursor(0, cur)
end, { desc = "Yank (keep cursor)", silent = true })

-- Select all
map("n", "<C-A>", "ggVG", { desc = "Select all" })

----------------------------------------------------------
-------------------- Window Management -------------------
----------------------------------------------------------
map("n", "<leader>w", "<nop>", { desc = "Window" })

-- Navigation
map("n", "<Up>", "<C-w>k", { desc = "Window up", silent = true })
map("n", "<Down>", "<C-w>j", { desc = "Window down", silent = true })
map("n", "<Left>", "<C-w>h", { desc = "Window left", silent = true })
map("n", "<Right>", "<C-w>l", { desc = "Window right", silent = true })

-- Splits
map("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
map("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
map("n", "<leader>we", "<C-w>=", { desc = "Equalize window sizes" })
map("n", "<leader>wc", "<cmd>close<cr>", { desc = "Close window" })

-- Buffers
map("n", "<leader>b", "<nop>", { desc = "Buffer" })

-- Navigation
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer", silent = true })
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer", silent = true })
map("n", "<leader>bb", "<cmd>b#<cr>", { desc = "Last buffer", silent = true })

-- Close buffers
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer (keep window)", silent = true })
map("n", "<leader>bD", "<cmd>bdelete!<cr>", { desc = "Force delete buffer", silent = true })
map("n", "<leader>bo", "<cmd>%bdelete|edit#|bdelete#<cr>", { desc = "Delete other buffers", silent = true })
map("n", "<leader>bq", "<cmd>bufdo bdelete<cr>", { desc = "Delete all buffers", silent = true })

-- Git
map("n", "<leader>g", "<nop>", { desc = "Git" })
map("n", "<leader>gg", "<cmd>Neogit<cr>", { desc = "Neogit" })
-- Git lineage is default mapped to v <leader>gl on selection
map("n", "<leader>gd", function()
	require("inlinediff").toggle()
end, { desc = "Toggle inline diff" })

----------------------------------------------------------
----------------------- Telescope ------------------------
----------------------------------------------------------
map("n", "<leader>f", "<nop>", { desc = "Find" })

-- Terminal
-- Increase/decrease terminal height from terminal mode
map("t", "<M-Up>", function()
	local win = vim.api.nvim_get_current_win()
	local height = vim.api.nvim_win_get_height(win)
	vim.api.nvim_win_set_height(win, height + 5)
end, { desc = "Terminal: increase height" })

map("t", "<M-Down>", function()
	local win = vim.api.nvim_get_current_win()
	local height = vim.api.nvim_win_get_height(win)
	vim.api.nvim_win_set_height(win, height - 5)
end, { desc = "Terminal: decrease height" })

-- Grug-far (find and replace)
map("n", "<leader>sr", function()
	open_grug_far()
end, { desc = "Search and replace" })
map("n", "<leader>sw", function()
	open_grug_far({ prefills = { search = vim.fn.expand("<cword>") } })
end, { desc = "Search current word" })
map("v", "<leader>sw", function()
	require("grug-far").with_visual_selection()
end, { desc = "Search selection" })
map("n", "<leader>sp", function()
	open_grug_far_current_file({ prefills = { search = vim.fn.expand("<cword>") } })
end, { desc = "Search current word in file" })
map("v", "<leader>sp", function()
	require("grug-far").with_visual_selection({
		prefills = { paths = vim.fn.expand("%") },
	})
end, { desc = "Search selection in file" })
map("n", "<leader>sf", function()
	open_grug_far_current_file()
end, { desc = "Search current file" })

-- Zen mode
map("n", "<leader>z", function()
	require("plugin.zen").toggle()
end, { desc = "Toggle Zen mode" })

----------------------------------------------------------
--------------------- Diagnostics ------------------------
----------------------------------------------------------
map("n", "<leader>x", "<nop>", { desc = "Diagnostics" })

-- Navigation
map("n", "[d", diagnostics.goto_prev(), { desc = "Previous diagnostic" })
map("n", "]d", diagnostics.goto_next(), { desc = "Next diagnostic" })
map("n", "[e", diagnostics.goto_prev({ severity = vim.diagnostic.severity.ERROR }), { desc = "Previous error" })
map("n", "]e", diagnostics.goto_next({ severity = vim.diagnostic.severity.ERROR }), { desc = "Next error" })
map("n", "[w", diagnostics.goto_prev({ severity = vim.diagnostic.severity.WARN }), { desc = "Previous warning" })
map("n", "]w", diagnostics.goto_next({ severity = vim.diagnostic.severity.WARN }), { desc = "Next warning" })
-- Inspection
map("n", "<leader>xh", vim.diagnostic.open_float, { desc = "Hover diagnostics (line)" })

-- Lists
map("n", "<leader>xx", diagnostics.toggle_buffer_list, { desc = "Buffer diagnostics" })
map("n", "<leader>xX", diagnostics.toggle_workspace_list, { desc = "Workspace diagnostics" })
map("n", "<leader>xe", function()
	vim.diagnostic.setqflist({ severity = vim.diagnostic.severity.ERROR })
end, { desc = "Workspace errors (quickfix)" })
map("n", "<leader>xq", diagnostics.close_lists, { desc = "Close diagnostic lists" })

-- Display toggles
map("n", "<leader>xv", diagnostics.toggle_virtual_lines, { desc = "Toggle diagnostic virtual lines" })

map("n", "<leader>xu", diagnostics.toggle_underline, { desc = "Toggle diagnostic underline" })
map("n", "<leader>xd", diagnostics.toggle, { desc = "Toggle diagnostics" })

-- Fluoride
map("n", "<leader>cp", function()
	require("fluoride").toggle()
end, { desc = "Toggle Fluoride" })
