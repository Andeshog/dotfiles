local dap = require("dap")
local dapview = require("dap-view")
local widgets = require("dap.ui.widgets")

vim.fn.sign_define("DapBreakpoint", {
	text = "●",
	texthl = "DiagnosticSignError",
	linehl = "",
	numhl = "",
})

vim.fn.sign_define("DapBreakpointCondition", {
	text = "◆",
	texthl = "DiagnosticSignWarn",
	linehl = "",
	numhl = "",
})

vim.fn.sign_define("DapStopped", {
	text = "▶",
	texthl = "DiagnosticSignInfo",
	linehl = "CursorLine",
	numhl = "",
})

-----------------------------------------------------------
-- Adapter: codelldb (C/C++)
-----------------------------------------------------------
local mason = vim.fn.stdpath("data") .. "/mason"
local codelldb_path = mason .. "/packages/codelldb/extension/adapter/codelldb"

dap.adapters.codelldb = {
	type = "server",
	port = "${port}",
	executable = {
		command = codelldb_path,
		args = { "--port", "${port}" },
	},
}

-----------------------------------------------------------
-- Launch target
-----------------------------------------------------------
local launch = require("custom_plugins.launch_target")

local function warn_if_no_debug_info(program)
	if launch.has_debug_info(program) == false then
		local msg =
			"DAP: %s has no debug info -- breakpoints will be rejected (R).\nRebuild with -DCMAKE_BUILD_TYPE=Debug"
		vim.notify(msg:format(vim.fn.fnamemodify(program, ":t")), vim.log.levels.WARN)
	end
end

dap.configurations.cpp = {
	{
		name = "Launch",
		type = "codelldb",
		request = "launch",
		program = function()
			local target = launch.ensure()
			if not target then
				return dap.ABORT
			end
			warn_if_no_debug_info(target.program)
			return target.program
		end,
		args = function()
			local target = launch.ensure()
			return target and target.args or {}
		end,
		cwd = "${workspaceFolder}",
		stopOnEntry = false,
		runInTerminal = true,
	},
}

dap.configurations.c = dap.configurations.cpp

-----------------------------------------------------------
-- dap-view & virtual text
-----------------------------------------------------------
dapview.setup({
	winbar = {
		show = true,
		controls = { enabled = true },
	},
	windows = { position = "below" },
	auto_toggle = false,
})

-- Hide neotest panels and neo-tree when debugging starts
dap.listeners.after.event_initialized["dapview_neotest"] = function()
	local ok, neotest = pcall(require, "neotest")
	if ok then
		pcall(function()
			neotest.summary.close()
		end)
		pcall(function()
			neotest.output_panel.close()
		end)
	end
	pcall(vim.cmd, "Neotree close")
end

-- Ensure DAP jumps to a code window, not the dap-view (which has winfixbuf)
dap.listeners.before.event_stopped["focus_code_window"] = function()
	if vim.wo.winfixbuf then
		for _, win in ipairs(vim.api.nvim_list_wins()) do
			if not vim.wo[win].winfixbuf then
				vim.api.nvim_set_current_win(win)
				return
			end
		end
	end
end

-----------------------------------------------------------
-- DAP keymaps
-----------------------------------------------------------
local map = vim.keymap.set

map("n", "<leader>d", "<nop>", { desc = "Debug" })

local debug_filetype

local function configured_filetype()
	for _, ft in ipairs({ vim.bo.filetype, debug_filetype }) do
		if ft and next(dap.configurations[ft] or {}) then
			return ft
		end
	end

	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(bufnr) then
			local ft = vim.bo[bufnr].filetype
			if next(dap.configurations[ft] or {}) then
				return ft
			end
		end
	end
end

local function continue()
	if dap.session() then
		dap.continue()
		return
	end

	local ft = configured_filetype()
	if not ft then
		vim.notify("DAP: no configuration matches any open buffer", vim.log.levels.WARN)
		return
	end

	local configs = dap.configurations[ft]
	if #configs == 1 then
		dap.run(configs[1], { filetype = ft })
		return
	end

	vim.ui.select(configs, {
		prompt = "Configuration: ",
		format_item = function(config)
			return config.name
		end,
	}, function(choice)
		if choice then
			dap.run(choice, { filetype = ft })
		end
	end)
end

