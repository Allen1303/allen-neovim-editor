-- ==============================
-- lua/plugins/colorscheme.lua
-- ==============================
-- GOAL: Provide great defaults with Catppuccin (plus alternates as spares),
--       apply the theme early, and keep transparency consistent.
--
-- Active theme:   catppuccin-macchiato
-- Alternates:     :colorscheme tokyonight
--                 :colorscheme onedark          (onedarkpro — accurate Atom One Dark)
--                 :colorscheme onedark_vivid     (onedarkpro — more vibrant variant)
--                 :colorscheme onedark_dark      (onedarkpro — darker variant)
--                 :colorscheme monokai-pro-octagon
--                 :colorscheme vscode
--                 :colorscheme one_monokai       (VSCode One Monokai port)
--                 :colorscheme oxocarbon

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

	-- ── One Monokai: alternate theme ────────────────────────────────────────
	-- Direct Lua port of the VSCode One Monokai theme
	-- Also includes a lualine theme — set via lualine opts: theme = "one_monokai"
	-- Apply with: :colorscheme one_monokai
	{
		"cpea2506/one_monokai.nvim",
		lazy = true,
		opts = {
			transparent = true,
			italics = true,
			colors = {},
			highlights = function()
				return {}
			end,
		},
	},

	-- ── VSCode: alternate theme ─────────────────────────────────────────────
	-- Apply with: :colorscheme vscode
	{
		"Mofiqul/vscode.nvim",
		lazy = true,
		opts = {
			style = "dark",
			transparent = true,
			italic_comments = true,
			disable_nvimtree_bg = true,
			color_overrides = {},
			group_overrides = {
				NormalFloat = { bg = "NONE" },
				FloatBorder = { bg = "NONE" },
				SignColumn = { bg = "NONE" },
				NormalNC = { bg = "NONE" },
			},
		},
		config = function(_, opts)
			require("vscode").setup(opts)
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

	-- ── OneDark Pro: alternate theme ────────────────────────────────────────
	-- Apply with: :colorscheme onedark | onedark_vivid | onedark_dark
	{
		"olimorris/onedarkpro.nvim",
		lazy = true,
		opts = {
			styles = {
				comments = "italic",
				keywords = "bold",
				functions = "italic",
				variables = "NONE",
				strings = "NONE",
				types = "bold",
			},
			options = {
				transparency = true,
				terminal_colors = true,
				lualine_transparency = true,
			},
			plugins = {
				all = false,
				treesitter = true,
				telescope = true,
				which_key = true,
				gitsigns = true,
				nvim_lsp = true,
				nvim_cmp = true,
				nvim_notify = true,
				trouble = true,
				["bufferline.nvim"] = true,
				["nvim-dap-ui"] = true,
			},
			highlights = {
				NormalFloat = { bg = "NONE" },
				FloatBorder = { bg = "NONE" },
				SignColumn = { bg = "NONE" },
				NormalNC = { bg = "NONE" },
			},
		},
		config = function(_, opts)
			require("onedarkpro").setup(opts)
		end,
	},

	-- ── Oxocarbon: alternate theme ──────────────────────────────────────────
	-- IBM Carbon inspired — cool blue/cyan tones
	-- Apply with: :colorscheme oxocarbon
	{
		"nyoom-engineering/oxocarbon.nvim",
		lazy = true,
		config = function()
			vim.api.nvim_create_autocmd("ColorScheme", {
				pattern = "oxocarbon",
				callback = function()
					local set = vim.api.nvim_set_hl
					pcall(set, 0, "NormalFloat", { bg = "NONE" })
					pcall(set, 0, "FloatBorder", { bg = "NONE" })
					pcall(set, 0, "SignColumn", { bg = "NONE" })
					pcall(set, 0, "NormalNC", { bg = "NONE" })
				end,
			})
		end,
	},

	-- ── Monokai Pro: alternate theme ────────────────────────────────────────
	-- Apply with: :colorscheme monokai-pro-octagon (or other filters)
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
