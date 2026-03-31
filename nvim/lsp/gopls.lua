local function enable_native_completion(client, bufnr)
	if client:supports_method("textDocument/completion") then
		local chars = {}
		for i = 32, 126 do
			table.insert(chars, string.char(i))
		end

		client.server_capabilities.completionProvider = client.server_capabilities.completionProvider or {}
		client.server_capabilities.completionProvider.triggerCharacters = chars
		vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
	end
end

return {
	cmd = { "gopls" },
	filetypes = { "go", "gomod", "gowork", "gotmpl" },
	root_markers = { "go.work", "go.mod", ".git" },
	settings = {
		gopls = {
			analyses = {
				unusedparams = true,
				shadow = true,
			},
			staticcheck = true,
			gofumpt = true,
			hints = {
				assignVariableTypes = true,
				compositeLiteralFields = true,
				compositeLiteralTypes = true,
				constantValues = true,
				parameterNames = true,
				rangeVariableTypes = true,
			},
		},
	},
	on_attach = enable_native_completion,
}
