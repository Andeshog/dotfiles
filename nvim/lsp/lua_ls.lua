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
	cmd = { "lua-language-server" },
	filetypes = { "lua" },
	root_markers = { ".luarc.json", ".luarc.jsonc", ".git" },
	settings = {
		Lua = {
			diagnostics = {
				globals = { "vim" },
			},
			workspace = {
				checkThirdParty = false,
				library = {
					vim.env.VIMRUNTIME,
					vim.fn.stdpath("config"),
				},
			},
			telemetry = {
				enable = false,
			},
		},
	},
	on_attach = enable_native_completion,
}
