local M = {}

local function find_comment_node()
	local ok, node = pcall(vim.treesitter.get_node)
	if not ok or not node then
		return nil
	end
	while node do
		if node:type():find("comment") then
			return node
		end
		node = node:parent()
	end
	return nil
end

local function prefix_len(s)
	local p = s:match("^(/%*+%s*)") or s:match("^(//+%s*)")
	return p and #p or 0
end

local function suffix_len(s)
	local p = s:match("(%s*%*+/)$")
	return p and #p or 0
end

local function select_range(sr, sc, er, ec)
	local mode = vim.fn.mode()
	if mode:match("[vV\22]") then
		vim.cmd("normal! " .. mode)
	end
	vim.api.nvim_win_set_cursor(0, { sr + 1, sc })
	vim.cmd("normal! v")
	vim.api.nvim_win_set_cursor(0, { er + 1, math.max(0, ec - 1) })
end

local function select_comment(inner)
	local node = find_comment_node()
	if not node then
		return
	end
	local sr, sc, er, ec = node:range()

	if inner then
		if sr == er then
			local line = vim.api.nvim_buf_get_lines(0, sr, sr + 1, false)[1] or ""
			local segment = line:sub(sc + 1, ec)
			sc = sc + prefix_len(segment)
			ec = ec - suffix_len(segment)
		else
			local first = vim.api.nvim_buf_get_lines(0, sr, sr + 1, false)[1] or ""
			local last = vim.api.nvim_buf_get_lines(0, er, er + 1, false)[1] or ""
			sc = sc + prefix_len(first:sub(sc + 1))
			ec = ec - suffix_len(last:sub(1, ec))
		end
	end

	select_range(sr, sc, er, ec)
end

vim.keymap.set({ "x", "o" }, "ac", function()
	select_comment(false)
end, { silent = true, desc = "A comment" })

vim.keymap.set({ "x", "o" }, "ic", function()
	select_comment(true)
end, { silent = true, desc = "Inner comment" })

return M
