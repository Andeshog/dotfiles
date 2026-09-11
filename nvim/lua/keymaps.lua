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

-- Conversion to NO keyboard
map({ "n", "x", "o" }, "ø", "[", { remap = true })
map({ "n", "x", "o" }, "æ", "]", { remap = true })

-- Scrolling
map({ "n", "v" }, "<C-d>", "<C-d>zz", { desc = "Scroll down (centered)", silent = true })
map({ "n", "v" }, "<C-u>", "<C-u>zz", { desc = "Scroll up (centered)", silent = true })

map("n", "<Esc>", "<cmd>nohlsearch | echon ''<cr>", { desc = "Clear search highlight + command line" })
-- Neo-tree
map("n", "<leader>o", "<cmd>Neotree reveal<cr>", { desc = "Reveal in Neo-tree", silent = true })
map("n", "<leader>B", "<cmd>Neotree float buffers<cr>", { desc = "Buffer list (Neo-tree)", silent = true })
map("n", "<leader>G", "<cmd>Neotree float git_status<cr>", { desc = "Git status (Neo-tree)", silent = true })

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

-- Move lines / selection up and down (replaces vim-move)
local function move_line(dir)
	return function()
		local line = vim.fn.line(".")
		if (dir > 0 and line >= vim.fn.line("$")) or (dir < 0 and line <= 1) then
			return
		end

		vim.cmd(("silent move %d"):format(dir > 0 and line + 1 or line - 2))
		vim.cmd("normal! ==")
	end
end

local function move_selection(dir)
	return function()
		-- Leave visual mode so the '< and '> marks are set
		vim.cmd("normal! \27")

		local first, last = vim.fn.line("'<"), vim.fn.line("'>")
		if (dir > 0 and last >= vim.fn.line("$")) or (dir < 0 and first <= 1) then
			vim.cmd("normal! gv")
			return
		end

		vim.cmd(("silent %d,%dmove %d"):format(first, last, dir > 0 and last + 1 or first - 2))
		vim.cmd("normal! gv=gv")
	end
end

map("n", "<A-j>", move_line(1), { desc = "Move line down", silent = true })
map("n", "<A-k>", move_line(-1), { desc = "Move line up", silent = true })
map("x", "<A-j>", move_selection(1), { desc = "Move selection down", silent = true })
map("x", "<A-k>", move_selection(-1), { desc = "Move selection up", silent = true })

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

-- Resize splits
map("n", "<M-Up>", "<cmd>resize +5<cr>", { desc = "Increase window height", silent = true })
map("n", "<M-Down>", "<cmd>resize -5<cr>", { desc = "Decrease window height", silent = true })
map("n", "<M-Left>", "<cmd>vertical resize +5<cr>", { desc = "Increase window width", silent = true })
map("n", "<M-Right>", "<cmd>vertical resize -5<cr>", { desc = "Decrease window width", silent = true })

-- Buffers
map("n", "<leader>b", "<nop>", { desc = "Buffer" })

-- Navigation
local buffer_history = require("custom_plugins.buffer_history")
map("n", "<S-l>", buffer_history.next, { desc = "Next buffer (history)", silent = true })
map("n", "<S-h>", buffer_history.prev, { desc = "Prev buffer (history)", silent = true })
map("n", "<leader>bb", "<cmd>b#<cr>", { desc = "Last buffer", silent = true })

-- Close buffers
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer (keep window)", silent = true })
map("n", "<leader>bD", "<cmd>bdelete!<cr>", { desc = "Force delete buffer", silent = true })
map("n", "<leader>bo", function()
	local current = vim.api.nvim_get_current_buf()

	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].buflisted and bufnr ~= current then
			vim.cmd("bdelete " .. bufnr)
		end
	end
end, { desc = "Delete other buffers", silent = true })
map("n", "<leader>bq", function()
	vim.cmd("silent! %bdelete | intro")
end, { desc = "Close all buffers", silent = true })

-- Git
local function visual_range()
	local start_line, end_line = vim.fn.line("v"), vim.fn.line(".")
	if start_line > end_line then
		start_line, end_line = end_line, start_line
	end
	return { start_line, end_line }
end

local function hunk_nav(direction)
	return function()
		if vim.wo.diff then
			vim.cmd.normal({ direction == "next" and "]c" or "[c", bang = true })
		else
			require("gitsigns").nav_hunk(direction)
		end
	end
end

