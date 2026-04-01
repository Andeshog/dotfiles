local M = {}

local last_editor_win
local last_toggle = {}

local function is_valid_win(win)
	return win and vim.api.nvim_win_is_valid(win)
end

local function is_float(win)
	return is_valid_win(win) and vim.api.nvim_win_get_config(win).relative ~= ""
end

local function is_editor_win(win)
	if not is_valid_win(win) or is_float(win) then
		return false
	end

	local buf = vim.api.nvim_win_get_buf(win)
	return vim.bo[buf].buftype == ""
end

local function find_editor_win()
	if is_editor_win(last_editor_win) then
		return last_editor_win
	end

	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if is_editor_win(win) then
			return win
		end
	end
end

local function get_view()
	local ok, view = pcall(require, "zen-mode.view")
	if not ok then
		return
	end

	return view
end

local function sync_zen_to_win(win)
	local view = get_view()
	if not view or not view.is_open() or not is_valid_win(view.win) or not is_editor_win(win) then
		return
	end

	local buf = vim.api.nvim_win_get_buf(win)
	local cursor = vim.api.nvim_win_get_cursor(win)

	last_editor_win = win
	view.parent = win

	if vim.api.nvim_win_get_buf(view.win) ~= buf then
		vim.api.nvim_win_set_buf(view.win, buf)
	end

	pcall(vim.api.nvim_win_set_cursor, view.win, cursor)
	vim.api.nvim_set_current_win(view.win)
	view.fix_hl(view.win)
	view.fix_layout()
end

local function patch_view()
	local view = get_view()
	if not view or view._dotfiles_buffer_sync then
		return
	end

	view.on_win_enter = function()
		local win = vim.api.nvim_get_current_win()

		if win ~= view.win and is_editor_win(win) then
			vim.schedule(function()
				if is_valid_win(win) then
					sync_zen_to_win(win)
				end
			end)
			return
		end

		if win ~= view.win and not is_float(win) then
			vim.defer_fn(function()
				if M.is_open() and vim.api.nvim_get_current_win() ~= view.win then
					view.close()
				end
			end, 10)
		end
	end

	view._dotfiles_buffer_sync = true
end

function M.is_open()
	local view = get_view()
	return view and view.is_open()
end

function M.get_last_toggle()
	return last_toggle
end

function M.open_buf(bufnr, line, column)
	local view = get_view()
	if not view or not view.is_open() or not is_valid_win(view.win) then
		return false
	end

	local target = is_editor_win(view.parent) and view.parent or find_editor_win()
	if target then
		last_editor_win = target
		view.parent = target
		if is_valid_win(target) then
			vim.api.nvim_win_set_buf(target, bufnr)
			if line then
				pcall(vim.api.nvim_win_set_cursor, target, { line + 1, column or 0 })
			end
		end
	end

	vim.api.nvim_win_set_buf(view.win, bufnr)
	if line then
		pcall(vim.api.nvim_win_set_cursor, view.win, { line + 1, column or 0 })
	end
	vim.api.nvim_set_current_win(view.win)
	view.fix_hl(view.win)
	view.fix_layout()
	return true
end

function M.toggle()
	local current = vim.api.nvim_get_current_win()
	last_toggle = {
		from_win = current,
		opening = not M.is_open(),
	}

	if M.is_open() then
		require("zen-mode").toggle()
		return
	end

	if not is_editor_win(current) then
		local editor_win = find_editor_win()
		if not editor_win then
			vim.notify("No editor window available for Zen Mode", vim.log.levels.INFO, { title = "Zen" })
			return
		end
		vim.api.nvim_set_current_win(editor_win)
		current = editor_win
	end

	last_editor_win = current
	require("zen-mode").toggle()
end

function M.setup()
	require("zen-mode").setup({
		window = {
			width = 1,
		},
		on_open = function()
			local view = get_view()
			if view and is_editor_win(view.parent) then
				last_editor_win = view.parent
			end
			vim.api.nvim_exec_autocmds("User", {
				pattern = "DotfilesZenOpen",
			})
		end,
		on_close = function()
			vim.api.nvim_exec_autocmds("User", {
				pattern = "DotfilesZenClose",
			})
		end,
	})

	patch_view()

	vim.api.nvim_create_autocmd("WinEnter", {
		group = vim.api.nvim_create_augroup("dotfiles-zen-track-editor", { clear = true }),
		callback = function()
			local win = vim.api.nvim_get_current_win()
			if not M.is_open() and is_editor_win(win) then
				last_editor_win = win
			end
		end,
	})

	vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
		group = vim.api.nvim_create_augroup("dotfiles-zen-follow-buffer", { clear = true }),
		callback = function()
			if not M.is_open() then
				return
			end

			local win = vim.api.nvim_get_current_win()
			if is_editor_win(win) then
				vim.schedule(function()
					if is_valid_win(win) then
						sync_zen_to_win(win)
					end
				end)
			end
		end,
	})
end

return M