local session_keymaps = {
	{
		name = "Launch",
		{
			"n",
			"<leader>dP",
			function()
				local target = launch.prompt()
				if target then
					vim.notify("DAP target: " .. target.program)
				end
			end,
			"Set executable + args",
		},
	},
	{
		name = "Stepping",
		{ "n", "<M-Right>", continue, "Continue / start running" },
		{ "n", "<M-Up>", dap.step_over, "Step over" },
		{ "n", "<M-Down>", dap.step_into, "Step into" },
		{ "n", "<M-Left>", dap.step_out, "Step out" },
		{ "n", "<leader>dc", dap.run_to_cursor, "Run to cursor" },
	},
	{
		name = "Breakpoints",
		{ "n", "<leader>db", dap.toggle_breakpoint, "Toggle breakpoint" },
		{
			"n",
			"<leader>dB",
			function()
				dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
			end,
			"Conditional breakpoint",
		},
		{
			"n",
			"<leader>dl",
			function()
				dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
			end,
			"Logpoint",
		},
		{
			"n",
			"<leader>da",
			function()
				local cond = vim.fn.input("Condition (empty for none): ")
				local hit = vim.fn.input("Hit count (empty for none): ")
				local log = vim.fn.input("Log message (empty for none): ")
				dap.set_breakpoint((cond ~= "" and cond) or nil, (hit ~= "" and hit) or nil, (log ~= "" and log) or nil)
			end,
			"Advanced breakpoint (cond/hit/log)",
		},
		{
			"n",
			"<leader>dx",
			function()
				dap.set_exception_breakpoints({ "cpp_throw", "cpp_catch" })
				vim.notify("DAP: break on C++ throw/catch enabled")
			end,
			"Break on C++ throw/catch",
		},
		{
			"n",
			"<leader>dC",
			function()
				dap.clear_breakpoints()
				vim.notify("DAP: cleared all breakpoints")
			end,
			"Clear all breakpoints",
		},
	},
	{
		name = "Inspection",
		{ { "n", "v" }, "<leader>dh", widgets.hover, "Hover / evaluate under cursor" },
		{ { "n", "v" }, "<leader>dp", widgets.preview, "Preview variable" },
		{
			"n",
			"<leader>df",
			function()
				widgets.centered_float(widgets.frames)
			end,
			"Show frames",
		},
		{
			"n",
			"<leader>ds",
			function()
				widgets.centered_float(widgets.scopes)
			end,
			"Show scopes",
		},
		{
			"n",
			"<leader>dE",
			function()
				widgets.centered_float(widgets.expression)
			end,
			"Show expressions",
		},
	},
	{
		name = "Session",
		{ "n", "<leader>dR", dap.restart, "Restart session" },
		{
			"n",
			"<leader>dr",
			function()
				dap.repl.open({}, "belowright split")
			end,
			"Open REPL (split)",
		},
		{
			"n",
			"<leader>dq",
			function()
				dap.terminate()
				dap.disconnect({ terminateDebuggee = true })
			end,
			"Stop program (stay in debug mode)",
		},
		{ "n", "<leader>dd", nil, "Exit debug mode (closes view)" },
	},
}

-----------------------------------------------------------
-- Cheatsheet
-----------------------------------------------------------
local help_ns = vim.api.nvim_create_namespace("dap-cheatsheet")

