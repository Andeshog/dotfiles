require("conform").setup({
	formatters_by_ft = {
		c = { "clang_format" },
		cpp = { "clang_format" },
		lua = { "stylua" },
		go = { "goimports", "gofmt" },
		sh = { "shfmt" },
		bash = { "shfmt" },
	},
	formatters = {
		clang_format = {
			command = "clang-format",
			stdin = true,
			args = function(_, ctx)
				local args = {}
				local local_cfg = vim.fs.find({ ".clang-format", "_clang-format" }, { path = ctx.filename, upward = true })[1]

				if local_cfg ~= nil then
					table.insert(args, "--style=file")
				else
					table.insert(args, "--style=google")
				end

				table.insert(args, "--assume-filename")
				table.insert(args, ctx.filename)

				return args
			end,
		},
	},
	format_on_save = function(bufnr)
		if vim.b[bufnr].visual_multi then
			return
		end

		local ft = vim.bo[bufnr].filetype
		if ft == "c" or ft == "cpp" or ft == "lua" or ft == "go" or ft == "sh" or ft == "bash" then
			return { timeout_ms = 2000, lsp_fallback = ft == "go" }
		end
	end,
})
