local M = {}

local config = {
	ignored_filetypes = {
		dashboard = true,
		checkhealth = true,
		termite = true,
		codecompanion = true,
	},
}

local history = {}
local index = 0
local navigating = false

local function is_trackable(bufnr)
	if not vim.api.nvim_buf_is_valid(bufnr) then
		return false
	end
	if vim.bo[bufnr].buftype ~= "" then
		return false
	end
	if not vim.bo[bufnr].buflisted then
		return false
	end
	if config.ignored_filetypes[vim.bo[bufnr].filetype] then
		return false
	end
	return true
end

local function prune()
	local kept = {}
	local new_index = 0
	for i, bufnr in ipairs(history) do
		if vim.api.nvim_buf_is_valid(bufnr) and vim.fn.buflisted(bufnr) == 1 then
			table.insert(kept, bufnr)
			if i <= index then
				new_index = #kept
			end
		end
	end
	history = kept
	index = math.min(new_index, #history)
end

local function push(bufnr)
	if navigating then
		return
	end
	if not is_trackable(bufnr) then
		return
	end
	if history[index] == bufnr then
		return
	end
	for i = #history, index + 1, -1 do
		table.remove(history, i)
	end
	table.insert(history, bufnr)
	index = #history
end

local function go(delta)
	prune()
	local target = index + delta
	if target < 1 or target > #history then
		return
	end
	index = target
	navigating = true
	vim.api.nvim_set_current_buf(history[index])
	navigating = false
end

function M.prev()
	go(-1)
end

function M.next()
	go(1)
end

function M.setup(opts)
	opts = opts or {}
	if opts.ignored_filetypes then
		config.ignored_filetypes = opts.ignored_filetypes
	end
end

vim.api.nvim_create_autocmd("BufEnter", {
	callback = function(ev)
		push(ev.buf)
	end,
})

return M
