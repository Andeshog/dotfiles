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
	root_markers = { "compile_commands.json", ".clangd", ".git" },
}
