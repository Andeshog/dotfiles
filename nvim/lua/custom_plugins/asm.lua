local M = {}

local launch = require("custom_plugins.launch_target")

local config = {
	objdump = "objdump",
	args = { "-dS", "--demangle", "--no-show-raw-insn", "-M", "intel" },
	split = "vsplit",
}

local function binary()
	local target = launch.get()
	if target.program and vim.fn.executable(target.program) == 1 then
		return target.program
	end

	local chosen = launch.ensure()
	return chosen and chosen.program
end

local function enclosing_function()
	local ok, parser = pcall(vim.treesitter.get_parser, 0)
	if not ok or not parser then
		return nil
	end
	parser:parse(true)

	local cursor = vim.api.nvim_win_get_cursor(0)
	local found, node = pcall(vim.treesitter.get_node, { bufnr = 0, pos = { cursor[1] - 1, cursor[2] } })
	if not found or not node then
		return nil
	end

	while node do
		if node:type() == "function_definition" then
			local declarator = node:field("declarator")[1]
			while declarator do
				local kind = declarator:type()
				if kind:match("identifier$") then
					return vim.treesitter.get_node_text(declarator, 0)
				end
				declarator = declarator:field("declarator")[1]
			end
			return nil
		end
		node = node:parent()
	end
end

local function disassemble(path)
	local cmd = vim.list_extend({ config.objdump }, vim.deepcopy(config.args))
	table.insert(cmd, path)

	local result = vim.system(cmd, { text = true }):wait()
	if result.code ~= 0 then
		vim.notify("objdump failed: " .. (result.stderr or ""), vim.log.levels.ERROR)
		return nil
	end

	return vim.split(result.stdout, "\n")
end

local function symbol_block(lines, symbol)
	local out, capturing = {}, false

	for _, line in ipairs(lines) do
		local header = line:match("^%x+ <(.+)>:$")
		if header then
			capturing = header:find(symbol, 1, true) ~= nil
		end
		if capturing then
			table.insert(out, line)
		end
	end

	return out
end

local function show(lines, title)
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].filetype = "asm"
	vim.bo[buf].modifiable = false
	vim.bo[buf].bufhidden = "wipe"

	vim.cmd(config.split)
	local win = vim.api.nvim_get_current_win()
	vim.api.nvim_win_set_buf(win, buf)
	vim.wo[win].wrap = false
	vim.wo[win].number = false
	vim.wo[win].winbar = " " .. title

	vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, nowait = true, silent = true })
end

function M.show(symbol)
	local path = binary()
	if not path then
		return
	end

	if launch.has_debug_info(path) == false then
		vim.notify(
			"No debug info in " .. vim.fn.fnamemodify(path, ":t") .. "; source will not interleave",
			vim.log.levels.WARN
		)
	end

	local lines = disassemble(path)
	if not lines then
		return
	end

	symbol = symbol ~= "" and symbol or (enclosing_function() or vim.fn.expand("<cword>"))

	if symbol and symbol ~= "" then
		local block = symbol_block(lines, symbol)
		if #block > 0 then
			return show(block, symbol)
		end
		vim.notify("No symbol matching '" .. symbol .. "'; showing full disassembly", vim.log.levels.WARN)
	end

	show(lines, vim.fn.fnamemodify(path, ":t"))
end

function M.setup(opts)
	config = vim.tbl_deep_extend("force", config, opts or {})

	vim.api.nvim_create_user_command("Asm", function(cmd)
		M.show(cmd.args)
	end, { nargs = "?", desc = "Disassemble symbol under cursor" })

	vim.keymap.set("n", "<leader>ca", function()
		M.show("")
	end, { desc = "Assembly for symbol under cursor" })
end

return M
