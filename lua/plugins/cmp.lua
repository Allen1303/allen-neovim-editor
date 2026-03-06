-- ==============================
-- lua/plugins/cmp.lua
-- ==============================

return {
	-- ── LuaSnip: snippet engine ────────────────────────────────────────────
	-- NOTE: snippets.lua deleted — this spec is the single source of truth
	-- Keys absorbed here; friendly-snippets loaded in config
	{
		"L3MON4D3/LuaSnip",
		version = "v2.*", -- FIX: pinned to v2 stable (was "*")
		build = "make install_jsregexp", -- enables regex-based snippet transforms
		dependencies = { "rafamadriz/friendly-snippets" },
		-- ADD: snippet jump keys live here so LuaSnip lazy-loads on first jump
		-- <C-k> jumps forward / expands — freed from LSP (lsp-config uses <C-s> now)
		-- <C-j> jumps backward through placeholders
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
			-- Load VS Code-style snippets from friendly-snippets
			require("luasnip.loaders.from_vscode").lazy_load()
		end,
	},

	-- ── nvim-cmp: main completion engine ───────────────────────────────────
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			-- Snippet engine
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
			-- Completion sources
			"hrsh7th/cmp-nvim-lsp", -- LSP completions
			"hrsh7th/cmp-buffer", -- buffer word completions
			"hrsh7th/cmp-path", -- filesystem path completions
			"hrsh7th/cmp-cmdline", -- cmdline completions
			-- Kind icons in the completion menu
			"onsails/lspkind.nvim", -- ADD: shows kind icons (function, variable, class, etc.)
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			local lspkind = require("lspkind")

			cmp.setup({

				-- ── Performance ──────────────────────────────────────────
				-- ADD: prevents sluggish menus on large files / many sources
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
					-- ADD: Vim-native navigation (<C-n>/<C-p>) alongside Tab
					["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
					["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),

					-- Doc scrolling
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),

					-- Trigger completion manually
					["<C-Space>"] = cmp.mapping.complete(),

					-- Abort / dismiss
					["<C-e>"] = cmp.mapping.abort(),

					-- FIX: was select = true — caused accidental confirmation on <CR>
					-- select = false only confirms explicitly selected items
					["<CR>"] = cmp.mapping.confirm({ select = false }),

					-- Tab: navigate menu OR jump through snippet placeholders
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						elseif vim.fn["emmet#isExpandable"]() == 1 then
							vim.fn["emmet#expandAbbr"](0, "")
						else
							fallback()
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

				-- ── Sources with priority weights ─────────────────────────
				-- FIX: added priority so LSP results always rank above buffer words
				sources = cmp.config.sources({
					{ name = "nvim_lsp", priority = 1000 },
					{ name = "luasnip", priority = 750 },
					{ name = "path", priority = 500 },
					{ name = "buffer", priority = 250 },
				}),

				-- ── Formatting: kind icons + source label ─────────────────
				-- ADD: lspkind shows kind icons (⊕ Function, ● Variable, etc.)
				formatting = {
					format = function(entry, item)
						-- Apply lspkind kind icons first
						item = lspkind.cmp_format({
							mode = "symbol_text",
							maxwidth = 50,
							ellipsis_char = "...",
						})(entry, item)

						-- Append source icon as menu label
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

			-- ── Cmdline completion (:commands) ────────────────────────────
			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = "path" },
					{ name = "cmdline" },
				}),
			})

			-- ── Search completion (/) ─────────────────────────────────────
			cmp.setup.cmdline("/", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = "buffer" },
				},
			})
		end,
	},
}
