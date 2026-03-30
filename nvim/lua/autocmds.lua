vim.api.nvim_create_autocmd("FileType", {
	callback = function()
		local lang = vim.treesitter.language.get_lang(vim.bo.filetype)
		if lang and vim.treesitter.language.add(lang) then
			vim.treesitter.start()
		end
	end,
})

vim.api.nvim_create_user_command("LspRestart", function()
	for _, client in ipairs(vim.lsp.get_clients()) do
		client:stop()
	end
	vim.cmd("edit")
end, { desc = "Restart all LSP clients" })
