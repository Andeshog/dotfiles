vim.api.nvim_create_autocmd("FileType", {
	callback = function()
		local lang = vim.treesitter.language.get_lang(vim.bo.filetype)
		if lang and vim.treesitter.language.add(lang) then
			vim.treesitter.start()
		end
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	callback = function()
		vim.opt_local.formatoptions:remove({ "r", "o" })
	end,
})

vim.api.nvim_create_autocmd({ "WinEnter", "BufWinEnter" }, {
	callback = function()
		if vim.bo.buftype ~= "terminal" then
			vim.wo.cursorline = true
		end
	end,
})

vim.api.nvim_create_autocmd("WinLeave", {
	callback = function()
		vim.wo.cursorline = false
	end,
})

vim.api.nvim_create_autocmd("LspProgress", {
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
