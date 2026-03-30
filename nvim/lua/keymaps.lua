local map = vim.keymap.set
local opts = { silent = true }

-- Neo-tree
map("n", "<leader>o", ":Neotree reveal<CR>", opts)
