local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.splitright = true
opt.splitbelow = true
opt.scrolloff = 8
opt.wrap = false
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.smartindent = true
opt.laststatus = 3
opt.ignorecase = true
opt.smartcase = true
opt.termguicolors = true
opt.sessionoptions =
	{ "blank", "buffers", "curdir", "folds", "help", "tabpages", "winsize", "winpos", "terminal", "localoptions" }

-- Use system clipboard for yanks etc
opt.clipboard = "unnamedplus"
opt.showmode = false
-- TODO: Move fold settings to autocommand
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"

opt.completeopt = { "menuone", "noselect", "popup" }

-- UI borders
vim.o.winborder = "rounded"
