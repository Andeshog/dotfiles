local api = vim.api
local map = vim.keymap.set

local request_state = {}
local spinner_frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }

local function redraw_codecompanion(bufnr)
	vim.schedule(function()
		if api.nvim_buf_is_valid(bufnr) then
			pcall(api.nvim_buf_call, bufnr, function()
				vim.cmd.redrawstatus()
			end)
		end
	end)
end

local function stop_request_indicator(bufnr)
	local state = request_state[bufnr]
	if not state then
		return
	end

	if state.timer then
		pcall(function()
			state.timer:stop()
		end)
		if not state.timer:is_closing() then
			pcall(function()
				state.timer:close()
			end)
		end
	end

	request_state[bufnr] = nil
	redraw_codecompanion(bufnr)
end

local function start_request_indicator(bufnr, text)
	stop_request_indicator(bufnr)

	local timer = vim.uv.new_timer()
	request_state[bufnr] = {
		timer = timer,
		frame = 1,
		text = text or "Thinking…",
	}

	if timer then
		timer:start(
			0,
			120,
			vim.schedule_wrap(function()
				local state = request_state[bufnr]
				if not state or not api.nvim_buf_is_valid(bufnr) then
					stop_request_indicator(bufnr)
					return
				end

				state.frame = (state.frame % #spinner_frames) + 1
				redraw_codecompanion(bufnr)
			end)
		)
	end

	redraw_codecompanion(bufnr)
end

local function update_request_indicator(bufnr, text)
	local state = request_state[bufnr]
	if not state then
		start_request_indicator(bufnr, text)
		return
	end

	if text and text ~= "" and state.text ~= text then
		state.text = text
		redraw_codecompanion(bufnr)
	end
end

local function get_chat_event_bufnr(args)
	local candidates = {
		args and args.data and args.data.bufnr,
		args and args.buf,
		api.nvim_get_current_buf(),
	}

	for _, bufnr in ipairs(candidates) do
		if type(bufnr) == "number" and api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].filetype == "codecompanion" then
			return bufnr
		end
	end
end

local function is_gpt5_model(model)
	return type(model) == "string" and vim.startswith(model, "gpt-5")
end

local function get_adapter_model(adapter)
	if not adapter then
		return nil
	end

	local model = adapter.model
	if type(model) == "table" then
		return model.formatted_name or model.name or model.id
	end
	if type(model) == "string" then
		return model
	end

	local schema_model = adapter.schema and adapter.schema.model and adapter.schema.model.default
	if type(schema_model) == "function" then
		local ok, resolved = pcall(schema_model, adapter)
		if ok then
			schema_model = resolved
		else
			schema_model = nil
		end
	end

	if type(schema_model) == "string" then
		return schema_model
	end
end

local function get_adapter_label(adapter)
	if not adapter then
		return "Unknown"
	end

	local parts = { adapter.formatted_name or adapter.name or "Unknown" }
	local model = get_adapter_model(adapter)

	if model and model ~= "" and model ~= parts[1] then
		table.insert(parts, model)
	elseif adapter.type == "acp" then
		table.insert(parts, "ACP")
	end

	return table.concat(parts, " · ")
end

local function get_chat_status(bufnr)
	local state = request_state[bufnr]
	if state then
		return string.format("%s %s", spinner_frames[state.frame] or spinner_frames[1], state.text)
	end

	local chat = require("codecompanion").buf_get_chat(bufnr)
	if not chat then
		return "ready"
	end

	if chat.status and chat.status ~= "" then
		return chat.status
	end

	return "ready"
end

local function escape_statusline(text)
	return tostring(text or ""):gsub("%%", "%%%%")
end

local function get_chat_winbar(bufnr)
	local ok, chat = pcall(require("codecompanion").buf_get_chat, bufnr)
	if not ok or not chat or not chat.adapter then
		return " CodeCompanion "
	end

	return string.format(
		" CodeCompanion · %s · send <C-s> · %s ",
		escape_statusline(get_adapter_label(chat.adapter)),
		escape_statusline(get_chat_status(bufnr))
	)
end

local function get_codecompanion_winhighlight()
	return table.concat({
		"Normal:Normal",
		"NormalNC:NormalNC",
		"EndOfBuffer:EndOfBuffer",
		"SignColumn:SignColumn",
		"FoldColumn:FoldColumn",
		"WinBar:CodeCompanionWinBar",
		"WinBarNC:CodeCompanionWinBarNC",
	}, ",")
end

local function close_window()
	vim.cmd.close()
end

local function toggle_cli_agent(agent_name)
	local cli = require("codecompanion.interactions.cli")
	local instance = cli.find_by_agent(agent_name)
	if instance then
		if instance.ui:is_visible() then
			instance.ui:hide()
		else
			instance.ui:open()
			instance:focus()
		end
	else
		require("codecompanion").cli({ agent = agent_name })
	end
end

local function set_codecompanion_window_options(winid)
	if not winid or not api.nvim_win_is_valid(winid) then
		return
	end

	vim.wo[winid].number = false
	vim.wo[winid].relativenumber = false
	vim.wo[winid].foldcolumn = "0"
	vim.wo[winid].signcolumn = "no"
	vim.wo[winid].statuscolumn = ""
	vim.wo[winid].winhighlight = get_codecompanion_winhighlight()
end

local function refresh_codecompanion_windows(bufnr)
	for _, winid in ipairs(vim.fn.win_findbuf(bufnr)) do
		set_codecompanion_window_options(winid)
	end
