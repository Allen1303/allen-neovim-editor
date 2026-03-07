-- ==============================
-- lua/plugins/cmp.lua
-- ==============================

return {
	-- ── LuaSnip: snippet engine ────────────────────────────────────────────
	-- NOTE: snippets.lua deleted — this spec is the single source of truth
	-- Keys absorbed here; friendly-snippets loaded in config
	{
		"L3MON4D3/LuaSnip",
		version = "v2.*",
		build = "make install_jsregexp",
		dependencies = { "rafamadriz/friendly-snippets" },
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
		config = function()
			require("luasnip.loaders.from_vscode").lazy_load()
		end,
	},

	-- ── nvim-cmp: main completion engine ───────────────────────────────────
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"onsails/lspkind.nvim",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			local lspkind = require("lspkind")

			cmp.setup({

				-- ── Performance ──────────────────────────────────────────
				performance = {
					debounce = 60,
					throttle = 30,
					fetching_timeout = 500,
					max_view_entries = 20,
				},

				-- ── Snippet expansion ─────────────────────────────────────
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},

				-- ── Windows ───────────────────────────────────────────────
				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},

				-- ── Keymaps ───────────────────────────────────────────────
				mapping = cmp.mapping.preset.insert({
					["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
					["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),

					-- Only confirm explicitly selected items
					["<CR>"] = cmp.mapping.confirm({ select = false }),

					-- Tab priority:
					--   1. Navigate cmp menu if visible
					--   2. Jump through luasnip placeholders
					--   3. Expand emmet abbreviation (mode 3 handles all complex syntax:
					--      p{text}+button*3, div.container>ul>li*3, header>nav>a*4)
					--   4. Fallback to normal Tab
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						else
							-- FIX: was emmet#isExpandable() == 1 which returns 0 for
							-- complex abbreviations like p{text}+button*3
							-- mode 3 = full expand — handles all emmet syntax
							local ok = pcall(vim.fn["emmet#expandAbbr"], 3, "")
							if not ok then
								fallback()
							end
						end
					end, { "i", "s" }),

					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
				}),

				-- ── Sources ───────────────────────────────────────────────
				sources = cmp.config.sources({
					{ name = "nvim_lsp", priority = 1000 },
					{ name = "luasnip", priority = 750 },
					{ name = "path", priority = 500 },
					{ name = "buffer", priority = 250 },
				}),

				-- ── Formatting ────────────────────────────────────────────
				formatting = {
					format = function(entry, item)
						item = lspkind.cmp_format({
							mode = "symbol_text",
							maxwidth = 50,
							ellipsis_char = "...",
						})(entry, item)

						local source_icons = {
							nvim_lsp = "",
							luasnip = "",
							buffer = "",
							path = "",
						}
						item.menu = source_icons[entry.source.name] or entry.source.name
						return item
					end,
				},
			})

			-- ── Cmdline completion ────────────────────────────────────────
			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = "path" },
					{ name = "cmdline" },
				}),
			})

			-- ── Search completion ─────────────────────────────────────────
			cmp.setup.cmdline("/", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = "buffer" },
				},
			})
		end,
	},
}