map("n", "<leader>g", "<nop>", { desc = "git" })
map("n", "<leader>gg", "<cmd>Neogit<cr>", { desc = "Neogit" })
map("n", "<leader>gf", function()
	require("fzf-lua").git_status()
end, { desc = "Git status (fzf)" })
map("n", "<leader>gc", function()
	require("fzf-lua").git_branches()
end, { desc = "Git branches (fzf)" })
map("n", "<leader>gl", "<cmd>.DiffviewFileHistory %<cr>", { desc = "Git line history" })
map("v", "<leader>gl", ":<C-u>'<,'>DiffviewFileHistory %<cr>", { desc = "Git line history" })
map("n", "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", { desc = "Git file history" })
map("n", "<leader>gd", function()
	require("inlinediff").toggle()
end, { desc = "Toggle inline diff" })
map("n", "]c", hunk_nav("next"), { desc = "Next git hunk" })
map("n", "[c", hunk_nav("prev"), { desc = "Previous git hunk" })
map({ "o", "x" }, "ih", function()
	require("gitsigns").select_hunk()
end, { desc = "Git hunk" })
map({ "n", "v" }, "<leader>gs", function()
	local gs = require("gitsigns")
	if vim.fn.mode():match("[vV]") then
		gs.stage_hunk(visual_range())
	else
		gs.stage_hunk()
	end
end, { desc = "Stage/unstage git hunk" })
map("n", "<leader>gS", function()
	require("gitsigns").stage_buffer()
end, { desc = "Stage git buffer" })
map({ "n", "v" }, "<leader>gr", function()
	local gs = require("gitsigns")
	if vim.fn.mode():match("[vV]") then
		gs.reset_hunk(visual_range())
	else
		local line = vim.api.nvim_win_get_cursor(0)[1]
		gs.reset_hunk({ line, line })
	end
end, { desc = "Reset git line(s)" })
map("n", "<leader>gb", function()
	require("gitsigns").blame_line({ full = true })
end, { desc = "Git blame line" })
map("n", "<leader>gB", function()
	require("gitsigns").blame()
end, { desc = "Git blame buffer" })
map("n", "<leader>gq", function()
	require("gitsigns").setqflist("all")
end, { desc = "Git hunks to quickfix" })

----------------------------------------------------------
------------------------ FZF-lua -------------------------
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

map("t", "<M-Left>", function()
	local win = vim.api.nvim_get_current_win()
	local width = vim.api.nvim_win_get_width(win)
	vim.api.nvim_win_set_width(win, width + 5)
end, { desc = "Terminal: increase width" })

map("t", "<M-Right>", function()
	local win = vim.api.nvim_get_current_win()
	local width = vim.api.nvim_win_get_width(win)
	vim.api.nvim_win_set_width(win, width - 5)
end, { desc = "Terminal: decrease width" })

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
	vim.diagnostic.setqflist({ open = true, severity = vim.diagnostic.severity.ERROR, title = "Workspace Errors" })
end, { desc = "Workspace errors (quickfix)" })
map("n", "<leader>xq", diagnostics.close_lists, { desc = "Close diagnostic lists" })

-- Display toggles
map("n", "<leader>xv", diagnostics.toggle_virtual_lines, { desc = "Toggle diagnostic virtual lines" })

map("n", "<leader>xu", diagnostics.toggle_underline, { desc = "Toggle diagnostic underline" })
map("n", "<leader>xd", diagnostics.toggle, { desc = "Toggle diagnostics" })

local saved_config = nil

vim.keymap.set("n", "<leader>de", function()
	if saved_config then
		vim.diagnostic.config(saved_config)
		saved_config = nil
		vim.notify("Diagnostics: all severities")
		return
	end

	-- config() with no args returns a deepcopy of the current global config
	saved_config = vim.diagnostic.config()

	local cfg = vim.deepcopy(saved_config)
	local only = vim.diagnostic.severity.ERROR

	for _, handler in ipairs({ "underline", "virtual_text", "virtual_lines", "signs", "float" }) do
		local v = cfg[handler]
		if v == true or v == nil then
			cfg[handler] = { severity = only }
		elseif type(v) == "table" then
			v.severity = only
		end
		-- `false` stays false; you don't want to turn on a handler you'd disabled
	end

	vim.diagnostic.config(cfg)
	vim.notify("Diagnostics: errors only")
end, { desc = "Toggle errors-only diagnostics" })

-- Fluoride
map("n", "<leader>cp", "<cmd>Fluoride<cr>", { desc = "Fluoride" })
map("n", "<leader>cv", "<cmd>Fluoride vsplit<cr>", { desc = "Fluoride (vertical split)" })

-- Diffview
map("n", "<leader>dv", "<cmd>DiffviewOpen origin/main...HEAD<cr>", { desc = "Diffview: current branch vs main" })

-- Peeper-picker
map("n", "<leader>rr", "<cmd>PeeperPicker<cr>", { desc = "Peeper-picker: show lsp references" })
