vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.loaded_matchparen = 1 -- This can add lag for larger files
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Core settings & mappings
require("core.options")
require("core.keymaps")
require("core.autocmds")

-- Plugin manager (lazy.nvim) and plugin specs
require("core.lazy")

-- Colorscheme
vim.cmd.colorscheme("catppuccin")

vim.diagnostic.config({
	virtual_text = {
		-- show text to the right of the line
		prefix = "●", -- change symbol if you like
		source = "if_many",
	},
	signs = true,
	underline = true,
	update_in_insert = true,
	severity_sort = true,
})

do
	local orig = vim.notify
	vim.notify = function(msg, level, opts)
		if type(msg) == "string" then
			-- neotest-gtest "killed/cancelled run" noise
			if msg:match("Gtest executable failed to produce a result") then
				return
			end
			-- (optional) also silence the nio coroutine wrapper line
			if msg:match("nvim%-nio") and msg:match("coroutine failed") and msg:match("neotest%-gtest") then
				return
			end
		end
		return orig(msg, level, opts)
	end
end
