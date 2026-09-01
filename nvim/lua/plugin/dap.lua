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

dap.configurations.cpp = {
	{
		name = "Launch (prompt)",
		type = "codelldb",
		request = "launch",
		program = function()
			return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
		end,
		cwd = "${workspaceFolder}",
		stopOnEntry = false,
		args = function()
			local input = vim.fn.input("Args: ")
			return input == "" and {} or vim.split(input, "%s+")
		end,
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
	-- Opening/closing the view is driven by <leader>dd (debug mode) instead,
	-- so the view survives a session ending and breakpoints can be adjusted.
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
--
-- <leader>dd is the only global mapping: it toggles "debug mode",
-- which opens dap-view and installs every other DAP mapping as
-- buffer-local. Buffer-local means they shadow global mappings
-- instead of replacing them -- teardown can never delete a global.
--
-- Debug mode is deliberately not tied to session lifetime: it stays
-- on after a session ends so breakpoints can be adjusted and the
-- program re-run with <M-Right> (continue).
-----------------------------------------------------------
local map = vim.keymap.set

map("n", "<leader>d", "<nop>", { desc = "Debug" })

local session_keymaps = {
	-- Stepping
	{ "n", "<M-Right>", dap.continue, "DAP: continue" },
	{ "n", "<M-Up>", dap.step_over, "DAP: step over" },
	{ "n", "<M-Down>", dap.step_into, "DAP: step into" },
	{ "n", "<M-Left>", dap.step_out, "DAP: step out" },
	{ "n", "<leader>dc", dap.run_to_cursor, "DAP: run to cursor" },

	-- Breakpoints
	{ "n", "<leader>db", dap.toggle_breakpoint, "DAP: toggle breakpoint" },
	{
		"n",
		"<leader>dB",
		function()
			dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
		end,
		"DAP: conditional breakpoint",
	},
	{
		"n",
		"<leader>dl",
		function()
			dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
		end,
		"DAP: logpoint",
	},
	{
		"n",
		"<leader>d?",
		function()
			local cond = vim.fn.input("Condition (empty for none): ")
			local hit = vim.fn.input("Hit count (empty for none): ")
			local log = vim.fn.input("Log message (empty for none): ")
			dap.set_breakpoint((cond ~= "" and cond) or nil, (hit ~= "" and hit) or nil, (log ~= "" and log) or nil)
		end,
		"DAP: set breakpoint (cond/hit/log)",
	},
	{
		"n",
		"<leader>dC",
		function()
			dap.clear_breakpoints()
			vim.notify("DAP: cleared all breakpoints")
		end,
		"DAP: clear all breakpoints",
	},
	{
		"n",
		"<leader>dx",
		function()
			dap.set_exception_breakpoints({ "cpp_throw", "cpp_catch" })
			vim.notify("DAP: break on C++ throw/catch enabled")
		end,
		"DAP: break on exceptions (C++)",
	},

	-- Inspection
	{ { "n", "v" }, "<leader>dh", widgets.hover, "DAP: hover / evaluate" },
	{ { "n", "v" }, "<leader>dp", widgets.preview, "DAP: preview variable" },
	{
		"n",
		"<leader>df",
		function()
			widgets.centered_float(widgets.frames)
		end,
		"DAP: show frames",
	},
	{
		"n",
		"<leader>ds",
		function()
			widgets.centered_float(widgets.scopes)
		end,
		"DAP: show scopes",
	},
	{
		"n",
		"<leader>dE",
		function()
			widgets.centered_float(widgets.expression)
		end,
		"DAP: show expressions",
	},

	-- Session control
	{ "n", "<leader>dR", dap.restart, "DAP: restart session" },
	{
		"n",
		"<leader>dr",
		function()
			dap.repl.open({}, "belowright split")
		end,
		"DAP: open REPL (split)",
	},
	{
		"n",
		"<leader>dq",
		function()
			dap.terminate()
			dap.disconnect({ terminateDebuggee = true })
			pcall(dapview.close)
		end,
		"DAP: stop",
	},
}

local session_augroup = vim.api.nvim_create_augroup("dap-session-keymaps", { clear = true })
local mapped_buffers = {}

local function set_buf_keymaps(bufnr)
	if mapped_buffers[bufnr] or not vim.api.nvim_buf_is_valid(bufnr) then
		return
	end

	for _, km in ipairs(session_keymaps) do
		map(km[1], km[2], km[3], { buffer = bufnr, desc = km[4], silent = true })
	end

	mapped_buffers[bufnr] = true
end

local function clear_buf_keymaps(bufnr)
	if vim.api.nvim_buf_is_valid(bufnr) then
		for _, km in ipairs(session_keymaps) do
			local modes = type(km[1]) == "table" and km[1] or { km[1] }
			for _, mode in ipairs(modes) do
				pcall(vim.keymap.del, mode, km[2], { buffer = bufnr })
			end
		end
	end

	mapped_buffers[bufnr] = nil
end

local debug_mode = false

local function enter_debug_mode()
	if debug_mode then
		return
	end
	debug_mode = true

	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(bufnr) then
			set_buf_keymaps(bufnr)
		end
	end

	-- Buffers opened later (stepping into a new file) get them too
	vim.api.nvim_create_autocmd("BufEnter", {
		group = session_augroup,
		callback = function(ev)
			set_buf_keymaps(ev.buf)
		end,
	})

	dapview.open()
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

-- A session started another way (e.g. neotest <leader>td) enters debug mode too
dap.listeners.after.event_initialized["debug_mode"] = enter_debug_mode
