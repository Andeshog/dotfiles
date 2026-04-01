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

local map = vim.keymap.set

map("n", "<leader>t", "<nop>", { desc = "Test" })
map("n", "<leader>tc", "<cmd>ConfigureGtest<cr>", { desc = "Gtest: configure marked tests" })
map("n", "<leader>tn", function()
	neotest.run.run()
end, { desc = "Test: run nearest" })
map("n", "<leader>tf", function()
	neotest.run.run(vim.fn.expand("%"))
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
	neotest.run.run({ strategy = "dap" })
end, { desc = "Test: debug nearest" })
map("n", "[t", function()
	neotest.jump.prev({ status = "failed" })
end, { desc = "Previous failed test" })
map("n", "]t", function()
	neotest.jump.next({ status = "failed" })
end, { desc = "Next failed test" })
