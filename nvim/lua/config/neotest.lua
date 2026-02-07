local neotest = require("neotest")

neotest.setup({
	adapters = {
		-- Python adapter
		--require("neotest-python")({
		--	runner = "pytest",
		--	--python = "python3",
		--	is_test_file = function(file_path)
		--		return file_path:match("test_.*%.py$") ~= nil or file_path:match(".*_test%.py$") ~= nil
		--	end,
		--}),

		-- Google Test adapter for C++
		require("neotest-gtest").setup({
			debug_adapter = "codelldb",

			is_test_file = function(path)
				if not (path:match("%.cpp$") or path:match("%.cc$") or path:match("%.cxx$")) then
					return false
				end

				return path:match("tests?%.[^/]+$") -- tests.cpp / test.cpp
					or path:match("_tests?%.[^/]+$") -- _tests.cpp / _test.cpp
					or path:match("test_.*%.[^/]+$") -- test_foo.cpp
					or path:match(".*_test%.[^/]+$") -- foo_test.cpp
					or path:match(".*_tests%.[^/]+$") -- foo_tests.cpp
			end,
		}),

		-- Go adapter
		require("neotest-golang")({
			go_test_args = {
				"-v", -- Verbose output
				"-count=1", -- Disable test caching
			},
		}),
	},
})
