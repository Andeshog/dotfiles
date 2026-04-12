vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.mapleader = " "
vim.g.maplocalleader = ","

if vim.fn.argc() == 1 and vim.fn.isdirectory(vim.fn.argv(0)) == 1 then
	vim.cmd.cd(vim.fn.argv(0))
end

vim.cmd("packadd nvim.undotree")
vim.keymap.set("n", "<leader>u", require("undotree").open)

vim.treesitter.language.register("bash", "sh")

require("options")
require("keymaps")
require("autocmds")
require("plugins")

--Plugins with config
require("plugin.neo-tree")
require("plugin.catppuccin")
require("plugin.mason")
require("plugin.conform")
require("plugin.lint")
require("plugin.auto-session")
require("plugin.statuscol")
require("plugin.indent_blankline")
require("plugin.telescope")
require("plugin.lualine")
require("plugin.lsp-keymaps")
require("plugin.copilot")
require("plugin.dap")
require("plugin.neotest")
require("plugin.termite")
require("plugin.blink")
require("plugin.codecompanion")

require("render-markdown").setup({
	file_types = { "markdown", "codecompanion" },
	render_modes = true,
	sign = { enabled = false },
})

vim.o.cmdheight = 1
require("vim._core.ui2").enable({
	enable = true,
	msg = {
		targets = {
			[""] = "msg",
			empty = "cmd",
			bufwrite = "msg",
			confirm = "cmd",
			emsg = "pager",
			echo = "msg",
			echomsg = "msg",
			echoerr = "pager",
			completion = "cmd",
			list_cmd = "pager",
			lua_error = "pager",
			lua_print = "msg",
			progress = "pager",
			rpc_error = "pager",
			quickfix = "msg",
			search_cmd = "cmd",
			search_count = "cmd",
			shell_cmd = "pager",
			shell_err = "pager",
			shell_out = "pager",
			shell_ret = "msg",
			undo = "msg",
			verbose = "pager",
			wildlist = "cmd",
			wmsg = "msg",
			typed_cmd = "cmd",
		},
		cmd = {
			height = 0.5,
		},
		dialog = {
			height = 0.5,
		},
		msg = {
			height = 0.3,
			timeout = 5000,
		},
		pager = {
			height = 0.5,
		},
	},
})

require("which-key").setup({
	delay = 800, -- ms before which-key popup shows
})
require("gitsigns").setup({
	current_line_blame = true,
})
require("nvim-autopairs").setup({ fast_wrap = {}, disable_filetype = { "TelescopePrompt", "vim" } })
require("arc").setup({
	hl_backdrop = "Ignore",
	hl_label = "Search",
})
require("treewalker").setup({})
require("plugin.zen").setup()
require("grug-far").setup({})
require("gitlineage").setup()
require("inlinediff").setup({
	colors = {
		InlineDiffAddContext = "#2a3b29",
		InlineDiffAddChange = "#3d5a3a",
		InlineDiffDeleteContext = "#3d2529",
		InlineDiffDeleteChange = "#5a2d33",
	},
})
require("neogit").setup({})
require("fluoride").setup()

vim.cmd.colorscheme("catppuccin")
vim.diagnostic.config({
	virtual_text = false,
	virtual_lines = { current_line = true },
	underline = true,
	severity_sort = true,
	float = {
		border = "rounded",
		source = "if_many",
	},
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "",
			[vim.diagnostic.severity.WARN] = "",
			[vim.diagnostic.severity.INFO] = "",
			[vim.diagnostic.severity.HINT] = "",
		},
	},
})

vim.lsp.enable({ "clangd", "gopls", "bashls", "pyright", "lua_ls" })
