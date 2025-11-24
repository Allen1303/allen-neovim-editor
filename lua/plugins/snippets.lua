return {
	{
		"L3MON4D3/LuaSnip",
		version = "v2.*",
		build = "make install_jsregexp",
		keys = {
			{
				"<C-k>",
				function()
					local ls = require("luasnip")
					if ls.expand_or_jumpable() then
						ls.expand_or_jump()
					end
				end,
				mode = { "i", "s" },
				desc = "Snippet: expand or jump forward",
			},
			{
				"<C-j>",
				function()
					local ls = require("luasnip")
					if ls.jumpable(-1) then
						ls.jump(-1)
					end
				end,
				mode = { "i", "s" },
				desc = "Snippet: jump backward",
			},
		},
	},
}
