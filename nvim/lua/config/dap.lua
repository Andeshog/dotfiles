-- lua/config/dap.lua
local dap = require("dap")
local dapui = require("dapui")
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
-- 2. dap-ui & virtual text
-----------------------------------------------------------
dapui.setup({
	controls = {
		enabled = true,
		element = "repl",
	},
	floating = {
		border = "rounded",
		mappings = { close = { "q", "<Esc>" } },
	},
	layouts = {
		{
			elements = {
				{ id = "scopes", size = 0.35 },
				{ id = "breakpoints", size = 0.15 },
				{ id = "stacks", size = 0.25 },
				{ id = "watches", size = 0.25 },
			},
			size = 45,
			position = "left",
		},
		{
			elements = {
				{ id = "repl", size = 0.5 },
				{ id = "console", size = 0.5 },
			},
			size = 12,
			position = "bottom",
		},
	},
})

require("nvim-dap-virtual-text").setup({})

-- Auto open/close UI + hide neotest panels when debugging
dap.listeners.after.event_initialized["dapui_neotest"] = function()
	dapui.open()

	-- If neotest is available, hide its side panes
	local ok, neotest = pcall(require, "neotest")
	if ok then
		-- pcall so this never crashes if API changes
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
end -----------------------------------------------------------
-- 3. Basic DAP keymaps
-----------------------------------------------------------
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- helper: is any dap-ui window open?
local function dapui_is_open()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		local ft = vim.bo[buf].filetype
		if ft:match("^dapui_") then
			return true
		end
	end
	return false
end

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

map("n", "<leader>dr", function()
	dap.repl.open()
end, { desc = "DAP: open REPL" })
map("n", "<leader>du", function()
	if dapui_is_open() then
		dapui.close()
	else
		dapui.open()
		pcall(vim.cmd, "Neotree close")
	end
end, { desc = "DAP: toggle UI (sync with Neo-tree)" })

map({ "n", "v" }, "<leader>dh", function()
	local widgets = require("dap.ui.widgets")
	widgets.hover()
end, { desc = "DAP: hover variables" })
map({ "n", "v" }, "<leader>dp", function()
	local widgets = require("dap.ui.widgets")
	widgets.preview()
end, { desc = "DAP: preview variable" })
map("n", "<leader>df", function()
	local widgets = require("dap.ui.widgets")
	widgets.centered_float(widgets.frames)
end, { desc = "DAP: show frames" })
map("n", "<leader>ds", function()
	local widgets = require("dap.ui.widgets")
	widgets.centered_float(widgets.scopes)
end, { desc = "DAP: show scopes" })
map({ "n", "v" }, "<leader>de", function()
	dapui.eval()
end, { desc = "DAP: evaluate" })

map("n", "<leader>dE", function()
	widgets.centered_float(widgets.expression)
end, { desc = "DAP: show expressions" })

map("n", "<leader>dw", function()
	require("dapui").float_element("watches", { enter = true, position = "center" })
end, { desc = "DAP: show watches (float)" })

map("n", "<leader>dq", function()
	-- 1) stop neotest run first (prevents JSON parse attempt)
	local ok_nt, neotest = pcall(require, "neotest")
	if ok_nt then
		pcall(neotest.run.stop)
	end

	-- 2) then stop dap
	local ok_dap, dap = pcall(require, "dap")
	if ok_dap then
		-- terminate is usually the “graceful” one
		dap.terminate()
		-- optional: also disconnect
		dap.disconnect({ terminateDebuggee = true })
	end

	-- 3) UI cleanup (optional)
	local ok_ui, dapui = pcall(require, "dapui")
	if ok_ui then
		pcall(dapui.close)
	end
end, { desc = "DAP: stop (cancel neotest first)" })

map("n", "<leader>dC", function()
	require("dap").clear_breakpoints()
	vim.notify("DAP: cleared all breakpoints")
end, { desc = "DAP: clear all breakpoints" })

map("n", "<leader>dl", function()
	require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
end, { desc = "DAP: logpoint" })

map("n", "<leader>d?", function()
	local dap = require("dap")
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
	local dap = require("dap")
	dap.restart()
end, { desc = "DAP: restart session" })

map("n", "<leader>dc", function()
	require("dap").run_to_cursor()
end, { desc = "DAP: run to cursor" })

map("n", "<leader>dr", function()
	require("dap").repl.open({}, "belowright split")
end, { desc = "DAP: open REPL (split)" })
