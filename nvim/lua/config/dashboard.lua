local M = {}
vim.api.nvim_create_user_command("ProjectRestore", function(opts)
	local dir = opts.args
	if dir and dir ~= "" then
		vim.cmd("cd " .. vim.fn.fnameescape(dir))
	end
	require("persistence").load({ last = false }) -- session for cwd
end, { nargs = 1 })

vim.api.nvim_create_user_command("SessionPick", function()
	-- This uses persistence's built-in UI
	require("persistence").select()

	-- After the session is loaded, sync Neo-tree.
	-- We schedule to run AFTER persistence finishes applying the session.
	vim.schedule(function()
		local ok, cmd = pcall(require, "neo-tree.command")
		if ok then
			cmd.execute({ action = "focus", dir = vim.uv.cwd() })
			cmd.execute({ action = "refresh" })
		else
			-- fallback if command module name changes
			pcall(vim.cmd, "Neotree reveal")
		end
	end)
end, {})

local function git_footer()
	local cwd = (vim.uv and vim.uv.cwd()) or vim.loop.cwd()

	local function sys(cmd)
		local out = vim.fn.systemlist(cmd)
		if vim.v.shell_error ~= 0 then
			return nil
		end
		return out
	end

	local function esc(p)
		return vim.fn.shellescape(p)
	end

	local root = sys("git -C " .. esc(cwd) .. " rev-parse --show-toplevel")
	if not root or not root[1] then
		return {}
	end

	local git_root = root[1]
	local repo = vim.fn.fnamemodify(git_root, ":t")

	local branch = sys("git -C " .. esc(git_root) .. " rev-parse --abbrev-ref HEAD")
	branch = branch and branch[1] or "?"

	local status = sys("git -C " .. esc(git_root) .. " status --porcelain") or {}
	local modified = #status

	local ab = sys("git -C " .. esc(git_root) .. " rev-list --left-right --count @{upstream}...HEAD")
	local behind, ahead = 0, 0
	if ab and ab[1] then
		behind, ahead = ab[1]:match("^(%d+)%s+(%d+)$")
		behind = tonumber(behind) or 0
		ahead = tonumber(ahead) or 0
	end

	local status_str
	if modified == 0 then
		status_str = "clean working tree"
	else
		status_str = string.format("%d modified file%s", modified, modified == 1 and "" or "s")
	end

	local sync_bits = {}
	if ahead > 0 then
		table.insert(sync_bits, "ahead " .. ahead)
	end
	if behind > 0 then
		table.insert(sync_bits, "behind " .. behind)
	end
	local sync_str = #sync_bits > 0 and (" | " .. table.concat(sync_bits, ", ")) or ""

	return {
		" ",
		string.format("  %s:%s", repo, branch),
		"    " .. status_str .. sync_str,
	}
end

M.setup = function()
	local db = require("dashboard")

	db.setup({
		theme = "hyper",
		config = {
			header = {
				" ",
				"                                                  @@@                                                 ",
				"                                                  @@@                                                 ",
				"    @@@@@@@@@@      @@@@@@@        @@@@@@@  @@@   @@@  @@@@@@@     @@@      @@@    @@@@@@@@@@@        ",
				"  @@@@@@@@@@@@    @@@@   @@@@     @@@@   @@@@@@   @@@@@@   @@@@    @@@      @@@   @@@@@@@@@@@         ",
				"        @@@@     @@@       @@@   @@@       @@@@   @@@@       @@@   @@@      @@@         @@@           ",
				"       @@@       @@@@@@@@@@@@@   @@@        @@@   @@@         @@@  @@@      @@@       @@@@            ",
				"     @@@@        @@@             @@@        @@@   @@@         @@@  @@@      @@@      @@@              ",
				"    @@@          @@@       @@@   @@@       @@@@   @@@@       @@@   @@@      @@@    @@@@               ",
				"  @@@@@@@@@@@@@   @@@@@@@@@@@     @@@@@@@@@@@@@   @@@@@@@@@@@@@     @@@@@@@@@@   @@@@@@@@@@@@@        ",
				" @@@@@@@@@@@@       @@@@@@@         @@@@@@  @@@   @@@  @@@@@@         @@@@@@    @@@@@@@@@@@@          ",
				"                                                                                                      ",
				" ",
			},
			shortcut = {
				-- { desc = "󰑓 Sessions", group = "Label", action = "SessionPick", key = "S" },
				{ desc = " Search and Replace", group = "Label", action = "Spectre", key = "S" },
				{ desc = "󰈞 Files", group = "Label", action = "Telescope find_files", key = "f" },
				{ desc = "󰊄 Grep", group = "Label", action = "Telescope live_grep", key = "g" },
				{ desc = "󰙅 Explorer", group = "Label", action = "Neotree toggle", key = "e" },
				{ desc = "󰋚 Recent", group = "Label", action = "Telescope frecency workspace=CWD", key = "r" },
				{ desc = "󰗼 Quit", group = "Label", action = "qa", key = "q" },
			},

			packages = { enable = true }, -- shows plugin count/startup time
			project = { enable = false, limit = 8, action = "ProjectRestore", label = "Recent repositories" },
			mru = { limit = 10, cwd_only = true },
			footer = git_footer(),
		},
	})

	-- Make it feel "clean" like a launcher
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "dashboard",
		callback = function()
			vim.opt_local.number = false
			vim.opt_local.relativenumber = false
			vim.opt_local.signcolumn = "no"
			vim.opt_local.foldcolumn = "0"
			vim.opt_local.statuscolumn = ""
		end,
	})
end
return M
