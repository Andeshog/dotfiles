-- lua/config/dap.lua
local dap = require("dap")
local dapview = require("dap-view")
local widgets = require("dap.ui.widgets")

vim.fn.sign_define("DapBreakpoint", {
	text = "●",
	texthl = "DiagnosticSignError", -- red by default in most themes
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
-- 1. Adapter: codelldb (C/C++)
-----------------------------------------------------------
-- Adjust this path to where your codelldb lives.
-- Examples:
--   - Mason: ~/.local/share/nvim/mason/packages/codelldb/extension/adapter/codelldb
--   - VSCode extension: ~/.vscode/extensions/vadimcn.vscode-lldb-*/adapter/codelldb

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

-- Generic configuration for C++ (also used for C)
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
-- 2. dap-view & virtual text
-----------------------------------------------------------
dapview.setup({
	winbar = {
		show = true,
	},
	windows = {
		position = "below",
	},
	auto_toggle = true,
})

require("nvim-dap-virtual-text").setup({})

-- Hide neotest panels and neotree when debugging starts
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

dap.listeners.before.event_terminated["neotest_cancel"] = function()
	local ok, neotest = pcall(require, "neotest")
	if ok then
		pcall(neotest.run.stop)
	end
end

dap.listeners.before.event_exited["neotest_cancel"] = function()
	local ok, neotest = pcall(require, "neotest")
	if ok then
		pcall(neotest.run.stop)
	end
end

-----------------------------------------------------------
-- 3. Basic DAP keymaps
-----------------------------------------------------------
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

map("n", "<M-Right>", function()
	dap.continue()
end, opts)
map("n", "<M-Up>", function()
	dap.step_over()
end, opts)
map("n", "<M-Down>", function()
	dap.step_into()
end, opts)
map("n", "<M-Left>", function()
	dap.step_out()
end, opts)
map("n", "<leader>db", function()
	dap.toggle_breakpoint()
end, { desc = "DAP: toggle breakpoint" })
map("n", "<leader>dB", function()
	dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "DAP: conditional breakpoint" })

map("n", "<leader>du", function()
	dapview.toggle()
end, { desc = "DAP: toggle view" })

map({ "n", "v" }, "<leader>dh", function()
	widgets.hover()
end, { desc = "DAP: hover variables" })
map({ "n", "v" }, "<leader>dp", function()
	widgets.preview()
end, { desc = "DAP: preview variable" })
map("n", "<leader>df", function()
	widgets.centered_float(widgets.frames)
end, { desc = "DAP: show frames" })
map("n", "<leader>ds", function()
	widgets.centered_float(widgets.scopes)
end, { desc = "DAP: show scopes" })
map({ "n", "v" }, "<leader>de", function()
	widgets.hover()
end, { desc = "DAP: evaluate expression" })
map("n", "<leader>dE", function()
	widgets.centered_float(widgets.expression)
end, { desc = "DAP: show expressions" })

map("n", "<leader>dq", function()
	local ok_nt, neotest = pcall(require, "neotest")
	if ok_nt then
		pcall(neotest.run.stop)
	end

	dap.terminate()
	dap.disconnect({ terminateDebuggee = true })

	pcall(dapview.close)
end, { desc = "DAP: stop (cancel neotest first)" })

map("n", "<leader>dC", function()
	require("dap").clear_breakpoints()
	vim.notify("DAP: cleared all breakpoints")
end, { desc = "DAP: clear all breakpoints" })

map("n", "<leader>dl", function()
	require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
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
	require("dap").set_exception_breakpoints({ "cpp_throw", "cpp_catch" })
	vim.notify("DAP: break on C++ throw/catch enabled")
end, { desc = "DAP: break on exceptions (C++)" })

map("n", "<leader>dR", function()
	dap.restart()
end, { desc = "DAP: restart session" })

map("n", "<leader>dc", function()
	require("dap").run_to_cursor()
end, { desc = "DAP: run to cursor" })

map("n", "<leader>dr", function()
	require("dap").repl.open({}, "belowright split")
end, { desc = "DAP: open REPL (split)" })
