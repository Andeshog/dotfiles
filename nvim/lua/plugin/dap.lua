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
	auto_toggle = true,
})

require("nvim-dap-virtual-text").setup({})

-- Hide neotest panels and neo-tree when debugging starts
dap.listeners.after.event_initialized["dapview_neotest"] = function()
	local ok, neotest = pcall(require, "neotest")
	if ok then
		pcall(function() neotest.summary.close() end)
		pcall(function() neotest.output_panel.close() end)
	end
	pcall(vim.cmd, "Neotree close")
end

dap.listeners.before.event_terminated["neotest_cancel"] = function()
	local ok, neotest = pcall(require, "neotest")
	if ok then pcall(neotest.run.stop) end
end

dap.listeners.before.event_exited["neotest_cancel"] = function()
	local ok, neotest = pcall(require, "neotest")
	if ok then pcall(neotest.run.stop) end
end

-----------------------------------------------------------
-- DAP keymaps
-----------------------------------------------------------
local map = vim.keymap.set

-- Persistent keymaps (always available)
map("n", "<leader>d", "<nop>", { desc = "Debug" })
map("n", "<leader>db", dap.toggle_breakpoint, { desc = "DAP: toggle breakpoint" })
map("n", "<leader>dB", function()
	dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "DAP: conditional breakpoint" })
map("n", "<leader>dC", function()
	dap.clear_breakpoints()
	vim.notify("DAP: cleared all breakpoints")
end, { desc = "DAP: clear all breakpoints" })
map("n", "<leader>dl", function()
	dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
end, { desc = "DAP: logpoint" })
map("n", "<leader>d?", function()
	local cond = vim.fn.input("Condition (empty for none): ")
	local hit = vim.fn.input("Hit count (empty for none): ")
	local log = vim.fn.input("Log message (empty for none): ")
	cond = (cond ~= "" and cond) or nil
	hit = (hit ~= "" and hit) or nil
	log = (log ~= "" and log) or nil
	dap.set_breakpoint(cond, hit, log)
end, { desc = "DAP: set breakpoint (cond/hit/log)" })
map("n", "<leader>dx", function()
	dap.set_exception_breakpoints({ "cpp_throw", "cpp_catch" })
	vim.notify("DAP: break on C++ throw/catch enabled")
end, { desc = "DAP: break on exceptions (C++)" })

-- Session-scoped keymaps (only active during a debug session)
local session_keymaps = {
	{ "n", "<M-Right>", dap.continue, "DAP: continue" },
	{ "n", "<M-Up>", dap.step_over, "DAP: step over" },
	{ "n", "<M-Down>", dap.step_into, "DAP: step into" },
	{ "n", "<M-Left>", dap.step_out, "DAP: step out" },
	{ "n", "<leader>du", dapview.toggle, "DAP: toggle view" },
	{ { "n", "v" }, "<leader>dh", widgets.hover, "DAP: hover variables" },
	{ { "n", "v" }, "<leader>dp", widgets.preview, "DAP: preview variable" },
	{ "n", "<leader>df", function() widgets.centered_float(widgets.frames) end, "DAP: show frames" },
	{ "n", "<leader>ds", function() widgets.centered_float(widgets.scopes) end, "DAP: show scopes" },
	{ { "n", "v" }, "<leader>de", widgets.hover, "DAP: evaluate expression" },
	{ "n", "<leader>dE", function() widgets.centered_float(widgets.expression) end, "DAP: show expressions" },
	{ "n", "<leader>dR", dap.restart, "DAP: restart session" },
	{ "n", "<leader>dc", dap.run_to_cursor, "DAP: run to cursor" },
	{ "n", "<leader>dr", function() dap.repl.open({}, "belowright split") end, "DAP: open REPL (split)" },
	{ "n", "<leader>dq", function()
		local ok_nt, neotest = pcall(require, "neotest")
		if ok_nt then pcall(neotest.run.stop) end
		dap.terminate()
		dap.disconnect({ terminateDebuggee = true })
		pcall(dapview.close)
	end, "DAP: stop (cancel neotest first)" },
}

local function set_session_keymaps()
	for _, km in ipairs(session_keymaps) do
		map(km[1], km[2], km[3], { desc = km[4], silent = true })
	end
end

local function clear_session_keymaps()
	for _, km in ipairs(session_keymaps) do
		local modes = type(km[1]) == "table" and km[1] or { km[1] }
		for _, mode in ipairs(modes) do
			pcall(vim.keymap.del, mode, km[2])
		end
	end
end

dap.listeners.after.event_initialized["session_keymaps"] = set_session_keymaps
dap.listeners.before.event_terminated["session_keymaps"] = clear_session_keymaps
dap.listeners.before.event_exited["session_keymaps"] = clear_session_keymaps
