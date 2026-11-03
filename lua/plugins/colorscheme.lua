-- ==============================
-- lua/plugins/colorscheme.lua
-- ==============================
-- GOAL: Provide great defaults with Catppuccin (plus alternates as spares),
--       apply the theme early, and keep transparency consistent.
--
-- Active theme:   catppuccin-macchiato
-- Alternates:     :colorscheme tokyonight
--                 :colorscheme onedark          (onedarkpro, tuned to akamud's Atom One Dark)
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
	-- onedark is tuned to match akamud's "Atom One Dark" VS Code theme
	-- (https://github.com/akamud/vscode-theme-onedark); onedark_vivid and
	-- onedark_dark keep One Dark Pro's colors.
	{
		"olimorris/onedarkpro.nvim",
		lazy = true,
		opts = {
			-- Atom One Dark editor colors (One Dark Pro's are lighter/darker)
			colors = {
				onedark = {
					comment = "#5c6370",
					line_number = "#636d83",
					selection = "#3e4451",
				},
			},
			-- Atom One Dark styles: italic comments, nothing else bold or italic
			-- (styles are global, so onedark_vivid / onedark_dark follow too)
			styles = {
				comments = "italic",
				keywords = "NONE",
				functions = "NONE",
				variables = "NONE",
				strings = "NONE",
				types = "NONE",
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
				-- Keys must match onedarkpro's highlights/plugins/*.lua file names;
				-- it has no bufferline integration
				nvim_dap_ui = true,
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

			-- onedark only: syntax colors from the Atom One Dark VS Code theme.
			-- @variable.declaration, @variable.builtin.console and @keyword.default
			-- come from after/queries/ecma/highlights.scm (JS, TS, JSX, TSX).
			vim.api.nvim_create_autocmd("ColorScheme", {
				group = vim.api.nvim_create_augroup("Allen_Atom_OneDark", { clear = true }),
				pattern = "onedark",
				callback = function()
					local set = vim.api.nvim_set_hl
					local text, red, dark_red, orange = "#abb2bf", "#e06c75", "#be5046", "#d19a66"
					local cursor_line = "#2c313a"

					-- Atom shows variables and parameters as plain text; One Dark Pro paints them red
					set(0, "@variable", { fg = text })
					set(0, "@variable.parameter", { fg = text })
					set(0, "@variable.builtin", { fg = red }) -- this, super, document, window
					set(0, "@variable.builtin.console", { fg = text })
					set(0, "@variable.declaration", { fg = orange }) -- const names where declared
					set(0, "@keyword.default", { fg = red }) -- export default
					set(0, "@tag.builtin", { fg = red }) -- <div> in JSX
					set(0, "@punctuation.bracket", { fg = text })
					set(0, "@punctuation.special", { fg = dark_red }) -- ${ } in template strings
					set(0, "CursorLine", { bg = cursor_line })
					set(0, "CursorLineNr", { fg = text, bg = cursor_line })

					-- onedarkpro also defines per-language groups (@variable.javascript, ...)
					-- that win over the generic ones; point them back at the colors above
					for _, lang in ipairs({ "javascript", "typescript", "tsx", "jsx" }) do
						set(0, "@variable." .. lang, { link = "@variable" })
						set(0, "@variable.builtin." .. lang, { link = "@variable.builtin" })
						set(0, "@parameter." .. lang, { link = "@variable.parameter" })
						set(0, "@punctuation.bracket." .. lang, { link = "@punctuation.bracket" })
					end
					-- ...and colors JS braces by context ({ } of blocks, objects, functions)
					for _, group in ipairs(vim.fn.getcompletion("@odp", "highlight")) do
						if group:match("punctuation%.bracket") then
							set(0, group, { fg = text })
						end
					end

					-- The VS Code theme doesn't use semantic highlighting, so clear the
					-- LSP semantic token groups and let the Treesitter colors show
					for _, group in ipairs(vim.fn.getcompletion("@lsp", "highlight")) do
						set(0, group, {})
					end
				end,
			})
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
