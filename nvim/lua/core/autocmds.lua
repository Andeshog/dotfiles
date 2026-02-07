local api = vim.api

api.nvim_create_autocmd("FileType", {
	pattern = { "dap-float", "dapui_hover", "dap-preview" },
	callback = function(ev)
		local opts = { buffer = ev.buf, silent = true, nowait = true }
		-- Close just this window
		vim.keymap.set("n", "q", function()
			vim.api.nvim_win_close(0, true)
		end, opts)
		vim.keymap.set("n", "<Esc>", function()
			vim.api.nvim_win_close(0, true)
		end, opts)
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "neo-tree",
	callback = function(ev)
		local opts = { buffer = ev.buf, silent = true, nowait = true }

		vim.keymap.set("n", "<Esc>", function()
			require("neo-tree.command").execute({ action = "close" })
		end, opts)
	end,
})

api.nvim_create_autocmd("FileType", {
	pattern = "spectre_panel",
	callback = function()
		local hl = api.nvim_set_hl

		-- --- CORE ACTION COLORS ---
		hl(0, "SpectreSearch", {
			fg = "#000000",
			bg = "#ffb86c",
			bold = true,
		})

		hl(0, "SpectreReplace", {
			fg = "#000000",
			bg = "#50fa7b",
			bold = true,
		})

		-- --- STRUCTURE / UI ---
		hl(0, "SpectreTitle", {
			fg = "#8be9fd",
			bold = true,
		})

		hl(0, "SpectreBorder", {
			fg = "#6272a4",
		})

		-- --- CONTEXT / METADATA ---
		hl(0, "SpectreFile", {
			fg = "#bd93f9",
			bold = true,
		})

		hl(0, "SpectreDir", {
			fg = "#6272a4",
		})

		hl(0, "SpectrePath", {
			fg = "#6272a4",
			italic = true,
		})

		hl(0, "SpectreLine", {
			fg = "#44475a",
		})

		hl(0, "SpectreBody", {
			fg = "#f8f8f2",
		})
	end,
})

api.nvim_create_autocmd("User", {
	pattern = { "LspProgressUpdate", "LspRequest" },
	callback = function()
		vim.cmd("redrawstatus")
	end,
})

local ignore_filetypes = { "neo-tree", "Trouble", "help" }
local ignore_buftypes = { "nofile", "prompt", "popup", "quickfix", "terminal" }

local augroup = vim.api.nvim_create_augroup("FocusDisableForUI", { clear = true })

api.nvim_create_autocmd("WinEnter", {
	group = augroup,
	callback = function()
		if vim.tbl_contains(ignore_buftypes, vim.bo.buftype) then
			vim.w.focus_disable = true
		else
			vim.w.focus_disable = false
		end
	end,
	desc = "Disable focus autoresize for BufType",
})

api.nvim_create_autocmd("FileType", {
	group = augroup,
	callback = function()
		if vim.tbl_contains(ignore_filetypes, vim.bo.filetype) then
			vim.b.focus_disable = true
		else
			vim.b.focus_disable = false
		end
	end,
	desc = "Disable focus autoresize for FileType",
})
