local neotest = require("neotest")
local zen = require("plugin.zen")
local neotest_ui = require("neotest.lib.ui")

local summary_origin_win
local summary_reopen_pending = false

if not neotest_ui._dotfiles_zen_patched then
	local original_open_buf = neotest_ui.open_buf
	neotest_ui.open_buf = function(bufnr, line, column)
		if zen.open_buf(bufnr, line, column) then
			return
		end

		return original_open_buf(bufnr, line, column)
	end
	neotest_ui._dotfiles_zen_patched = true
end

local function is_valid_win(win)
	return win and vim.api.nvim_win_is_valid(win)
end

local function is_summary_win(win)
	if not is_valid_win(win) then
		return false
	end

	local buf = vim.api.nvim_win_get_buf(win)
	return vim.bo[buf].filetype == "neotest-summary"
end

local function find_summary_win()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if is_summary_win(win) then
			return win
		end
	end
end

local function is_float_win(win)
	return is_valid_win(win) and vim.api.nvim_win_get_config(win).relative ~= ""
end

local function open_summary_window()
	if not zen.is_open() then
		vim.cmd("botright vsplit | vertical resize 50")
		return vim.api.nvim_get_current_win()
	end

	local width = math.max(40, math.floor(vim.o.columns * 0.28))
	local height = math.max(12, math.floor(vim.o.lines * 0.7))
	local col = math.max(1, vim.o.columns - width - 3)
	local row = math.max(1, math.floor((vim.o.lines - height) / 2) - 1)
	local buf = vim.api.nvim_create_buf(false, true)

	return vim.api.nvim_open_win(buf, false, {
		relative = "editor",
		style = "minimal",
		border = "rounded",
		width = width,
		height = height,
		row = row,
		col = col,
		zindex = 60,
	})
end

local function remember_summary_origin()
	local current = vim.api.nvim_get_current_win()
	if not is_summary_win(current) then
		summary_origin_win = current
	end
end

local function focus_summary_window()
	local summary_win = find_summary_win()
	if summary_win then
		vim.api.nvim_set_current_win(summary_win)
	end
end

local function reopen_summary_for_zen(should_focus)
	if summary_reopen_pending then
		return
	end

	local summary_win = find_summary_win()
	if not summary_win then
		return
	end

	local wants_float = zen.is_open()
	if is_float_win(summary_win) == wants_float then
		if should_focus then
			vim.schedule(focus_summary_window)
		end
		return
	end

	summary_reopen_pending = true
	neotest.summary.close()
	vim.schedule(function()
		summary_reopen_pending = false
		neotest.summary.open()
		if should_focus then
			vim.schedule(focus_summary_window)
		end
	end)
end

local function restore_summary_origin()
	local origin = summary_origin_win
	vim.schedule(function()
		if is_valid_win(origin) and not is_summary_win(origin) then
			vim.api.nvim_set_current_win(origin)
		end
	end)
end

local adapters = {}
if pcall(vim.treesitter.language.inspect, "cpp") then
	table.insert(
		adapters,
		require("neotest-gtest").setup({
			debug_adapter = "codelldb",
			is_test_file = function(path)
				if not (path:match("%.cpp$") or path:match("%.cc$") or path:match("%.cxx$")) then
					return false
				end
				return path:match("tests?%.[^/]+$")
					or path:match("_tests?%.[^/]+$")
					or path:match("test_.*%.[^/]+$")
					or path:match(".*_tests?%.[^/]+$")
			end,
		})
	)
end

neotest.setup({
	adapters = adapters,
	summary = {
		open = open_summary_window,
	},
})
local function run_and_redraw(...)
	local args = { ... }
	neotest.run.run(unpack(args))
	-- Neotest places the running sign async; defer a redraw so statuscol picks it up
	vim.defer_fn(function()
		vim.cmd("redrawstatus!")
	end, 50)
end

local function open_summary_and_focus()
	remember_summary_origin()
	neotest.summary.open()
	vim.schedule(focus_summary_window)
end

local function toggle_summary()
	local summary_win = find_summary_win()
	if summary_win then
		if vim.api.nvim_get_current_win() == summary_win then
			neotest.summary.close()
			restore_summary_origin()
		else
			remember_summary_origin()
			vim.api.nvim_set_current_win(summary_win)
		end
		return
	end

	open_summary_and_focus()
end

local function toggle_summary_focus()
	local summary_win = find_summary_win()
	if not summary_win then
		open_summary_and_focus()
		return
	end

	if vim.api.nvim_get_current_win() == summary_win then
		restore_summary_origin()
	else
		remember_summary_origin()
		vim.api.nvim_set_current_win(summary_win)
	end
end

vim.api.nvim_create_autocmd("User", {
	group = vim.api.nvim_create_augroup("dotfiles-neotest-zen-summary", { clear = true }),
	pattern = "DotfilesZenOpen",
	callback = function()
		local summary_win = find_summary_win()
		if not summary_win then
			return
		end

		local toggle = zen.get_last_toggle()
		local should_focus = toggle.from_win == summary_win
			or (is_summary_win(toggle.from_win) and is_valid_win(toggle.from_win))
		reopen_summary_for_zen(should_focus)
	end,
})

vim.api.nvim_create_autocmd("User", {
	group = vim.api.nvim_create_augroup("dotfiles-neotest-zen-summary-close", { clear = true }),
	pattern = "DotfilesZenClose",
	callback = function()
		local summary_win = find_summary_win()
		if not summary_win then
			return
		end

		local toggle = zen.get_last_toggle()
		local should_focus = toggle.from_win == summary_win
			or (is_summary_win(toggle.from_win) and is_valid_win(toggle.from_win))
		reopen_summary_for_zen(should_focus)
	end,
})

local map = vim.keymap.set

map("n", "<leader>t", "<nop>", { desc = "Test" })
map("n", "<leader>tc", "<cmd>ConfigureGtest<cr>", { desc = "Gtest: configure marked tests" })
map("n", "<leader>tn", function()
	run_and_redraw()
end, { desc = "Test: run nearest" })
map("n", "<leader>tf", function()
	run_and_redraw(vim.fn.expand("%"))
end, { desc = "Test: run file" })
map("n", "<leader>ts", toggle_summary, { desc = "Test: toggle summary" })
map("n", "<leader>tt", toggle_summary_focus, { desc = "Test: toggle summary focus" })
map("n", "<leader>to", function()
	neotest.output_panel.toggle()
end, { desc = "Test: toggle output panel" })
map("n", "<leader>tp", function()
	neotest.output.open({ enter = true })
end, { desc = "Test: peek output" })
map("n", "<leader>tq", function()
	neotest.run.stop()
end, { desc = "Test: stop" })
map("n", "<leader>td", function()
	run_and_redraw({ strategy = "dap" })
end, { desc = "Test: debug nearest" })
map("n", "[t", function()
	neotest.jump.prev({ status = "failed" })
end, { desc = "Previous failed test" })
map("n", "]t", function()
	neotest.jump.next({ status = "failed" })
end, { desc = "Next failed test" })
