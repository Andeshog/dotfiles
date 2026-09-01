local M = {}

local state_path = vim.fn.stdpath("state") .. "/dap-launch.json"
local state

local function read_state()
	if state then
		return state
	end

	state = {}
	local file = io.open(state_path, "r")
	if file then
		local content = file:read("*a")
		file:close()
		local ok, decoded = pcall(vim.json.decode, content)
		if ok and type(decoded) == "table" then
			state = decoded
		end
	end

	return state
end

local function write_state()
	local file = io.open(state_path, "w")
	if file then
		file:write(vim.json.encode(read_state()))
		file:close()
	end
end

local function split_args(input)
	local args, i = {}, 1

	while i <= #input do
		local char = input:sub(i, i)

		if char:match("%s") then
			i = i + 1
		elseif char == '"' then
			local close = input:find('"', i + 1, true)
			table.insert(args, input:sub(i + 1, (close or #input + 1) - 1))
			i = (close or #input) + 1
		else
			local stop = input:find("%s", i) or (#input + 1)
			table.insert(args, input:sub(i, stop - 1))
			i = stop
		end
	end

	return vim.tbl_map(function(arg)
		return arg:sub(1, 1) == "~" and vim.fn.expand(arg) or arg
	end, args)
end

local function join_args(args)
	return table.concat(
		vim.tbl_map(function(arg)
			return arg:find("%s") and ('"' .. arg .. '"') or arg
		end, args or {}),
		" "
	)
end

function M.get()
	local all = read_state()
	local key = vim.fn.getcwd()
	all[key] = all[key] or {}
	return all[key]
end

function M.prompt()
	local target = M.get()

	local program = vim.fn.input({
		prompt = "Executable: ",
		default = target.program or (vim.fn.getcwd() .. "/"),
		completion = "file",
	})
	if program == "" then
		return nil
	end

	local args = vim.fn.input({
		prompt = "Args: ",
		default = join_args(target.args),
		completion = "file",
	})

	target.program = vim.fn.expand(program)
	target.args = split_args(args)
	write_state()

	return target
end

function M.ensure()
	local target = M.get()
	if not target.program or target.program == "" then
		return M.prompt()
	end
	return target
end

function M.has_debug_info(program)
	if vim.fn.filereadable(program) ~= 1 or vim.fn.executable("readelf") ~= 1 then
		return nil
	end

	local out = vim.fn.system({ "readelf", "-S", "--wide", program })
	if vim.v.shell_error ~= 0 then
		return nil
	end

	return out:find(".debug_info", 1, true) ~= nil
end

return M