end

local function set_codecompanion_keymaps(bufnr)
	if vim.b[bufnr].codecompanion_keymaps_set then
		return
	end

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

	vim.b[bufnr].codecompanion_keymaps_set = true
end

require("codecompanion").setup({
	interactions = {
		chat = {
			adapter = {
				name = "copilot",
				model = "gpt-5.4",
			},
			keymaps = {
				send = {
					modes = {
						n = { "<CR>", "<C-s>" },
						i = "<C-s>",
					},
				},
			},
			roles = {
				llm = function(adapter)
					return get_adapter_label(adapter)
				end,
				user = "You",
			},
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
		http = {
			copilot = function()
				return require("codecompanion.adapters").extend("copilot", {
					schema = {
						top_p = {
							enabled = function(self)
								local model = self.schema.model.default
								if type(model) == "function" then
									model = model(self)
								end
								return not vim.startswith(model, "o1") and not is_gpt5_model(model)
							end,
						},
						n = {
							enabled = function(self)
								local model = self.schema.model.default
								if type(model) == "function" then
									model = model(self)
								end
								return not vim.startswith(model, "o1") and not is_gpt5_model(model)
							end,
						},
					},
				})
			end,
		},
	},
	display = {
		chat = {
			intro_message = "CodeCompanion chat · <C-s> sends · ? shows chat keymaps",
			show_header_separator = true,
			show_token_count = true,
			token_count = function(tokens, adapter)
				return string.format(" (%s · %d tokens)", get_adapter_label(adapter), tokens)
			end,
			window = {
				layout = "vertical",
				width = 0.35,
				opts = {
					winbar = "%!v:lua.CodeCompanionChatWinbarDotfiles()",
					winhighlight = get_codecompanion_winhighlight(),
				},
			},
		},
		cli = {
			window = {
				layout = "vertical",
				width = 0.4,
				opts = {
					winhighlight = get_codecompanion_winhighlight(),
				},
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

_G.CodeCompanionChatWinbarDotfiles = function()
	local ok, winbar = pcall(get_chat_winbar, api.nvim_get_current_buf())
	if ok then
		return winbar
	end
	return " CodeCompanion "
end

api.nvim_create_autocmd("FileType", {
	group = group,
	pattern = { "codecompanion", "codecompanion_cli" },
	callback = function(event)
		refresh_codecompanion_windows(event.buf)
		set_codecompanion_keymaps(event.buf)
	end,
})

api.nvim_create_autocmd("BufWinEnter", {
	group = group,
	callback = function(event)
		if vim.bo[event.buf].filetype == "codecompanion" or vim.bo[event.buf].filetype == "codecompanion_cli" then
			refresh_codecompanion_windows(event.buf)
		end
	end,
})

api.nvim_create_autocmd("User", {
	group = group,
	pattern = {
		"CodeCompanionChatOpened",
		"CodeCompanionChatSubmitted",
		"CodeCompanionRequestStarted",
		"CodeCompanionRequestStreaming",
		"CodeCompanionRequestFinished",
		"CodeCompanionChatDone",
		"CodeCompanionChatAdapter",
		"CodeCompanionChatModel",
	},
	callback = function(args)
		local bufnr = get_chat_event_bufnr(args)
		if not bufnr then
			return
		end

		if args.match == "CodeCompanionChatSubmitted" or args.match == "CodeCompanionRequestStarted" then
			start_request_indicator(bufnr, "Thinking…")
		elseif args.match == "CodeCompanionRequestStreaming" then
			update_request_indicator(bufnr, "Responding…")
		elseif args.match == "CodeCompanionRequestFinished" or args.match == "CodeCompanionChatDone" then
			stop_request_indicator(bufnr)
		end

		vim.schedule(function()
			if api.nvim_buf_is_valid(bufnr) then
				refresh_codecompanion_windows(bufnr)
				set_codecompanion_keymaps(bufnr)
				redraw_codecompanion(bufnr)
			end
		end)
	end,
})

api.nvim_create_autocmd("BufWipeout", {
	group = group,
	callback = function(args)
		stop_request_indicator(args.buf)
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
map("n", "<leader>aC", function()
	toggle_cli_agent("claude_code")
end, { noremap = true, silent = true, desc = "AI: Toggle Claude Code CLI" })
map("n", "<leader>aP", function()
	toggle_cli_agent("copilot_cli")
end, { noremap = true, silent = true, desc = "AI: Toggle Copilot CLI" })
map("n", "<leader>a<space>", function()
	require("codecompanion").toggle()
end, { noremap = true, silent = true, desc = "AI: Toggle last interaction (chat/CLI)" })
map({ "n", "v" }, "<leader>ai", "<cmd>CodeCompanion<cr>", { noremap = true, silent = true, desc = "AI: Inline Prompt" })
map("v", "<leader>ae", "<cmd>CodeCompanion /explain<cr>", { noremap = true, silent = true, desc = "AI: Explain Code" })
map("v", "<leader>af", "<cmd>CodeCompanion /fix<cr>", { noremap = true, silent = true, desc = "AI: Fix Code" })
map("v", "<leader>at", "<cmd>CodeCompanion /tests<cr>", { noremap = true, silent = true, desc = "AI: Generate Tests" })
map("n", "<leader>am", "<cmd>CodeCompanion /commit<cr>", { noremap = true, silent = true, desc = "AI: Commit Message" })

vim.cmd([[cab cc CodeCompanion]])
