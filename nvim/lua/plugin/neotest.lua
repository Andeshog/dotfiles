local neotest = require("neotest")

neotest.setup({
	adapters = {
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
		}),
		-- require("neotest-ctest").setup({}),
		require("neotest-golang")({
			go_test_args = {
				"-v",
				"-count=1",
			},
		}),
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

local map = vim.keymap.set

map("n", "<leader>t", "<nop>", { desc = "Test" })
map("n", "<leader>tc", "<cmd>ConfigureGtest<cr>", { desc = "Gtest: configure marked tests" })
map("n", "<leader>tn", function()
	run_and_redraw()
end, { desc = "Test: run nearest" })
map("n", "<leader>tf", function()
	run_and_redraw(vim.fn.expand("%"))
end, { desc = "Test: run file" })
map("n", "<leader>ts", function()
	neotest.summary.toggle()
end, { desc = "Test: toggle summary" })
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
