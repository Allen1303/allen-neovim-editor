-- ==============================
-- lua/plugins/colorscheme.lua
-- ==============================
-- GOAL: Provide great defaults with Catppuccin (plus alternates as spares),
--       apply the theme early, and keep transparency consistent.

return {
	-- ── Catppuccin: primary theme ───────────────────────────────────────────
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000, -- load before all other UI plugins (avoids flash)
		lazy = false, -- must be available at startup
		opts = {
			flavour = "macchiato", -- latte | frappe | macchiato | mocha
			transparent_background = true, -- respect terminal transparency
			term_colors = true, -- better terminal palette matching
			no_italic = false,
			no_bold = false,

			integrations = {
				treesitter = true,
				native_lsp = {
					enabled = true,
					inlay_hints = { background = false },
					underlines = {
						errors = { "underline" },
						hints = { "underline" },
						warnings = { "underline" },
						information = { "underline" },
					},
				},
				-- FIX: was lsp_trouble = false — key changed in Catppuccin + trouble v3
				trouble = true,
				telescope = true,
				gitsigns = true,
				which_key = true,
				navic = false,
				-- ADD: styles Noice message/cmdline UI elements
				noice = true,
				-- ADD: styles custom dashboard filetype highlight groups
				dashboard = true,
				-- EXPAND: full mini integration table
				mini = {
					enabled = true,
					indentscope_color = "", -- inherits from theme palette
				},
			},

			-- Tweak highlight groups for transparent UI consistency
			custom_highlights = function(colors)
				return {
					NormalFloat = { bg = "NONE" }, -- clear floating window background
					FloatBorder = { bg = "NONE" }, -- clear floating border background
					SignColumn = { bg = "NONE" }, -- keep sign column transparent
					NormalNC = { bg = "NONE" }, -- clear inactive window background
					-- Keep statusline opaque so it stays readable over transparent bg
					StatusLine = { bg = colors.base, fg = colors.text },
					StatusLineNC = { bg = colors.mantle, fg = colors.overlay1 },
				}
			end,
		},
		config = function(_, opts)
			-- FIX: safe_colorscheme moved inside config (was module-level, unsafe for hot-reload)
			local function safe_colorscheme(name)
				local ok = pcall(vim.cmd.colorscheme, name)
				if not ok then
					vim.notify(
						("Colorscheme '%s' not found, falling back to default."):format(name),
						vim.log.levels.WARN
					)
				end
			end
			require("catppuccin").setup(opts)
			safe_colorscheme("catppuccin")
		end,
	},

	-- ── Tokyonight: alternate theme ─────────────────────────────────────────
	{
		"folke/tokyonight.nvim",
		lazy = true, -- available but not applied by default (:colorscheme tokyonight)
		opts = {
			style = "storm", -- storm | night | moon | day
			transparent = true,
			styles = {
				sidebars = "transparent",
				floats = "transparent",
			},
		},
	},

	-- ── Onedark: alternate theme ────────────────────────────────────────────
	{
		"navarasu/onedark.nvim",
		lazy = true, -- available but not applied by default (:colorscheme onedark)
		opts = {
			style = "darker", -- dark | darker | cool | deep | warm | warmer
			transparent = true,
			-- FIX: removed styles.sidebars/floats — those are TokyoNight-only keys
			-- onedark.nvim does not support them and they were causing silent no-ops
		},
	},

	-- ── Monokai Pro: alternate theme ────────────────────────────────────────
	{
		"loctvl842/monokai-pro.nvim",
		lazy = true, -- available but not applied by default (:colorscheme monokai-pro-octagon)
		opts = {
			filter = "octagon", -- classic | octagon | pro | machine | ristretto | spectrum
			transparent_background = true,
			terminal_colors = true,
			devicons = true,
			styles = {
				comment = { italic = true },
				keyword = { italic = true },
				type = { bold = true },
				storageclass = { bold = true },
				structure = { bold = true },
				parameter = { italic = true },
				annotation = { italic = true },
				tag_attribute = { italic = true },
			},
			inc_search = "background",
			background_clear = {
				"float_win",
				"toggleterm",
				"telescope",
				"which-key",
				"renamer",
				"notify",
				"nvim-tree",
				"neo-tree",
				"bufferline",
				"mini.files",
			},
		},
		config = function(_, opts)
			require("monokai-pro").setup(opts)
			-- Apply manually: :colorscheme monokai-pro-octagon
		end,
	},

	-- ── transparent.nvim: REMOVED ───────────────────────────────────────────
	-- Reason: redundant — transparency is already handled correctly via:
	--   1. transparent_background = true in each theme
	--   2. custom_highlights NormalFloat/FloatBorder/SignColumn in Catppuccin
	-- Keeping transparent.nvim risks fighting with those groups and causing flicker
}
