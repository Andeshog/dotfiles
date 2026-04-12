require("mason").setup()

local registry = require("mason-registry")

local packages = {
	"bash-language-server",
	"gopls",
	"pyright",
	"lua-language-server",
	"shfmt",
	"stylua",
	"shellcheck",
	"clangd",
	"clang-format",
}

local function ensure_installed()
	for _, name in ipairs(packages) do
		local ok, pkg = pcall(registry.get_package, name)
		if ok and not pkg:is_installed() then
			pkg:install()
		end
	end
end

registry.refresh(ensure_installed)
