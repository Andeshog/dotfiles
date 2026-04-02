local diagnostics = require("diagnostics")

-- Cache git repo name per directory to avoid blocking shell calls on every render
local git_repo_cache = {}
local function get_git_repo_name()
	local cwd = vim.fn.getcwd()
	if git_repo_cache[cwd] ~= nil then
		return git_repo_cache[cwd]
	end

	local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
	if vim.v.shell_error ~= 0 or not git_root or git_root == "" then
		git_repo_cache[cwd] = false
		return false
	end

	local remote = vim.fn.systemlist("git config --get remote.origin.url")[1]
	if not remote or remote == "" then
		local name = vim.fn.fnamemodify(git_root, ":t")
		git_repo_cache[cwd] = name
		return name
	end

	local repo = remote:gsub("%.git$", ""):match("([^/]+)$") or remote
	git_repo_cache[cwd] = repo
	return repo
end

vim.api.nvim_create_autocmd("DirChanged", {
	callback = function()
		git_repo_cache = {}
	end,
})

local function is_copilot_client(client)
	local name = (client and client.name or ""):lower()
	return name:find("copilot", 1, true) ~= nil
end

---------------------------------------------------------------------------
----------------- LSP status + progress helpers ---------------------------
---------------------------------------------------------------------------

local function lsp_status()
	local bufnr = vim.api.nvim_get_current_buf()
	local clients = vim.lsp.get_clients and vim.lsp.get_clients({ bufnr = bufnr }) or {}

	local names = {}
	for _, client in ipairs(clients) do
		if not is_copilot_client(client) then
			table.insert(names, client.name)
		end
	end

	if #names == 0 then
		return "  no LSP"
	end

	return "  " .. table.concat(names, ",")
end

-- Single function that lualine actually calls
local function lsp_component()
	return lsp_status()
end

local function show_lsp_status()
	local bufnr = vim.api.nvim_get_current_buf()
	local clients = vim.lsp.get_clients and vim.lsp.get_clients({ bufnr = bufnr }) or {}
	local lines = {}

	for _, client in ipairs(clients) do
		if not is_copilot_client(client) then
			local root = client.root_dir or client.config.root_dir or "?"
			table.insert(lines, string.format("%s [%s]", client.name, root))
		end
	end

	if #lines == 0 then
		vim.notify("No native LSP attached to current buffer", vim.log.levels.INFO, { title = "LSP" })
		return
	end

	vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = "LSP" })
end

local function copilot_icon()
	return ""
end

local function copilot_color()
	local base = vim.api.nvim_get_hl(0, { name = "lualine_z_normal", link = false })
	local colors = {
		inactive = "#626880",
		busy = "#e5c890",
		ready = "#a6d189",
		error = "#e78284",
	}

	local ok_client, client = pcall(require, "copilot.client")
	if not ok_client or client.is_disabled() then
		return { fg = base.fg, bg = colors.inactive }
	end

	local bufnr = vim.api.nvim_get_current_buf()
	if client.startup_error then
		return { fg = base.fg, bg = colors.error }
	end

	local ok_status, status = pcall(require, "copilot.status")
	if ok_status then
		if status.data.status == "InProgress" or status.data.status == "Warning" then
			return { fg = base.fg, bg = colors.busy }
		end
		if status.data.status ~= "" and status.data.message ~= "" and status.data.message:lower():find("error", 1, true) then
			return { fg = base.fg, bg = colors.error }
		end
	end

	local ok_suggestion, suggestion = pcall(require, "copilot.suggestion")
	if ok_suggestion and suggestion.is_visible() then
		return { fg = base.fg, bg = colors.ready }
	end

	if client.get() and client.buf_is_attached(bufnr) then
		return { fg = base.fg, bg = colors.ready }
	end

	return { fg = base.fg, bg = colors.inactive }
end

require("lualine").setup({
	options = {
		theme = "auto",
		globalstatus = true,
		icons_enabled = true,
		component_separators = "",
		section_separators = "",
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = {
			{
				"branch",
				icon = "",
				fmt = function(branch)
					if branch == "" then
						return ""
					end

					local repo = get_git_repo_name()
					if not repo then
						return branch
					end

					return repo .. ":" .. branch
				end,
			},
			{
				"diff", -- added/changed/removed counts
				symbols = { added = "+", modified = "~", removed = "-" },
			},
		},
		lualine_c = {
			{
				function()
					local name = vim.api.nvim_buf_get_name(0)
					if name == "" then
						return "[No Name]"
					end
					local path = vim.fn.fnamemodify(name, ":~:.")
					if vim.bo.modified then
						return path .. " ●"
					end
					return path
				end,
			},
		},
		lualine_x = {
			"progress",
			{
				function()
					local counts = vim.diagnostic.count(0)
					local sev = vim.diagnostic.severity
					local e = counts[sev.ERROR] or 0
					local w = counts[sev.WARN] or 0
					local i = counts[sev.INFO] or 0
					local h = counts[sev.HINT] or 0
					if e == 0 and w == 0 and i == 0 and h == 0 then
						return " OK"
					end
					return string.format(" %d  %d  %d  %d", e, w, i, h)
				end,
				-- Optional: color based on worst severity
				color = function()
					local bufnr = vim.api.nvim_get_current_buf()
					local errors = #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.ERROR })
					local warns = #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.WARN })

					if errors > 0 then
						return { fg = "#e78284" } -- catppuccin-frappe red
					elseif warns > 0 then
						return { fg = "#e5c890" } -- catppuccin-frappe yellow
					else
						return { fg = "#a6d189" } -- catppuccin-frappe green
					end
				end,
				on_click = function(clicks, button, modifiers)
					if button ~= "l" then
						return
					end
					diagnostics.toggle_buffer_list()
				end,
			},
		},
		lualine_y = {
			{
				lsp_component,
				color = { gui = "bold" },
				on_click = function(clicks, button, _)
					if button ~= "l" or clicks ~= 1 then
						return
					end
					show_lsp_status()
				end,
			},
		},
		lualine_z = {
			{
				copilot_icon,
				color = copilot_color,
				on_click = function(clicks, button, _)
					if button ~= "l" or clicks ~= 1 then
						return
					end
					vim.cmd("Copilot status")
				end,
			},
		},
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = {},
		lualine_x = {},
		lualine_y = {},
		lualine_z = {},
	},
})
