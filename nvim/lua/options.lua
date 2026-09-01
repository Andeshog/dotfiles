local opt = vim.opt

-- UI
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.termguicolors = true
opt.laststatus = 3
opt.showmode = false
opt.winborder = "rounded"
opt.list = true
opt.listchars = { tab = "  ", trail = "·", nbsp = "␣" }

-- Wrapping and scrolling
opt.wrap = true
opt.linebreak = true
opt.breakindent = true
opt.scrolloff = 8

-- Indentation
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.smartindent = true

-- Editing
opt.clipboard = "unnamedplus"
opt.virtualedit = "block"

-- Search
opt.ignorecase = true
opt.smartcase = true

-- Windows
opt.splitright = true
opt.splitbelow = true
opt.splitkeep = "screen"

-- Files and sessions
opt.undofile = true
opt.confirm = true
opt.sessionoptions =
	{ "blank", "buffers", "curdir", "folds", "help", "tabpages", "winsize", "winpos", "terminal", "localoptions" }
