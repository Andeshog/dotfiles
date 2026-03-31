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
	cmd = { "pyright-langserver", "--stdio" },
	filetypes = { "python" },
	root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" },
	on_attach = enable_native_completion,
}
