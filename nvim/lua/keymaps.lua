local map = vim.keymap.set
local opts = { silent = true }

-- Neo-tree
map("n", "<leader>o", ":Neotree reveal<CR>", opts)

-- Treewalker

-- Save
map("n", "<C-S>", ":w<CR>", opts)
map("i", "<C-S>", function()
	vim.cmd("w")
end, opts)

-- Quit
map("n", "q", "<cmd>q<cr>", { desc = "Quit window" })

-- Delete to black hole register (don't pollute clipboard)
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
map("n", "<Up>", "<C-w>k", opts)
map("n", "<Down>", "<C-w>j", opts)
map("n", "<Left>", "<C-w>h", opts)
map("n", "<Right>", "<C-w>l", opts)

-- Splits
map("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
map("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
map("n", "<leader>we", "<C-w>=", { desc = "Equalize window sizes" })
map("n", "<leader>wc", "<cmd>close<cr>", { desc = "Close window" })
