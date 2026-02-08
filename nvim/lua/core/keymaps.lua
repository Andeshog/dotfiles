local map = vim.keymap.set
local opts = { silent = true }

----------------------------------------------------------
---------------------- Basic Editing ---------------------
----------------------------------------------------------

-- Escape alternatives
map("i", "jj", "<Esc>", opts)
map("i", "jk", "<Esc>", opts)

-- Clear search highlight
map("n", "<Esc>", ":nohlsearch<CR><Esc>", opts)

-- Yank without moving cursor
map("x", "y", function()
	local cur = vim.api.nvim_win_get_cursor(0)
	vim.cmd("normal! y")
	vim.api.nvim_win_set_cursor(0, cur)
end, { desc = "Yank (keep cursor)", silent = true })

-- Delete to black hole register (don't pollute clipboard)
map({ "n", "v" }, "d", '"_d', { desc = "Delete to black hole" })
map({ "n", "v" }, "D", '"_D', { desc = "Delete to EOL (black hole)" })
map({ "n", "v" }, "c", '"_c', { desc = "Change to black hole" })
map({ "n", "v" }, "C", '"_C', { desc = "Change to EOL (black hole)" })

-- Select all
map("n", "<C-A>", "ggVG", { desc = "Select all" })

-- Save
map("n", "<C-S>", ":w<CR>", opts)
map("i", "<C-S>", function()
	vim.cmd("w")
end, opts)

-- Quit
map("n", "q", "<cmd>q<cr>", { desc = "Quit window" })

----------------------------------------------------------
-------------------- Window Management -------------------
----------------------------------------------------------
map("n", "<leader>w", "<nop>", { desc = "Window" })

-- Navigation
map("n", "<Up>", "<C-w>k", opts)
map("n", "<Down>", "<C-w>j", opts)
map("n", "<Left>", "<C-w>h", opts)
map("n", "<Right>", "<C-w>l", opts)

-- Splits
map("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
map("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
map("n", "<leader>se", "<C-w>=", { desc = "Equalize window sizes" })
map("n", "<leader>sx", "<cmd>close<cr>", { desc = "Close current window" })
map("n", "<leader>wc", "<cmd>close<cr>", { desc = "Close window" })

-- Swap windows
map("n", "<leader>wx", "<C-w>x", { desc = "Swap windows", silent = true })

-- Move window to edge
map("n", "<leader>wH", "<C-w>H", { desc = "Move window far left" })
map("n", "<leader>wJ", "<C-w>J", { desc = "Move window far down" })
map("n", "<leader>wK", "<C-w>K", { desc = "Move window far up" })
map("n", "<leader>wL", "<C-w>L", { desc = "Move window far right" })

-- Maximize current window
map("n", "<C-w>z", function()
	vim.cmd("wincmd _")
	vim.cmd("wincmd |")
end, { desc = "Maximize current window" })

-- Move floating window to split
map("n", "<leader>ws", function()
	vim.api.nvim_win_set_config(0, { split = "above", win = vim.fn.win_getid(1) })
end, { desc = "Move floating window to split" })

-- Which-Key
map("n", "<leader>wK", "<cmd>WhichKey <CR>", { desc = "whichkey all keymaps" })
map("n", "<leader>wk", function()
	vim.cmd("WhichKey " .. vim.fn.input("WhichKey: "))
end, { desc = "whichkey query lookup" })

----------------------------------------------------------
-------------------- Buffer Management -------------------
----------------------------------------------------------
map("n", "<leader>b", "<nop>", { desc = "Buffer" })

-- Navigation
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer", silent = true })
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer", silent = true })
map("n", "<leader>bb", "<cmd>b#<cr>", { desc = "Last buffer", silent = true })
map("n", "<leader><leader>", "<cmd>Telescope buffers<cr>", { desc = "Buffers" })

-- Close buffers
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer (keep window)", silent = true })
map("n", "<leader>bD", "<cmd>bdelete!<cr>", { desc = "Force delete buffer", silent = true })
map("n", "<leader>bo", "<cmd>%bdelete|edit#|bdelete#<cr>", { desc = "Delete other buffers", silent = true })
map("n", "<leader>bq", "<cmd>bufdo bdelete<cr>", { desc = "Delete all buffers", silent = true })

----------------------------------------------------------
----------------------- Telescope ------------------------
----------------------------------------------------------
map("n", "<leader>f", "<nop>", { desc = "Find" })

map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Live grep" })
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Buffers" })
map("n", "<leader>fc", "<cmd>Telescope current_buffer_fuzzy_find<cr>", { desc = "Current buffer" })
map("n", "<leader>fx", "<cmd>Telescope diagnostics<cr>", { desc = "Diagnostics" })
map("n", "<leader>fn", "<cmd>Telescope notify<cr>", { desc = "Notify" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Help tags" })
map("n", "<leader>fo", "<cmd>Telescope oldfiles<cr>", { desc = "Old files" })
map("n", "<leader>fm", "<cmd>Telescope marks<cr>", { desc = "Marks" })
map("n", "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", { desc = "Document symbols" })
map("n", "<leader>fS", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", { desc = "Workspace symbols" })
map("n", "<leader>fk", "<cmd>Telescope keymaps<cr>", { desc = "Keymaps" })
map("n", "<leader>fC", "<cmd>Telescope commands<cr>", { desc = "Commands" })
map("n", "<leader>fr", "<cmd>Telescope frecency workspace=CWD<cr>", { desc = "Frecency recent files" })

----------------------------------------------------------
-------------------------- Git ---------------------------
----------------------------------------------------------
map("n", "<leader>g", "<nop>", { desc = "Git" })

map("n", "<leader>gs", "<cmd>Telescope git_status<cr>", { desc = "Git status" })
map("n", "<leader>gg", "<cmd>Neogit<cr>", { desc = "Neogit" })
map("n", "<leader>gp", function()
	require("gitsigns").preview_hunk()
end, { desc = "Preview git hunk inline" })
map("n", "<leader>gb", "<C-o>", { desc = "Jump back" })
map("n", "<leader>gf", "<C-i>", { desc = "Jump forward" })

----------------------------------------------------------
----------------------- Terminal -------------------------
----------------------------------------------------------
map("n", "<leader>t", "<nop>", { desc = "Terminal/Test" })

map("n", "<leader>tt", "<cmd>terminal<cr>", { desc = "Open terminal" })

-- Terminal mode navigation
map("t", "<C-x>", "<C-\\><C-N>", { desc = "Terminal escape" })
map("t", "<C-h>", "<C-\\><C-N><C-w>h", { desc = "Terminal: go to left window" })
map("t", "<C-j>", "<C-\\><C-N><C-w>j", { desc = "Terminal: go to bottom window" })
map("t", "<C-k>", "<C-\\><C-N><C-w>k", { desc = "Terminal: go to top window" })
map("t", "<C-l>", "<C-\\><C-N><C-w>l", { desc = "Terminal: go to right window" })

-- Terminal scrolling
map("t", "<M-u>", "<C-\\><C-N><C-u>i", { desc = "Terminal: scroll up half page" })
map("t", "<M-d>", "<C-\\><C-N><C-d>i", { desc = "Terminal: scroll down half page" })
map("t", "<M-b>", "<C-\\><C-N><C-b>i", { desc = "Terminal: scroll up full page" })
map("t", "<M-f>", "<C-\\><C-N><C-f>i", { desc = "Terminal: scroll down full page" })
map("t", "<M-q>", "<C-\\><C-N>:q<CR>", { desc = "Terminal: quit window" })

-- Auto-enter insert mode when entering terminal windows
vim.api.nvim_create_autocmd("BufEnter", {
	pattern = "term://*",
	callback = function()
		vim.cmd("startinsert")
	end,
})

----------------------------------------------------------
------------------------ Testing -------------------------
----------------------------------------------------------
-- (shares <leader>t with Terminal)

map("n", "<leader>tc", "<cmd>ConfigureGtest<cr>", { desc = "Gtest: configure marked tests" })
map("n", "<leader>td", "<cmd>TodoTelescope<CR>", { desc = "TODO comments" })

-- Run tests
map("n", "<leader>tn", function()
	local ok, neotest = pcall(require, "neotest")
	if not ok then
		vim.notify("neotest not available", vim.log.levels.WARN)
		return
	end
	neotest.run.run()
end, { desc = "Neotest: run nearest test" })

map("n", "<leader>tf", function()
	local ok, neotest = pcall(require, "neotest")
	if not ok then
		vim.notify("neotest not available", vim.log.levels.WARN)
		return
	end
	neotest.run.run(vim.fn.expand("%"))
end, { desc = "Neotest: run file tests" })

-- Debug tests
map("n", "<leader>tN", function()
	local ok, neotest = pcall(require, "neotest")
	if not ok then
		vim.notify("neotest not available", vim.log.levels.WARN)
		return
	end
	neotest.run.run({ strategy = "dap" })
end, { desc = "Neotest: debug nearest test" })

map("n", "<leader>tD", function()
	local ok, neotest = pcall(require, "neotest")
	if not ok then
		return
	end
	neotest.run.run(vim.fn.expand("%"), { strategy = "dap" })
end, { desc = "Test: debug file" })

-- Test UI
map("n", "<leader>ts", function()
	local ok, neotest = pcall(require, "neotest")
	if not ok then
		vim.notify("neotest not available", vim.log.levels.WARN)
		return
	end
	neotest.summary.toggle()
end, { desc = "Neotest: toggle summary" })

map("n", "<leader>to", function()
	local ok, neotest = pcall(require, "neotest")
	if not ok then
		vim.notify("neotest not available", vim.log.levels.WARN)
		return
	end
	neotest.output_panel.toggle()
end, { desc = "Neotest: toggle output panel" })

map("n", "<leader>tO", function()
	local ok, neotest = pcall(require, "neotest")
	if not ok then
		vim.notify("neotest not available", vim.log.levels.WARN)
		return
	end
	neotest.output.open({ position = "float", enter = false })
end, { desc = "Neotest: output (float) for nearest/last test" })

-- Test navigation
map("n", "<leader>t]", function()
	local ok, neotest = pcall(require, "neotest")
	if not ok then
		vim.notify("neotest not available", vim.log.levels.WARN)
		return
	end
	neotest.jump.next({ status = "failed" })
end, { desc = "Neotest: next failed test" })

map("n", "<leader>t[", function()
	local ok, neotest = pcall(require, "neotest")
	if not ok then
		vim.notify("neotest not available", vim.log.levels.WARN)
		return
	end
	neotest.jump.prev({ status = "failed" })
end, { desc = "Neotest: prev failed test" })

----------------------------------------------------------
--------------------- Diagnostics ------------------------
----------------------------------------------------------
map("n", "<leader>x", "<nop>", { desc = "Diagnostics" })

map("n", "<leader>xh", function()
	vim.diagnostic.open_float(nil, { scope = "line", focus = false, border = "rounded" })
end, { desc = "Hover diagnostics (line)" })

map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics (Trouble)" })
map("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "Buffer Diagnostics (Trouble)" })
map("n", "<leader>xL", "<cmd>Trouble loclist toggle<cr>", { desc = "Location List (Trouble)" })
map("n", "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", { desc = "Quickfix List (Trouble)" })

----------------------------------------------------------
------------------------- LSP ----------------------------
----------------------------------------------------------
map("n", "<leader>c", "<nop>", { desc = "Code/LSP" })

map("n", "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>", { desc = "Symbols (Trouble)" })
map(
	"n",
	"<leader>cl",
	"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
	{ desc = "LSP Definitions / references / ... (Trouble)" }
)
map("n", "<leader>cm", function()
	vim.cmd("delmarks!")
	vim.cmd("delmarks A-Z0-9")
	vim.notify("Cleared buffer marks", vim.log.levels.INFO)
end, { desc = "Clear buffer marks" })

-- Goto preview
map("n", "gpd", "<cmd>lua require('goto-preview').goto_preview_definition()<CR>", { desc = "Goto preview definition" })
map(
	"n",
	"gpt",
	"<cmd>lua require('goto-preview').goto_preview_type_definition()<CR>",
	{ desc = "Goto preview type definition" }
)
map(
	"n",
	"gpi",
	"<cmd>lua require('goto-preview').goto_preview_implementation()<CR>",
	{ desc = "Goto preview implementation" }
)
map(
	"n",
	"gpD",
	"<cmd>lua require('goto-preview').goto_preview_declaration()<CR>",
	{ desc = "Goto preview declaration" }
)
map("n", "gpr", "<cmd>lua require('goto-preview').goto_preview_references()<CR>", { desc = "Goto preview references" })
map("n", "gP", "<cmd>lua require('goto-preview').close_all_win()<CR>", { desc = "Close all preview windows" })

----------------------------------------------------------
-------------------- File Explorer -----------------------
----------------------------------------------------------

map("n", "<leader>e", "<cmd>Neotree toggle reveal_force_cwd<cr>", { desc = "Toggle Neo-tree" })
map("n", "<leader>o", "<cmd>Neotree reveal<cr>", { desc = "Reveal Neo-tree" })

----------------------------------------------------------
-------------------- Search/Replace ----------------------
----------------------------------------------------------
map("n", "<leader>s", "<nop>", { desc = "Search/Replace" })

map("n", "<leader>S", '<cmd>lua require("spectre").toggle()<CR>', { desc = "Toggle Spectre" })
map(
	"n",
	"<leader>sw",
	'<cmd>lua require("spectre").open_visual({select_word=true})<CR>',
	{ desc = "Search current word" }
)
map("v", "<leader>sw", '<esc><cmd>lua require("spectre").open_visual()<CR>', { desc = "Search current word" })
map(
	"n",
	"<leader>sp",
	'<cmd>lua require("spectre").open_file_search({select_word=true})<CR>',
	{ desc = "Search on current file" }
)

----------------------------------------------------------
----------------------- Markdown -------------------------
----------------------------------------------------------
map("n", "<leader>m", "<nop>", { desc = "Markdown/Minimap" })

map(
	"n",
	"<leader>mp",
	":rightbelow vsplit | terminal glow %<CR>",
	{ desc = "Markdown preview with glow", silent = true }
)

-- Minimap
map("n", "<leader>mm", "<cmd>Neominimap Toggle<cr>", { desc = "Toggle minimap (global)" })
map("n", "<leader>mf", "<cmd>Neominimap Focus<cr>", { desc = "Focus minimap" })

----------------------------------------------------------
----------------------- AI/Copilot -----------------------
----------------------------------------------------------
map("n", "<leader>a", "<nop>", { desc = "AI/Claude Code" })

-- Copilot (insert mode)
map("i", "<C-l>", 'copilot#Accept("<CR>")', {
	silent = true,
	expr = true,
	replace_keycodes = false,
	desc = "Copilot accept",
})
map("i", "<M-]>", "<Plug>(copilot-next)", { silent = true, desc = "Copilot next" })
map("i", "<M-[>", "<Plug>(copilot-previous)", { silent = true, desc = "Copilot previous" })
map("i", "<C-]>", "<Plug>(copilot-dismiss)", { silent = true, desc = "Copilot dismiss" })

-- Claude Code
map("n", "<leader>ac", "<cmd>ClaudeCode<cr>", { desc = "Toggle Claude" })
map("n", "<leader>af", "<cmd>ClaudeCodeFocus<cr>", { desc = "Focus Claude" })
map("n", "<leader>ar", "<cmd>ClaudeCode --resume<cr>", { desc = "Resume Claude" })
map("n", "<leader>aC", "<cmd>ClaudeCode --continue<cr>", { desc = "Continue Claude" })
map("n", "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", { desc = "Select Claude model" })
map("n", "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", { desc = "Add current buffer" })
map("v", "<leader>as", "<cmd>ClaudeCodeSend<cr>", { desc = "Send to Claude" })
map("n", "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", { desc = "Accept diff" })
map("n", "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", { desc = "Deny diff" })

----------------------------------------------------------
--------------------- Navigation -------------------------
----------------------------------------------------------

-- Treewalker (treesitter-based navigation)
map({ "n", "v" }, "<C-k>", "<cmd>Treewalker Up<cr>", { silent = true })
map({ "n", "v" }, "<C-j>", "<cmd>Treewalker Down<cr>", { silent = true })
map({ "n", "v" }, "<C-h>", "<cmd>Treewalker Left<cr>", { silent = true })
map({ "n", "v" }, "<C-l>", "<cmd>Treewalker Right<cr>", { silent = true })

----------------------------------------------------------
----------------------- Zen Mode -------------------------
----------------------------------------------------------
map("n", "<leader>z", "<nop>", { desc = "Zen" })

map("n", "<leader>z", function()
	require("zen-mode").toggle({
		window = {
			width = 0.85,
		},
	})
end, { desc = "Toggle Zen mode" })

----------------------------------------------------------
-------------------- Command Line ------------------------
----------------------------------------------------------

map("n", "Q", "<cmd>Telescope cmdline<cr>", { desc = "Command line" })
