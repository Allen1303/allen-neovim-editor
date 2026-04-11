-- ==============================
-- lua/plugins/tailwind.lua
-- ==============================
-- tailwind-tools.nvim: Tailwind CSS color swatches + class sorting
-- Works with your existing tailwindcss LSP and nvim-cmp setup
--
-- Features:
--   - Color swatches in cmp menu next to every Tailwind color class
--   - Inline color hints next to classes in the buffer
--   - Class sorting via :TailwindSort
--   - Works in JSX, TSX, HTML, CSS

return {
	{
		"luckasRanarison/tailwind-tools.nvim",
		version = false,
		event = { "BufReadPost", "BufNewFile" },
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-telescope/telescope.nvim", -- optional but you have it
		},
		opts = {
			server = {
				-- Don't override LSP setup — we handle that in lsp-config.lua
				override = false,
			},

			document_color = {
				-- Show color swatches inline next to Tailwind classes in buffer
				enabled = true,
				kind = "inline", -- "inline" | "foreground" | "background"
				inline_symbol = "󰝤 ", -- swatch icon shown next to the class
				debounce = 200,
			},

			conceal = {
				-- Optionally shorten long class strings in the buffer
				enabled = false,
				min_length = nil,
				symbol = "󱏿",
			},

			cmp = {
				-- Show color swatches in cmp completion menu
				highlight = "foreground", -- "foreground" | "background"
			},

			telescope = {
				-- Utilities for searching Tailwind classes
				utilities = {
					load_on_startup = false,
				},
			},

			keymaps = {
				-- Jump between Tailwind classes in the buffer
				next_color = {
					key = "]w",
					mode = { "n", "x" },
					desc = "Tailwind: next color",
				},
				prev_color = {
					key = "[w",
					mode = { "n", "x" },
					desc = "Tailwind: prev color",
				},
				-- Change color shade up/down while cursor is on a class
				increment_color = {
					key = "<leader>tk",
					mode = { "n", "x" },
					desc = "Tailwind: increment shade",
				},
				decrement_color = {
					key = "<leader>tj",
					mode = { "n", "x" },
					desc = "Tailwind: decrement shade",
				},
			},
		},
	},
}
