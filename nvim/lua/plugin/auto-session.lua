local ignored_filetypes = {
	dashboard = true,
	checkhealth = true,
	termite = true,
	["copilot-chat"] = true,
	codecompanion = true,
	Avante = true,
}

local function close_session_ignored_windows()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)

		if vim.api.nvim_buf_is_valid(buf) then
			local buftype = vim.bo[buf].buftype
			local filetype = vim.bo[buf].filetype

			if buftype == "terminal" or ignored_filetypes[filetype] then
				pcall(vim.api.nvim_win_close, win, true)
			end
		end
	end

	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf) then
			local buftype = vim.bo[buf].buftype
			local filetype = vim.bo[buf].filetype

			if buftype == "terminal" or ignored_filetypes[filetype] then
				pcall(vim.api.nvim_buf_delete, buf, { force = true })
			end
		end
	end

	return true
end

require("auto-session").setup({
	args_allow_files_auto_save = true,
	bypass_save_filetypes = { "dashboard" },
	close_filetypes_on_save = { "checkhealth", "dashboard", "termite", "copilot-chat", "codecompanion", "Avante" },
	pre_save_cmds = { close_session_ignored_windows },
})
