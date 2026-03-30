local builtin = require("statuscol.builtin")
require("statuscol").setup({
	relculright = true,
	segments = {
		-- Git signs
		{
			sign = { namespace = { "gitsigns" }, maxwidth = 1, colwidth = 1 },
			click = "v:lua.ScSa",
		},
		-- Line numbers
		{
			text = { builtin.lnumfunc, " " },
			click = "v:lua.ScLa",
		},
	},
})
