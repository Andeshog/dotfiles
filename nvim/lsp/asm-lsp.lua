return {
	cmd = { "asm-lsp" },
	filetypes = { "asm", "vmasm" },
	root_markers = { ".asm-lsp.toml", ".git" },
	handlers = {
		["textDocument/publishDiagnostics"] = function(err, result, ctx)
			local bufnr = vim.fn.bufnr(vim.uri_to_fname(result.uri))
			local client = vim.lsp.get_client_by_id(ctx.client_id)
			if bufnr == -1 or not (client and client.attached_buffers[bufnr]) then
				return
			end
			vim.lsp.diagnostic.on_publish_diagnostics(err, result, ctx)
		end,
	},
}