local function build_help_lines()
	local width = 0
	for _, group in ipairs(session_keymaps) do
		for _, km in ipairs(group) do
			width = math.max(width, #km[2])
		end
	end

	local lines, marks = {}, {}

	local target = launch.get()
	table.insert(lines, "Target")
	table.insert(marks, { #lines - 1, 0, -1, "Title" })
	local program = target.program and vim.fn.fnamemodify(target.program, ":~") or "(unset -- <leader>dP)"
	table.insert(lines, "  " .. program)
	if target.args and #target.args > 0 then
		table.insert(lines, "  args: " .. table.concat(target.args, " "))
	end

	for _, group in ipairs(session_keymaps) do
		table.insert(lines, "")

		table.insert(lines, group.name)
		table.insert(marks, { #lines - 1, 0, -1, "Title" })

		for _, km in ipairs(group) do
			local lhs = km[2]
			table.insert(lines, string.format("  %s  %s", lhs .. (" "):rep(width - #lhs), km[4]))
			table.insert(marks, { #lines - 1, 2, 2 + #lhs, "Special" })
		end
	end

	table.insert(lines, "")
	table.insert(lines, "q / <Esc> to close")
	table.insert(marks, { #lines - 1, 0, -1, "Comment" })

	return lines, marks
end

local function show_help()
	local lines, marks = build_help_lines()

	local width = 0
	for _, line in ipairs(lines) do
		width = math.max(width, vim.fn.strdisplaywidth(line))
	end
	width = math.min(width + 2, vim.o.columns - 4)
	local height = math.min(#lines, vim.o.lines - 6)

	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

	for _, m in ipairs(marks) do
		vim.api.nvim_buf_set_extmark(buf, help_ns, m[1], m[2], {
			end_col = m[3] == -1 and #lines[m[1] + 1] or m[3],
			hl_group = m[4],
		})
	end

	vim.bo[buf].modifiable = false
	vim.bo[buf].bufhidden = "wipe"

	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = math.max(0, math.floor((vim.o.lines - height) / 2) - 1),
		col = math.floor((vim.o.columns - width) / 2),
		style = "minimal",
		border = "rounded",
		title = " Debug mode ",
		title_pos = "center",
	})

	vim.wo[win].wrap = false
	vim.wo[win].cursorline = false

	local function close()
		if vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_close(win, true)
		end
	end

	for _, lhs in ipairs({ "q", "<Esc>", "<CR>", "<leader>d?" }) do
		map("n", lhs, close, { buffer = buf, nowait = true, silent = true, desc = "Close cheatsheet" })
	end

	vim.api.nvim_create_autocmd("WinLeave", { buffer = buf, once = true, callback = close })
end

table.insert(session_keymaps[#session_keymaps], { "n", "<leader>d?", show_help, "Show this cheatsheet" })

-----------------------------------------------------------
-- Debug mode
-----------------------------------------------------------
local session_augroup = vim.api.nvim_create_augroup("dap-session-keymaps", { clear = true })
local mapped_buffers = {}

local function each_keymap(fn)
	for _, group in ipairs(session_keymaps) do
		for _, km in ipairs(group) do
			if km[3] then
				fn(km)
			end
		end
	end
end

local function set_buf_keymaps(bufnr)
	if mapped_buffers[bufnr] or not vim.api.nvim_buf_is_valid(bufnr) then
		return
	end

	each_keymap(function(km)
		map(km[1], km[2], km[3], { buffer = bufnr, desc = "DAP: " .. km[4], silent = true })
	end)

	mapped_buffers[bufnr] = true
end

local function clear_buf_keymaps(bufnr)
	if vim.api.nvim_buf_is_valid(bufnr) then
		each_keymap(function(km)
			local modes = type(km[1]) == "table" and km[1] or { km[1] }
			for _, mode in ipairs(modes) do
				pcall(vim.keymap.del, mode, km[2], { buffer = bufnr })
			end
		end)
	end

	mapped_buffers[bufnr] = nil
end

local debug_mode = false

local function enter_debug_mode()
	if debug_mode then
		return
	end
	debug_mode = true
	debug_filetype = next(dap.configurations[vim.bo.filetype] or {}) and vim.bo.filetype or debug_filetype

	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(bufnr) then
			set_buf_keymaps(bufnr)
		end
	end

	vim.api.nvim_create_autocmd("BufEnter", {
		group = session_augroup,
		callback = function(ev)
			set_buf_keymaps(ev.buf)
		end,
	})

	local origin = vim.api.nvim_get_current_win()
	dapview.open()
	if vim.api.nvim_win_is_valid(origin) then
		vim.api.nvim_set_current_win(origin)
	end
end

local function exit_debug_mode()
	if not debug_mode then
		return
	end
	debug_mode = false

	vim.api.nvim_clear_autocmds({ group = session_augroup })

	for bufnr in pairs(vim.deepcopy(mapped_buffers)) do
		clear_buf_keymaps(bufnr)
	end

	if next(dap.sessions()) then
		dap.terminate()
		dap.disconnect({ terminateDebuggee = true })
	end

	pcall(dapview.close, true)
end

map("n", "<leader>dd", function()
	if debug_mode then
		exit_debug_mode()
	else
		enter_debug_mode()
	end
end, { desc = "DAP: toggle debug mode (view + keymaps)", silent = true })

dap.listeners.after.event_initialized["debug_mode"] = enter_debug_mode
