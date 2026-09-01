local group = vim.api.nvim_create_augroup("dotfiles", { clear = true })

vim.api.nvim_create_autocmd("ColorScheme", {
	group = group,
	callback = function()
		vim.api.nvim_set_hl(0, "SnippetTabstop", {})
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = group,
	callback = function()
		local ok, lang = pcall(vim.treesitter.language.get_lang, vim.bo.filetype)
		if not ok or not lang then
			return
		end

		local added, has_parser = pcall(vim.treesitter.language.add, lang)
		if added and has_parser then
			pcall(vim.treesitter.start)
		end
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = group,
	callback = function()
		vim.opt_local.formatoptions:remove({ "r", "o" })
	end,
})

vim.api.nvim_create_autocmd({ "WinEnter", "BufWinEnter" }, {
	group = group,
	callback = function()
		local ft = vim.bo.filetype
		if ft == "neo-tree" or ft == "neo-tree-popup" then
			return
		end
		if vim.bo.buftype ~= "terminal" then
			vim.wo.cursorline = true
		end
	end,
})

vim.api.nvim_create_autocmd("WinLeave", {
	group = group,
	callback = function()
		local ft = vim.bo.filetype
		if ft == "neo-tree" or ft == "neo-tree-popup" then
			return
		end
		vim.wo.cursorline = false
	end,
})

vim.api.nvim_create_autocmd("LspProgress", {
	group = group,
	callback = function(ev)
		local value = ev.data.params.value
		vim.api.nvim_echo({ { value.message or "Done" } }, false, {
			id = "lsp." .. ev.data.client_id,
			kind = "progress",
			source = "vim.lsp",
			title = value.title,
			status = value.kind ~= "end" and "running" or "success",
			percent = value.percentage,
		})
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = group,
	pattern = "neo-tree-popup",
	callback = function()
		vim.opt_local.cursorline = false
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = group,
	pattern = "msg",
	callback = function()
		local ok, ui2 = pcall(require, "vim._core.ui2")
		if not ok then
			return
		end

		local win = ui2.wins and ui2.wins.msg
		if win and vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_set_option_value(
				"winhighlight",
				"Normal:NormalFloat,FloatBorder:FloatBorder",
				{ scope = "local", win = win }
			)
		end
	end,
})
