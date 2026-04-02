local function centered_lnum(args)
	if not args.rnu and not args.nu then
		return ""
	end

	if args.virtnum ~= 0 then
		return (" "):rep(args.nuw)
	end

	local lnum = args.rnu and (args.relnum > 0 and args.relnum or (args.nu and args.lnum or 0)) or args.lnum
	lnum = tostring(lnum)

	local total_pad = math.max(args.nuw - #lnum, 0)
	local left_pad = math.floor(total_pad / 2)
	local right_pad = total_pad - left_pad

	return (" "):rep(left_pad) .. lnum .. (" "):rep(right_pad)
end

require("statuscol").setup({
	ft_ignore = { "codecompanion", "codecompanion_cli" },
	relculright = true,
	segments = {
		-- Git signs
		{
			sign = { namespace = { "gitsigns" }, maxwidth = 1, colwidth = 1, fillcharhl = "LineNr" },
			click = "v:lua.ScSa",
		},
		-- Line numbers
		{
			text = { centered_lnum },
			hl = "LineNr",
			click = "v:lua.ScLa",
		},
		-- Neotest > DAP > diagnostics (first match wins)
		{
			sign = { name = { "neotest_.*", "Dap.*" }, namespace = { "diagnostic%.signs" }, maxwidth = 1, colwidth = 1, auto = " ", fillcharhl = "LineNr" },
			click = "v:lua.ScSa",
		},
		{
			text = { " " },
			hl = "LineNr",
		},
		{
			text = { "▏" },
			hl = "WinSeparator",
		},
	},
})
