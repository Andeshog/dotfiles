local M = {}

local definition_nodes = {
	struct_specifier = true,
	class_specifier = true,
	union_specifier = true,
	enum_specifier = true,
	function_definition = true,
	type_definition = true,
	alias_declaration = true,
	concept_definition = true,
}

local function definition_range(bufnr, row, col)
	local ft = vim.bo[bufnr].filetype ~= "" and vim.bo[bufnr].filetype or vim.filetype.match({ buf = bufnr })
	local lang = ft and vim.treesitter.language.get_lang(ft)
	local ok, parser = pcall(vim.treesitter.get_parser, bufnr, lang)
	if not ok or not parser then
		return row, row, ft
	end
	parser:parse()
	local node = vim.treesitter.get_node({ bufnr = bufnr, pos = { row, col }, ignore_injections = true })
	while node and not definition_nodes[node:type()] do
		node = node:parent()
	end
	if not node then
		return row, row, ft
	end
	local parent = node:parent()
	if parent and parent:type() == "template_declaration" then
		node = parent
	end
	local start_row, _, end_row = node:range()
	return start_row, end_row, ft
end

function M.peek_definition()
	vim.lsp.buf_request(0, "textDocument/definition", function(client)
		return vim.lsp.util.make_position_params(0, client.offset_encoding)
	end, function(err, result)
		if err or not result or vim.tbl_isempty(result) then
			return vim.notify("No definition found", vim.log.levels.INFO)
		end
		local loc = vim.islist(result) and result[1] or result
		local range = loc.targetRange or loc.range
		local bufnr = vim.uri_to_bufnr(loc.targetUri or loc.uri)
		vim.fn.bufload(bufnr)
		local first, last, ft = definition_range(bufnr, range.start.line, range.start.character)
		local lines = vim.api.nvim_buf_get_lines(bufnr, first, last + 1, false)
		local float_buf = vim.lsp.util.open_floating_preview(lines, "", {
			focus_id = "peek_definition",
			max_width = 100,
			max_height = 30,
		})
		local lang = ft and vim.treesitter.language.get_lang(ft)
		if lang then
			pcall(vim.treesitter.start, float_buf, lang)
		end
	end)
end

return M
