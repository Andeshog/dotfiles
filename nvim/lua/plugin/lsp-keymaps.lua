local diagnostics = require("diagnostics")
local fzf = require("fzf-lua")

local function switch_source_header(cmd)
	cmd = cmd or "edit"
	local bufnr = vim.api.nvim_get_current_buf()
	local client = vim.lsp.get_clients({ bufnr = bufnr, name = "clangd" })[1]
	if not client then
		return vim.notify("clangd not attached", vim.log.levels.WARN)
	end

	client:request("textDocument/switchSourceHeader", vim.lsp.util.make_text_document_params(bufnr), function(err, uri)
		if err then
			return vim.notify(err.message, vim.log.levels.ERROR)
		end
		if not uri or uri == "" then
			return vim.notify("No corresponding file found", vim.log.levels.WARN)
		end
		vim.cmd[cmd](vim.fn.fnameescape(vim.uri_to_fname(uri)))
	end, bufnr)
end

vim.api.nvim_create_user_command("ClangdSwitch", function(o)
	switch_source_header(o.bang and "vsplit" or "edit")
end, { bang = true, desc = "Switch between source and header" })

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("lsp-keymaps", {}),
	callback = function(ev)
		local opts = function(desc)
			return { buffer = ev.buf, desc = desc }
		end

		-- Navigation
		vim.keymap.set("n", "gd", fzf.lsp_definitions, opts("Go to definition"))
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts("Go to declaration"))
		vim.keymap.set("n", "gi", fzf.lsp_implementations, opts("Go to implementation"))
		vim.keymap.set("n", "gr", fzf.lsp_references, opts("References"))
		vim.keymap.set("n", "gy", vim.lsp.buf.type_definition, opts("Type definition"))

		-- Call hierarchy
		vim.keymap.set("n", "<leader>lci", vim.lsp.buf.incoming_calls, opts("Incoming calls"))
		vim.keymap.set("n", "<leader>lco", vim.lsp.buf.outgoing_calls, opts("Outgoing calls"))

		-- Type hierarchy
		vim.keymap.set("n", "<leader>lt", function()
			vim.lsp.buf.typehierarchy("subtypes")
		end, opts("Type hierarchy"))

		-- Info
		vim.keymap.set("n", "K", vim.lsp.buf.hover, opts("Hover"))

		-- Actions
		vim.keymap.set({ "n", "x" }, "<leader>la", vim.lsp.buf.code_action, opts("Code action"))
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
			vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
			vim.keymap.set("n", "<leader>lh", function()
				vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf }), { bufnr = ev.buf })
			end, opts("Toggle inlay hints"))
		end
		-- Switch between source and header (if clangd)
		if client and client.name == "clangd" then
			vim.keymap.set("n", "<leader>lo", function()
				switch_source_header()
			end, opts("Switch source/header"))
			vim.keymap.set("n", "<leader>lO", function()
				switch_source_header("vsplit")
			end, opts("Switch source/header (split)"))
		end
	end,
})
