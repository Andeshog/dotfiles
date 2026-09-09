return {
	cmd = {
		"clangd",
		"--background-index",
		"--clang-tidy",
		"--header-insertion=iwyu",
		"--completion-style=detailed",
		"--function-arg-placeholders",
		"--header-insertion-decorators",
		"--pch-storage=memory",
		"--all-scopes-completion",
		"-j=6",
		"--fallback-style=google",
	},
	filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
	root_markers = { "compile_commands.json", ".clangd", ".git" },
}
