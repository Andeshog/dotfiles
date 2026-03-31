local M = {}

local function current_loclist_winid()
	return vim.fn.getloclist(0, { winid = 0 }).winid
end

local function current_qflist_winid()
	return vim.fn.getqflist({ winid = 0 }).winid
end

function M.open_float()
	vim.diagnostic.open_float(nil, {
		scope = "line",
		focus = false,
		border = "rounded",
		source = "if_many",
	})
end

function M.toggle_buffer_list()
	if current_loclist_winid() ~= 0 then
		vim.cmd.lclose()
		return
	end

	vim.diagnostic.setloclist({
		open = true,
		title = "Buffer Diagnostics",
	})
end

function M.toggle_workspace_list()
	if current_qflist_winid() ~= 0 then
		vim.cmd.cclose()
		return
	end

	vim.diagnostic.setqflist({
		open = true,
		title = "Workspace Diagnostics",
	})
end

function M.close_lists()
	if current_loclist_winid() ~= 0 then
		vim.cmd.lclose()
	end

	if current_qflist_winid() ~= 0 then
		vim.cmd.cclose()
	end
end

function M.toggle_virtual_lines()
	local current = vim.diagnostic.config().virtual_lines
	if current then
		vim.diagnostic.config({ virtual_lines = false })
		vim.notify("Diagnostic virtual lines: OFF")
	else
		vim.diagnostic.config({ virtual_lines = { current_line = true } })
		vim.notify("Diagnostic virtual lines: ON")
	end
end

function M.goto_prev(opts)
	return function()
		vim.diagnostic.jump(vim.tbl_extend("force", { count = -1, float = true }, opts or {}))
	end
end

function M.goto_next(opts)
	return function()
		vim.diagnostic.jump(vim.tbl_extend("force", { count = 1, float = true }, opts or {}))
	end
end

function M.toggle_underline()
	local current = vim.diagnostic.config().underline
	if current then
		vim.diagnostic.config({ underline = false })
		vim.notify("Diagnostic underline: OFF")
	else
		vim.diagnostic.config({ underline = true })
		vim.notify("Diagnostic underline: ON")
	end
end

function M.toggle()
	if vim.diagnostic.is_enabled() then
		vim.diagnostic.enable(false)
		vim.notify("Diagnostics: OFF")
	else
		vim.diagnostic.enable(true)
		vim.notify("Diagnostics: ON")
	end
end

return M
