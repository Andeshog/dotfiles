local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
local navic = require("nvim-navic")
if ok_cmp then
	capabilities = cmp_lsp.default_capabilities(capabilities)
end

local function on_attach(client, bufnr)
	if client.name == "clangd" then
		client.server_capabilities.documentFormattingProvider = false
		client.server_capabilities.documentRangeFormattingProvider = false
	end
	local function map(mode, lhs, rhs, desc)
		vim.keymap.set(mode, lhs, rhs, {
			noremap = true,
			silent = true,
			buffer = bufnr,
			desc = desc,
		})
	end
	map("n", "gd", vim.lsp.buf.definition, "Go to definition")
	map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
	map("n", "K", vim.lsp.buf.hover, "Hover documentation")
	map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
	map("n", "gr", vim.lsp.buf.references, "Go to references")
	map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
	map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")

	if client.server_capabilities.documentSymbolProvider then
		navic.attach(client, bufnr)
	end
end

vim.lsp.config("clangd", {
	cmd = {
		"clangd",
		"--background-index",
		"--clang-tidy",
		"--completion-style=detailed",
		"--header-insertion=iwyu",
		--"--config-file=/ros_ws/.clangd",
		--"--compile-commands-dir=/ros_ws/build",
	},

	filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },

	-- This replaces the old lspconfig root_dir logic.
	-- clangd will treat the directory containing one of these markers
	-- as the workspace root.
	root_markers = {
		"compile_commands.json",
		".clangd",
		".git",
	},

	capabilities = capabilities,
	on_attach = on_attach,
})

vim.lsp.enable("clangd")

-- Go: gopls ----------------------------------------------------
vim.lsp.config("gopls", {
	cmd = { "gopls" }, -- Mason or go-installed binary
	filetypes = { "go", "gomod", "gowork", "gotmpl" },

	-- workspace root detection
	root_markers = {
		"go.work",
		"go.mod",
		".git",
	},

	on_attach = on_attach,
	capabilities = capabilities,

	settings = {
		gopls = {
			analyses = {
				unusedparams = true,
				shadow = true,
			},
			staticcheck = true, -- extra checks (like golangci-lite)
			gofumpt = true, -- stricter formatting if you like that
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
})

-- enable gopls
vim.lsp.enable("gopls")

vim.lsp.config("bashls", {
	cmd = { "bash-language-server", "start" },
	filetypes = { "sh", "bash", "zsh" },
	root_markers = { ".git" },
	capabilities = capabilities,
	on_attach = on_attach,
})

vim.lsp.enable("bashls")
