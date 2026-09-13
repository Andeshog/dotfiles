local neotest = require("neotest")

local summary_origin_win

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

local function open_summary_window()
	vim.cmd("botright vsplit | vertical resize 50")
	return vim.api.nvim_get_current_win()
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
			mappings = { configure = "C" },
		})
	)
end

local ignored_dirs = { build = true, install = true, log = true, _deps = true, [".cache"] = true, [".git"] = true }

neotest.setup({
	adapters = adapters,
	discovery = {
		filter_dir = function(name)
			return not ignored_dirs[name]
		end,
	},
	summary = {
		open = open_summary_window,
	},
})

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

local function pick_test()
	local nio = require("nio")
	nio.run(function()
		-- Starts the neotest client if needed and waits for discovery
		local root = neotest.run.get_tree_from_args({ suite = true })
		nio.scheduler()
		if not root then
			return vim.notify("No tests found", vim.log.levels.WARN)
		end

		local entries, by_entry = {}, {}
		for _, node in root:iter_nodes() do
			local data = node:data()
			if data.type == "test" then
				local name = data.id:match("::(.*)$"):gsub("::", ".")
				local entry = ("%s:%d:1: %s"):format(vim.fn.fnamemodify(data.path, ":."), data.range[1] + 1, name)
				entries[#entries + 1] = entry
				by_entry[entry] = data
			end
		end
		if #entries == 0 then
			return vim.notify("No tests found", vim.log.levels.WARN)
		end
		table.sort(entries)

		require("fzf-lua").fzf_exec(entries, {
			prompt = "Tests> ",
			previewer = "builtin",
			fzf_opts = { ["--no-multi"] = true, ["--delimiter"] = ":", ["--nth"] = "4.." },
			actions = {
				["enter"] = function(selected)
					local data = by_entry[selected[1]]
					vim.cmd.edit(data.path)
					vim.api.nvim_win_set_cursor(0, { data.range[1] + 1, data.range[2] })
				end,
			},
		})
	end)
end

local map = vim.keymap.set

map("n", "<leader>t", "<nop>", { desc = "Test" })
map("n", "<leader>tn", function()
	neotest.run.run()
end, { desc = "Test: run nearest" })
map("n", "<leader>tf", function()
	neotest.run.run(vim.fn.expand("%"))
end, { desc = "Test: run file" })
map("n", "<leader>ta", function()
	neotest.run.run(vim.uv.cwd())
end, { desc = "Test: run all" })
map("n", "<leader>tl", function()
	neotest.run.run_last()
end, { desc = "Test: run last" })
map("n", "<leader>ft", pick_test, { desc = "Find test" })
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
	neotest.run.run({ strategy = "dap" })
end, { desc = "Test: debug nearest" })
map("n", "[t", function()
	neotest.jump.prev({ status = "failed" })
end, { desc = "Previous failed test" })
map("n", "]t", function()
	neotest.jump.next({ status = "failed" })
end, { desc = "Next failed test" })
