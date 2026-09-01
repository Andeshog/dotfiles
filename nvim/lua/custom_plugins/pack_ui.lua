local M = {}

local ns = vim.api.nvim_create_namespace("pack-ui")
local state = { win = nil, buf = nil, rows = {} }

local function plugins()
	local list = vim.pack.get(nil, { info = false })
	table.sort(list, function(a, b)
		return a.spec.name:lower() < b.spec.name:lower()
	end)

	local active, unused = {}, {}
	for _, plugin in ipairs(list) do
		table.insert(plugin.active and active or unused, plugin)
	end

	return active, unused
end

local function short_src(src)
	return (src or ""):gsub("^https?://", ""):gsub("%.git$", "")
end

local function render()
	local active, unused = plugins()

	local width = 0
	for _, plugin in ipairs(vim.list_extend(vim.deepcopy(active), unused)) do
		width = math.max(width, #plugin.spec.name)
	end

	local lines, marks, rows = {}, {}, {}

	local function section(title, items, hl)
		table.insert(lines, string.format("%s (%d)", title, #items))
		table.insert(marks, { #lines - 1, 0, -1, hl })

		if #items == 0 then
			table.insert(lines, "  none")
			table.insert(marks, { #lines - 1, 0, -1, "Comment" })
		end

		for _, plugin in ipairs(items) do
			local name = plugin.spec.name
			table.insert(
				lines,
				string.format(
					"  %s  %s  %s",
					name .. (" "):rep(width - #name),
					plugin.rev:sub(1, 7),
					short_src(plugin.spec.src)
				)
			)
			rows[#lines] = plugin
			table.insert(marks, { #lines - 1, 2, 2 + #name, "Special" })
			table.insert(marks, { #lines - 1, 4 + width, 11 + width, "Comment" })
		end

		table.insert(lines, "")
	end

	section("Active", active, "Title")
	section("Unused", unused, #unused > 0 and "WarningMsg" or "Title")

	table.insert(lines, "u update   U update all   d delete   r refresh   q close")
	table.insert(marks, { #lines - 1, 0, -1, "Comment" })

	state.rows = rows
	vim.bo[state.buf].modifiable = true
	vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)
	vim.bo[state.buf].modifiable = false

	vim.api.nvim_buf_clear_namespace(state.buf, ns, 0, -1)
	for _, mark in ipairs(marks) do
		pcall(vim.api.nvim_buf_set_extmark, state.buf, ns, mark[1], mark[2], {
			end_col = mark[3] == -1 and #lines[mark[1] + 1] or mark[3],
			hl_group = mark[4],
		})
	end
end

local function current_plugin()
	return state.rows[vim.api.nvim_win_get_cursor(0)[1]]
end

function M.close()
	if state.win and vim.api.nvim_win_is_valid(state.win) then
		vim.api.nvim_win_close(state.win, true)
	end
	state.win, state.buf, state.rows = nil, nil, {}
end

local function update(names)
	M.close()
	vim.pack.update(names)
end

local function delete()
	local plugin = current_plugin()
	if not plugin then
		return
	end

	if plugin.active then
		vim.notify("'" .. plugin.spec.name .. "' is still in plugins.lua; remove it there first", vim.log.levels.WARN)
		return
	end

	if vim.fn.confirm("Delete '" .. plugin.spec.name .. "' from disk?", "&Yes\n&No", 2) ~= 1 then
		return
	end

	vim.pack.del({ plugin.spec.name })
	render()
end

function M.open()
	if state.win and vim.api.nvim_win_is_valid(state.win) then
		return vim.api.nvim_set_current_win(state.win)
	end

	state.buf = vim.api.nvim_create_buf(false, true)
	vim.bo[state.buf].bufhidden = "wipe"

	local width = math.min(84, vim.o.columns - 4)
	local height = math.min(math.max(20, math.floor(vim.o.lines * 0.7)), vim.o.lines - 6)

	state.win = vim.api.nvim_open_win(state.buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = math.max(0, math.floor((vim.o.lines - height) / 2) - 1),
		col = math.floor((vim.o.columns - width) / 2),
		style = "minimal",
		border = "rounded",
		title = " Plugins ",
		title_pos = "center",
	})

	vim.wo[state.win].wrap = false
	vim.wo[state.win].cursorline = true

	render()

	local map = function(lhs, fn)
		vim.keymap.set("n", lhs, fn, { buffer = state.buf, nowait = true, silent = true })
	end

	map("q", M.close)
	map("<Esc>", M.close)
	map("r", render)
	map("U", function()
		update(nil)
	end)
	map("u", function()
		local plugin = current_plugin()
		if plugin then
			update({ plugin.spec.name })
		end
	end)
	map("d", delete)
end

function M.setup()
	vim.api.nvim_create_user_command("Pack", M.open, { desc = "Plugin manager" })

	local names = function(arg_lead)
		local all = vim.tbl_map(function(plugin)
			return plugin.spec.name
		end, vim.pack.get(nil, { info = false }))

		table.sort(all)
		return vim.tbl_filter(function(name)
			return name:lower():find(arg_lead:lower(), 1, true) ~= nil
		end, all)
	end

	vim.api.nvim_create_user_command("PackUpdate", function(cmd)
		vim.pack.update(#cmd.fargs > 0 and cmd.fargs or nil)
	end, { nargs = "*", complete = names, desc = "Update plugins" })

	vim.api.nvim_create_user_command("PackDel", function(cmd)
		vim.pack.del(cmd.fargs)
	end, { nargs = "+", complete = names, desc = "Delete plugins from disk" })

	vim.keymap.set("n", "<leader>p", M.open, { desc = "Plugins" })
end

return M
