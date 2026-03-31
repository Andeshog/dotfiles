local diagnostics = require("diagnostics")

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("lsp-keymaps", {}),
	callback = function(ev)
		local opts = function(desc)
			return { buffer = ev.buf, desc = desc }
		end

		-- Navigation
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts("Go to definition"))
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts("Go to declaration"))
		vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts("Go to implementation"))
		vim.keymap.set("n", "gr", vim.lsp.buf.references, opts("References"))
		vim.keymap.set("n", "gy", vim.lsp.buf.type_definition, opts("Type definition"))

		-- Info
		vim.keymap.set("n", "K", vim.lsp.buf.hover, opts("Hover"))

		-- Actions
		vim.keymap.set("n", "<leader>la", vim.lsp.buf.code_action, opts("Code action"))
		vim.keymap.set("n", "<leader>lr", vim.lsp.buf.rename, opts("Rename symbol"))
		vim.keymap.set("n", "<leader>lf", function()
			local ok, conform = pcall(require, "conform")
			if ok then
				conform.format({ bufnr = ev.buf, async = true, lsp_fallback = true })
				return
			end

			vim.lsp.buf.format({ bufnr = ev.buf, async = true })
		end, opts("Format buffer"))
		vim.keymap.set("n", "<leader>ll", function()
			local ok, lint = pcall(require, "lint")
			if ok then
				lint.try_lint()
			end
		end, opts("Lint buffer"))

		-- Diagnostics
		vim.keymap.set("n", "<leader>ld", diagnostics.open_float, opts("Line diagnostics"))

		-- Workspace
		vim.keymap.set("n", "<leader>lwa", vim.lsp.buf.add_workspace_folder, opts("Add workspace folder"))
		vim.keymap.set("n", "<leader>lwr", vim.lsp.buf.remove_workspace_folder, opts("Remove workspace folder"))

		-- Toggle inlay hints (if supported)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if client and client:supports_method("textDocument/inlayHint") then
			vim.keymap.set("n", "<leader>lh", function()
				vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf }), { bufnr = ev.buf })
			end, opts("Toggle inlay hints"))
		end
	end,
})
