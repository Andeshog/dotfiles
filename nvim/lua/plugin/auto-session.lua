local ignored_filetypes = {
	checkhealth = true,
	termite = true,
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

local function enable_auto_save()
	require("auto-session.config").auto_save = true
end

require("auto-session").setup({
	auto_restore = false,
	auto_save = false,
	args_allow_files_auto_save = false,
	args_allow_single_directory = true,
	close_filetypes_on_save = {
		"checkhealth",
		"termite",
	},
	pre_save_cmds = { close_session_ignored_windows },
	post_restore_cmds = { enable_auto_save },
	post_save_cmds = { enable_auto_save },
	session_lens = { picker = "fzf" },
})

vim.keymap.set("n", "<leader>Sr", "<cmd>AutoSession restore<cr>", { desc = "Restore session (cwd)" })
vim.keymap.set("n", "<leader>Sf", "<cmd>AutoSession search<cr>", { desc = "Find session" })
vim.keymap.set("n", "<leader>Sd", "<cmd>AutoSession delete<cr>", { desc = "Delete session (cwd)" })
