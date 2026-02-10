local M = {}

local state = {
	building = false,
	output_buf = nil,
	config = {
		show_output = false, -- show output split on build start
		keep_output_on_success = false, -- keep output visible after successful build
	},
}

--- Search upwards from the current file to find package.xml
--- @returns string|nil The path to the package.xml file, or nil if not found
local function find_package_root()
	local current = vim.fn.expand("%:p:h")
	if current == "" then
		current = vim.fn.getcwd()
	end

	local results = vim.fs.find("package.xml", {
		path = current,
		upward = true,
		type = "file",
	})

	if #results > 0 then
		return vim.fn.fnamemodify(results[1], ":h")
	end

	return nil
end

--- Parse the <name> tag from package.xml
--- @param pkg_dir string directory containing package.xml
--- @returns string|nil The package name, or nil if not found
local function read_package_name(pkg_dir)
	local xml_path = pkg_dir .. "/package.xml"
	local file = io.open(xml_path, "r")
	if not file then
		return nil
	end

	local content = file:read("*a")
	file:close()

	-- Extract package name from <name>...</name> tag
	local name = content:match("<name>%s*(.-)%s*</name>")
	return name
end

--- Determine build command: prefer 'cb' if available, otherwise fall back to colcon
--- @param package_name string
--- @returns string
local function get_build_command(package_name)
	if vim.fn.executable("cb") == 1 then
		return string.format("cb %s", package_name)
	else
		return string.format(
			"colcon build --packages-select %s --event-handlers console_direct+ --cmake-args -DEXPORT_COMPILE_COMMANDS=ON",
			package_name
		)
	end
end

--- Find the colcon workspace root (parent directory that contains 'src')
--- @param pkg_dir string directory containing package.xml
--- @returns string workspace root
local function find_workspace_root(pkg_dir)
	local current = pkg_dir
	while current ~= "/" do
		local parent = vim.fn.fnamemodify(current, ":h")
		if vim.fn.isdirectory(parent .. "/src") == 1 then
			if pkg_dir:find(parent .. "/src", 1, true) then
				return parent
			end
		end
		current = parent
	end
	return vim.fn.getcwd()
end

--- Get or create the output buffer for error display
--- @returns number buffer handle
local function get_output_buffer()
	if state.output_buf and vim.api.nvim_buf_is_valid(state.output_buf) then
		vim.api.nvim_buf_set_lines(state.output_buf, 0, -1, false, {})
		return state.output_buf
	end

	state.output_buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_name(state.output_buf, "[ROS2 Build Output]")
	vim.bo[state.output_buf].buftype = "nofile"
	vim.bo[state.output_buf].filetype = "ros2build"
	return state.output_buf
end

--- Show the output buffer in a bottom split
local function show_output_split()
	local buf = get_output_buffer()

	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_get_buf(win) == buf then
			vim.api.nvim_set_current_win(win)
			return
		end
	end

	vim.cmd("botright split")
	local win = vim.api.nvim_get_current_win()
	vim.api.nvim_win_set_buf(win, buf)
	vim.api.nvim_win_set_height(win, 15)
	vim.cmd("wincmd p")
end

-- Main build function
function M.build()
	if state.building then
		vim.notify("ROS2 build already in progress...", vim.log.levels.WARN)
		return
	end

	local pkg_dir = find_package_root()
	if not pkg_dir then
		vim.notify("No package.xml found in parent directories", vim.log.levels.ERROR)
		return
	end

	local pkg_name = read_package_name(pkg_dir)
	if not pkg_name then
		vim.notify("Could not parse package name from package.xml", vim.log.levels.ERROR)
		return
	end

	local ws_root = find_workspace_root(pkg_dir)
	local build_cmd = get_build_command(pkg_name)

	state.building = true
	vim.notify(string.format("Building %s", pkg_name), vim.log.levels.INFO)

	local buf = get_output_buffer()
	local output_lines = {}

	-- Show output split immediately if configured
	if state.config.show_output then
		show_output_split()
	end

	vim.system(
		{ "sh", "-c", string.format("cd %s && %s 2>&1", vim.fn.shellescape(ws_root), build_cmd) },
		{
			text = true,
			stdout = function(_, data)
				if data then
					local new_lines = {}
					for line in data:gmatch("[^\r\n]+") do
						table.insert(output_lines, line)
						table.insert(new_lines, line)
					end

					-- Update buffer in real-time
					vim.schedule(function()
						if vim.api.nvim_buf_is_valid(buf) then
							local line_count = vim.api.nvim_buf_line_count(buf)
							-- If buffer only has one empty line, replace it instead of appending
							if line_count == 1 and vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] == "" then
								vim.api.nvim_buf_set_lines(buf, 0, -1, false, new_lines)
							else
								vim.api.nvim_buf_set_lines(buf, line_count, -1, false, new_lines)
							end

							-- Auto-scroll all windows showing this buffer to the bottom
							for _, win in ipairs(vim.api.nvim_list_wins()) do
								if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == buf then
									local new_line_count = vim.api.nvim_buf_line_count(buf)
									vim.api.nvim_win_set_cursor(win, { new_line_count, 0 })
								end
							end
						end
					end)
				end
			end,
		},
		vim.schedule_wrap(function(result)
			state.building = false

			if result.code == 0 then
				vim.notify(string.format("✓ Built %s", pkg_name), vim.log.levels.INFO)
				-- Close output window on success unless configured to keep it
				if not state.config.keep_output_on_success then
					for _, win in ipairs(vim.api.nvim_list_wins()) do
						if vim.api.nvim_win_get_buf(win) == buf then
							vim.api.nvim_win_close(win, true)
						end
					end
				end
			else
				vim.notify(
					string.format("✗ Build failed for %s (code %d)", pkg_name, result.code),
					vim.log.levels.ERROR
				)
				show_output_split()
			end
		end)
	)
end

-- Close the output split if open
function M.close_output()
	if state.output_buf and vim.api.nvim_buf_is_valid(state.output_buf) then
		for _, win in ipairs(vim.api.nvim_list_wins()) do
			if vim.api.nvim_win_get_buf(win) == state.output_buf then
				vim.api.nvim_win_close(win, true)
			end
		end
	end
end

--- Setup: keymaps and commands
function M.setup(opts)
	opts = opts or {}
	local key = opts.key or "<leader>cb"

	-- Update config with user options
	state.config.show_output = opts.show_output or false
	state.config.keep_output_on_success = opts.keep_output_on_success or false

	vim.api.nvim_create_user_command("ROS2Build", M.build, { desc = "Build current ROS2 package" })
	vim.api.nvim_create_user_command("ROS2BuildClose", M.close_output, { desc = "Close build output" })

	vim.keymap.set("n", key, M.build, { desc = "Build ROS2 package", silent = true })
end

return M
