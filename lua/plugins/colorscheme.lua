-- ==============================
-- lua/plugins/colorscheme.lua
-- ==============================
-- GOAL: Provide great defaults with Catppuccin (plus alternates as spares),
--       apply the theme early, and keep transparency consistent.
--
-- Active theme:   catppuccin-macchiato
-- Alternates:     :colorscheme tokyonight
--                 :colorscheme onedark
--                 :colorscheme monokai-pro-octagon
--                 :colorscheme vscode

return {
	-- ── Catppuccin: primary theme ───────────────────────────────────────────
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		lazy = false,
		opts = {
			flavour = "macchiato",
			transparent_background = true,
			term_colors = true,
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
				trouble = true,
				telescope = true,
				gitsigns = true,
				which_key = true,
				navic = false,
				noice = true,
				dashboard = true,
				mini = {
					enabled = true,
					indentscope_color = "",
				},
			},

			custom_highlights = function(colors)
				return {
					NormalFloat = { bg = "NONE" },
					FloatBorder = { bg = "NONE" },
					SignColumn = { bg = "NONE" },
					NormalNC = { bg = "NONE" },
					StatusLine = { bg = colors.base, fg = colors.text },
					StatusLineNC = { bg = colors.mantle, fg = colors.overlay1 },
				}
			end,
		},
		config = function(_, opts)
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

	-- ── VSCode: alternate theme ─────────────────────────────────────────────
	-- Accurate port of VSCode's default Dark+ theme
	-- Apply with: :colorscheme vscode
	{
		"Mofiqul/vscode.nvim",
		lazy = true,
		opts = {
			-- dark | light
			style = "dark",

			-- Match VSCode's transparent feel
			transparent = true,

			-- Italic comments and keywords (matches VSCode defaults)
			italic_comments = true,

			-- Disable nvim-cmp highlights if you want pure VSCode colors
			disable_nvimtree_bg = true,

			-- Override specific highlight groups if needed
			color_overrides = {},

			-- Full treesitter + LSP semantic token support
			group_overrides = {
				-- keep floating windows transparent
				NormalFloat = { bg = "NONE" },
				FloatBorder = { bg = "NONE" },
				SignColumn = { bg = "NONE" },
				NormalNC = { bg = "NONE" },
			},
		},
		config = function(_, opts)
			require("vscode").setup(opts)
			-- Apply manually: :colorscheme vscode
		end,
	},

	-- ── Tokyonight: alternate theme ─────────────────────────────────────────
	{
		"folke/tokyonight.nvim",
		lazy = true,
		opts = {
			style = "storm",
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
		lazy = true,
		opts = {
			style = "darker",
			transparent = true,
		},
	},

	-- ── Monokai Pro: alternate theme ────────────────────────────────────────
	{
		"loctvl842/monokai-pro.nvim",
		lazy = true,
		opts = {
			filter = "octagon",
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
		end,
	},
}
