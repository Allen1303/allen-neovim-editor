-- ==============================
-- lua/plugins/colorscheme.lua
-- ==============================
-- GOAL: Provide great defaults with Catppuccin (plus Tokyonight as a spare),
--       apply the theme early, and keep transparency consistent.

-- this local function safely applies a colorscheme without throwing UI errors
local function safe_colorscheme(name)
	local ok = pcall(vim.cmd.colorscheme, name)
	if not ok then
		vim.notify(("Colorscheme '%s' not found, falling back to default."):format(name), vim.log.levels.WARN)
	end
end

return {
	-- Catppuccin: polished theme with broad plugin integrations
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000, -- this setting loads theme before other UI plugins (avoids flash)
		lazy = false, -- this setting ensures theme is available at startup
		opts = {
			flavour = "macchiato", -- this option selects a palette (latte, frappe, macchiato, mocha)
			transparent_background = true, -- this option removes the background to respect terminal transparency
			term_colors = true, -- this option enables terminal palette (better matching)
			no_italic = false, -- this option keeps italics (tweak to taste)
			no_bold = false, -- this option keeps bold (tweak to taste)
			integrations = {
				treesitter = true, -- this option enables Treesitter highlight groups
				native_lsp = { -- this table styles built-in LSP highlights
					enabled = true,
					inlay_hints = { background = false },
					underlines = {
						errors = { "underline" },
						hints = { "underline" },
						warnings = { "underline" },
						information = { "underline" },
					},
				},
				-- Add per-plugin integrations as we bring them in
				lsp_trouble = false,
				telescope = true,
				gitsigns = true,
				which_key = true,
				navic = false,
				mini = true,
			},
			custom_highlights = function(colors) -- this function tweaks a few groups to play nice with transparency
				return {
					NormalFloat = { bg = "NONE" }, -- this group clears floating window background
					FloatBorder = { bg = "NONE" }, -- this group clears floating border background
					SignColumn = { bg = "NONE" }, -- this group keeps sign column transparent
					NormalNC = { bg = "NONE" }, -- this group clears inactive window background
					-- Make statusline opaque even with transparent UI:
					StatusLine = { bg = colors.base, fg = colors.text }, -- pick any combo you like
					StatusLineNC = { bg = colors.mantle, fg = colors.overlay1 }, -- slightly dimmer for inactive
				}
			end,
		},
		config = function(_, opts)
			require("catppuccin").setup(opts) -- this call applies Catppuccin options
			safe_colorscheme("catppuccin") -- this call sets the active theme (with fallback handling)
		end,
	},

	-- Tokyonight: excellent alternate theme (kept installed for easy switching)
	{
		"folke/tokyonight.nvim",
		lazy = true, -- this setting keeps it available but not applied by default
		opts = {
			style = "storm", -- this option selects a variant (storm, night, moon, day)
			transparent = true, -- this option mirrors our transparency preference
			styles = {
				sidebars = "transparent",
				floats = "transparent",
			},
		},
	},
	-- Onedark Theme  excellent alternate theme (kept installed for easy switching)
	{
		"navarasu/onedark.nvim",
		lazy = true, -- this setting keeps it available but not applied by default
		opts = {
			style = "darker", -- this option selects a variant (dark, darker, ect..)
			transparent = true, -- this option mirrors our transparency preference
			styles = {
				sidebars = "transparent",
				floats = "transparent",
			},
		},
	},
	-- Optional utility: ensure transparency is preserved even if a theme flips it
	{
		"xiyaowong/transparent.nvim",
		lazy = true, -- this plugin is only used if you actively :TransparentEnable
		opts = {
			extra_groups = {
				"NormalFloat",
				"NvimTreeNormal",
				"TelescopeNormal",
				"TelescopeBorder",
				"SignColumn",
				"LineNr",
			},
			exclude_groups = { "StatusLine", "StatusLineNC" }, -- this table lets you protect groups from becoming transparent
		},
	},
}
