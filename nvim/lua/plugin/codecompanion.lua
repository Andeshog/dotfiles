local api = vim.api
local map = vim.keymap.set

local function close_window()
	vim.cmd.close()
end

local function set_codecompanion_window_options()
	vim.opt_local.number = false
	vim.opt_local.relativenumber = false
	vim.opt_local.foldcolumn = "0"
	vim.opt_local.signcolumn = "no"
	vim.opt_local.statuscolumn = ""
end

local function set_codecompanion_keymaps(bufnr)
	map("n", "q", close_window, { buffer = bufnr, silent = true, desc = "Close CodeCompanion window" })
	map("n", "<C-w>q", close_window, { buffer = bufnr, silent = true, desc = "Close CodeCompanion window" })
	map("i", "<C-w>q", "<Esc><Cmd>close<CR>", { buffer = bufnr, silent = true, desc = "Close CodeCompanion window" })
	map("i", "<C-w>h", "<Esc><C-w>h", { buffer = bufnr, silent = true, desc = "Focus left window" })
	map("i", "<C-w>p", "<Esc><C-w>p", { buffer = bufnr, silent = true, desc = "Focus previous window" })

	if vim.bo[bufnr].filetype == "codecompanion_cli" then
		map("t", "<Esc><Esc>", [[<C-\><C-n>]], { buffer = bufnr, silent = true, desc = "Terminal normal mode" })
		map(
			"t",
			"<C-w>q",
			[[<C-\><C-n><Cmd>close<CR>]],
			{ buffer = bufnr, silent = true, desc = "Close CodeCompanion window" }
		)
		map("t", "<C-w>h", [[<C-\><C-n><C-w>h]], { buffer = bufnr, silent = true, desc = "Focus left window" })
		map("t", "<C-w>p", [[<C-\><C-n><C-w>p]], { buffer = bufnr, silent = true, desc = "Focus previous window" })
	end
end

require("codecompanion").setup({
	interactions = {
		chat = {
			adapter = "copilot",
		},
		inline = {
			adapter = "copilot",
		},
		background = {
			adapter = {
				name = "copilot",
				model = "gpt-5.4",
			},
		},
		cli = {
			agent = "claude_code",
			agents = {
				claude_code = {
					cmd = "claude",
					args = {},
					description = "Claude Code CLI",
					provider = "terminal",
				},
				copilot_cli = {
					cmd = "copilot",
					args = {},
					description = "GitHub Copilot CLI",
					provider = "terminal",
				},
			},
			opts = {
				auto_insert = true,
				reload = true,
			},
		},
	},
	adapters = {
		acp = {
			claude_code = function()
				return require("codecompanion.adapters").extend("claude_code", {})
			end,
		},
	},
	display = {
		chat = {
			window = {
				layout = "vertical",
				width = 0.35,
			},
		},
		cli = {
			window = {
				layout = "vertical",
				width = 0.4,
			},
		},
		action_palette = {
			provider = "telescope",
		},
	},
	opts = {
		log_level = "ERROR",
	},
})

local group = api.nvim_create_augroup("CodeCompanionConfig", { clear = true })

api.nvim_create_autocmd("FileType", {
	group = group,
	pattern = { "codecompanion", "codecompanion_cli" },
	callback = function(event)
		set_codecompanion_window_options()
		set_codecompanion_keymaps(event.buf)
	end,
})

api.nvim_create_autocmd("BufWinEnter", {
	group = group,
	callback = function(event)
		if vim.bo[event.buf].filetype == "codecompanion" or vim.bo[event.buf].filetype == "codecompanion_cli" then
			set_codecompanion_window_options()
		end
	end,
})

map(
	{ "n", "v" },
	"<leader>aa",
	"<cmd>CodeCompanionActions<cr>",
	{ noremap = true, silent = true, desc = "AI: Action Palette" }
)
map(
	{ "n", "v" },
	"<leader>ac",
	"<cmd>CodeCompanionChat Toggle<cr>",
	{ noremap = true, silent = true, desc = "AI: Toggle Chat" }
)
map(
	"v",
	"<leader>as",
	"<cmd>CodeCompanionChat Add<cr>",
	{ noremap = true, silent = true, desc = "AI: Add Selection to Chat" }
)
map("n", "<leader>aC", "<cmd>CodeCompanionCLI<cr>", { noremap = true, silent = true, desc = "AI: Claude Code CLI" })
map(
	"n",
	"<leader>aP",
	"<cmd>CodeCompanionCLI agent=copilot_cli<cr>",
	{ noremap = true, silent = true, desc = "AI: Copilot CLI" }
)
map({ "n", "v" }, "<leader>ai", "<cmd>CodeCompanion<cr>", { noremap = true, silent = true, desc = "AI: Inline Prompt" })
map("v", "<leader>ae", "<cmd>CodeCompanion /explain<cr>", { noremap = true, silent = true, desc = "AI: Explain Code" })
map("v", "<leader>af", "<cmd>CodeCompanion /fix<cr>", { noremap = true, silent = true, desc = "AI: Fix Code" })
map("v", "<leader>at", "<cmd>CodeCompanion /tests<cr>", { noremap = true, silent = true, desc = "AI: Generate Tests" })
map("n", "<leader>am", "<cmd>CodeCompanion /commit<cr>", { noremap = true, silent = true, desc = "AI: Commit Message" })

vim.cmd([[cab cc CodeCompanion]])
