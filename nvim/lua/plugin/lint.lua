local lint = require("lint")
local parser = require("lint.parser")

local has_zb = vim.fn.executable("zb_flake8") == 1
	and vim.fn.executable("zb_mypy") == 1
	and vim.fn.executable("zb_yamllint") == 1
	and vim.fn.executable("zb_pep257") == 1

if has_zb then
	lint.linters.zb_flake8 = {
		cmd = "zb_flake8",
		stdin = false,
		append_fname = true,
		args = {},
		ignore_exitcode = true,
		parser = parser.from_errorformat("%f:%l:%c: %m", {
			severity = vim.diagnostic.severity.WARN,
			source = "zb_flake8",
		}),
	}

	lint.linters.zb_mypy = {
		cmd = "zb_mypy",
		stdin = false,
		append_fname = true,
		args = {},
		ignore_exitcode = true,
		parser = parser.from_errorformat("%f:%l: %m", {
			severity = vim.diagnostic.severity.WARN,
			source = "zb_mypy",
		}),
	}

	lint.linters.zb_yamllint = {
		cmd = "zb_yamllint",
		stdin = false,
		append_fname = true,
		args = {},
		ignore_exitcode = true,
		parser = parser.from_errorformat("%f:%l:%c: %m", {
			severity = vim.diagnostic.severity.WARN,
			source = "zb_yamllint",
		}),
	}

	lint.linters.zb_pep257 = {
		cmd = "zb_pep257",
		stdin = false,
		append_fname = true,
		args = {},
		ignore_exitcode = true,
		parser = parser.from_errorformat("%f:%l: %m", {
			severity = vim.diagnostic.severity.WARN,
			source = "zb_pep257",
		}),
	}
end

lint.linters_by_ft = {
	python = has_zb and { "zb_flake8", "zb_mypy", "zb_pep257" } or {},
	yaml = has_zb and { "zb_yamllint" } or {},
	sh = { "shellcheck" },
	bash = { "shellcheck" },
}

local lint_augroup = vim.api.nvim_create_augroup("nvim-lint", { clear = true })
vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
	group = lint_augroup,
	callback = function()
		require("lint").try_lint()
	end,
})
