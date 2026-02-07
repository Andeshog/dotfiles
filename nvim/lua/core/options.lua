local opt = vim.opt

-- Basic settings
opt.encoding = "utf-8"

opt.mouse = "a"

opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.splitright = true

opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.smartindent = true

opt.laststatus = 3

-- Use system clipboard for yanks etc
opt.clipboard = "unnamedplus"

opt.showmode = false

vim.cmd("syntax on")
vim.cmd("filetype plugin indent on")
opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()"
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldenable = true
