return {
	cmd = {
		"clangd",
		"--background-index",
		"--clang-tidy",
		"--header-insertion=iwyu",
		"--completion-style=detailed",
		"--function-arg-placeholders",
		"--fallback-style=google",
	},
	filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
	root_markers = { "compile_commands.json", "compile_flags.txt", ".clangd", ".git" },

	-- Enable native completion with autotrigger
	on_attach = function(client, bufnr)
		if client:supports_method("textDocument/completion") then
			-- Trigger on every printable character for nvim-cmp-like behavior
			local chars = {}
			for i = 32, 126 do
				table.insert(chars, string.char(i))
			end
			client.server_capabilities.completionProvider.triggerCharacters = chars
			vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
		end
	end,
	capabilities = vim.lsp.protocol.make_client_capabilities(),
}
