local diagnostics = require("diagnostics")

---------------------------------------------------------------------------
----------------- LSP status + progress helpers ---------------------------
---------------------------------------------------------------------------

local function lsp_status()
	local bufnr = vim.api.nvim_get_current_buf()
	local clients = vim.lsp.get_clients and vim.lsp.get_clients() or {}

	local names = {}
	for _, client in ipairs(clients) do
		if client.attached_buffers and client.attached_buffers[bufnr] and client.name ~= "GitHub Copilot" then
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

local function toggle_lspinfo() -- Look for an existing LspInfo window
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		local ft = vim.bo[buf].filetype
		local name = vim.api.nvim_buf_get_name(buf)
		-- Match either by filetype or by buffer name
		if ft == "checkhealth" and name == "health://" then
			vim.api.nvim_win_close(win, true)
			return
		end
	end -- No LspInfo window found -> open it
	vim.cmd("LspInfo")
end

local function copilot_icon()
	return ""
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

					-- If we're not in a git repo, just show branch
					local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
					if vim.v.shell_error ~= 0 or git_root == nil or git_root == "" then
						return branch
					end

					-- Get remote origin URL
					local remote = vim.fn.systemlist("git config --get remote.origin.url")[1]
					if remote == nil or remote == "" then
						-- fallback: directory name if no remote
						local dir = vim.fn.fnamemodify(git_root, ":t")
						return dir .. ":" .. branch
					end

					-- Extract repo name from URL:
					--  - git@github.com:user/repo.git
					--  - https://github.com/user/repo.git
					--  - /some/path/repo.git
					local repo = remote
					repo = repo:gsub("%.git$", "") -- drop .git
					repo = repo:match("([^/]+)$") or repo -- take last path component

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
			{
				-- nvim-navic location
				function()
					local ok, navic = pcall(require, "nvim-navic")
					if not ok then
						return ""
					end
					return navic.get_location()
				end,
				cond = function()
					local ok, navic = pcall(require, "nvim-navic")
					return ok and navic.is_available()
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
						return { fg = "#ed8796" } -- catppuccin-macchiato red
					elseif warns > 0 then
						return { fg = "#eed49f" } -- catppuccin-macchiato yellow
					else
						return { fg = "#a6da95" } -- catppuccin-macchiato green
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
					toggle_lspinfo()
				end,
			},
		},
		lualine_z = {
			{
				copilot_icon,
				color = function()
					local base = vim.api.nvim_get_hl(0, { name = "lualine_z_normal", link = false })
					local ok, status = pcall(require, "sidekick.status")
					if not ok then
						return { fg = base.fg, bg = "#5b6078" }
					end
					local s = status.get()
					if not s then
						return { fg = base.fg, bg = "#5b6078" }
					end
					if s.kind == "Error" then
						return { fg = base.fg, bg = "#ed8796" }
					elseif s.busy or s.kind == "Warning" then
						return { fg = base.fg, bg = "#eed49f" }
					elseif s.kind == "Inactive" then
						return { fg = base.fg, bg = "#5b6078" }
					else
						return { fg = base.fg, bg = "#a6da95" }
					end
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
