require("cmake-tools").setup({
	cmake_command = "cmake",
	cmake_build_directory = "build",
	cmake_generate_options = { "-DCMAKE_EXPORT_COMPILE_COMMANDS=1" },
	cmake_compile_commands_options = {
		action = "none",
	},
	cmake_regenerate_on_save = true,
	cmake_executor = {
		name = "quickfix",
		opts = {
			show = "only_on_error",
			position = "belowright",
			size = 12,
			auto_close_when_success = true,
		},
	},
	cmake_runner = {
		name = "terminal",
		opts = {
			focus = false,
			single_terminal_per_instance = true,
			close_on_exit = false,
		},
	},
	cmake_dap_configuration = {
		name = "cpp",
		type = "codelldb",
		request = "launch",
		stopOnEntry = false,
		runInTerminal = true,
		console = "integratedTerminal",
	},
	cmake_use_scratch_buffer = true,
	cmake_virtual_text_support = false,
})

local cmake = require("cmake-tools")

-- cmake-tools' own progress notifier requires rcarriga/nvim-notify; route through vim.notify instead
local function run(label, fn, opt)
	vim.notify("CMake: " .. label .. "...")
	fn(opt or { bang = false, fargs = {} }, function(result)
		local ok = type(result) == "table" and result.is_ok and result:is_ok()
		vim.notify(
			("CMake: %s %s"):format(label, ok and "done" or "failed"),
			ok and vim.log.levels.INFO or vim.log.levels.ERROR
		)
	end)
end

local map = vim.keymap.set

map("n", "<leader>k", "<nop>", { desc = "CMake" })
map("n", "<leader>kg", function()
	run("configure", cmake.generate)
end, { desc = "CMake: configure" })
map("n", "<leader>kb", function()
	run("build", cmake.build)
end, { desc = "CMake: build" })
map("n", "<leader>kf", "<cmd>CMakeBuildCurrentFile<cr>", { desc = "CMake: build current file" })
map("n", "<leader>kr", function()
	run("run", cmake.run)
end, { desc = "CMake: run" })
map("n", "<leader>kd", "<cmd>CMakeDebug<cr>", { desc = "CMake: debug" })
map("n", "<leader>kt", "<cmd>CMakeSelectBuildTarget<cr>", { desc = "CMake: select build target" })
map("n", "<leader>kl", "<cmd>CMakeSelectLaunchTarget<cr>", { desc = "CMake: select launch target" })
map("n", "<leader>ka", function()
	local cmake = require("cmake-tools")
	if not cmake.get_launch_target() then
		vim.notify("No launch target selected (<leader>kl)", vim.log.levels.WARN)
		return
	end

	vim.ui.input({
		prompt = "Launch args: ",
		default = table.concat(cmake.get_launch_args() or {}, " "),
		completion = "file",
	}, function(input)
		if input then
			vim.cmd("CMakeLaunchArgs " .. input)
			vim.notify("Launch args: " .. (input ~= "" and input or "(none)"))
		end
	end)
end, { desc = "CMake: launch args" })
map("n", "<leader>kc", function()
	run("clean", cmake.clean)
end, { desc = "CMake: clean" })
map("n", "<leader>ks", "<cmd>CMakeStopExecutor<cr>", { desc = "CMake: stop build" })
map("n", "<leader>ko", "<cmd>CMakeOpenExecutor<cr>", { desc = "CMake: open build output" })
map("n", "<leader>kL", "<cmd>CMakeShowTargetFiles<cr>", { desc = "CMake: show target files" })
map("n", "<leader>kp", "<cmd>CMakeSelectConfigurePreset<cr>", { desc = "CMake: select configure preset" })
map("n", "<leader>kP", "<cmd>CMakeSelectBuildPreset<cr>", { desc = "CMake: select build preset" })
