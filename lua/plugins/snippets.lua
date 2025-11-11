return {
	-- Snippet engine
	{
		"L3MON4D3/LuaSnip",
		version = "v2.*",
		build = "make install_jsregexp", -- Optional: for advanced regex support
		dependencies = {
			"rafamadriz/friendly-snippets", -- Collection of snippets for various languages
		},
		config = function()
			local luasnip = require("luasnip")

			-- Load snippets from friendly-snippets
			require("luasnip.loaders.from_vscode").lazy_load()

			-- Optional: Custom snippet directory (if you want to add your own)
			-- require("luasnip.loaders.from_vscode").lazy_load({ paths = { "~/.config/nvim/snippets" } })

			-- Snippet navigation keymaps
			vim.keymap.set({ "i", "s" }, "<C-k>", function()
				if luasnip.expand_or_jumpable() then
					luasnip.expand_or_jump()
				end
			end, { silent = true, desc = "Snippet: expand or jump forward" })

			vim.keymap.set({ "i", "s" }, "<C-j>", function()
				if luasnip.jumpable(-1) then
					luasnip.jump(-1)
				end
			end, { silent = true, desc = "Snippet: jump backward" })

			vim.keymap.set({ "i", "s" }, "<C-l>", function()
				if luasnip.choice_active() then
					luasnip.change_choice(1)
				end
			end, { silent = true, desc = "Snippet: cycle choices" })
		end,
	},

	-- Snippet source for nvim-cmp
	{
		"saadparwaiz1/cmp_luasnip",
		dependencies = { "L3MON4D3/LuaSnip" },
	},
}
