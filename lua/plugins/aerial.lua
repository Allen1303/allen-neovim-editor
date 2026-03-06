-- ==============================
-- lua/plugins/aerial.lua
-- ==============================
-- aerial.nvim: code outline / symbols panel
-- Shows functions, classes, variables in a sidebar or Telescope picker
--
-- Usage:
--   <leader>cs       → toggle aerial sidebar
--   <leader>cS       → aerial symbols via Telescope
--   {  / }           → jump to prev/next symbol

return {
	{
		"stevearc/aerial.nvim",
		version = "*",
		event = { "BufReadPost", "BufNewFile" },
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-telescope/telescope.nvim",
		},
		keys = {
			{
				"<leader>cs",
				"<cmd>AerialToggle!<CR>",
				desc = "Code: symbols (aerial)",
			},
			{
				"<leader>cS",
				"<cmd>Telescope aerial<CR>",
				desc = "Code: symbols (Telescope)",
			},
			{
				"{",
				"<cmd>AerialPrev<CR>",
				desc = "Aerial: prev symbol",
			},
			{
				"}",
				"<cmd>AerialNext<CR>",
				desc = "Aerial: next symbol",
			},
		},
		opts = {
			-- Use treesitter as primary backend, LSP as fallback
			backends = { "treesitter", "lsp", "markdown", "asciidoc", "man" },

			-- Filetypes to show aerial for
			filter_kind = {
				"Class",
				"Constructor",
				"Enum",
				"Function",
				"Interface",
				"Module",
				"Method",
				"Struct",
			},

			-- Layout
			layout = {
				max_width = { 40, 0.2 },
				width = nil,
				min_width = 20,
				win_opts = {},
				default_direction = "prefer_right",
				placement = "window",
				resize_to_content = true,
				preserve_equality = false,
			},

			-- Attach aerial to these filetypes
			attach_mode = "window",

			-- Show symbols in order of appearance
			post_jump_cmd = "normal! zz",

			-- Keymaps inside the aerial window
			keymaps = {
				["?"] = "actions.show_help",
				["g?"] = "actions.show_help",
				["<CR>"] = "actions.jump",
				["<2-LeftMouse>"] = "actions.jump",
				["<C-v>"] = "actions.jump_vsplit",
				["<C-s>"] = "actions.jump_split",
				["p"] = "actions.scroll",
				["<C-j>"] = "actions.down_and_scroll",
				["<C-k>"] = "actions.up_and_scroll",
				["{"] = "actions.prev",
				["}"] = "actions.next",
				["[["] = "actions.prev_up",
				["]]"] = "actions.next_up",
				["q"] = "actions.close",
				["o"] = "actions.tree_toggle",
				["za"] = "actions.tree_toggle",
				["O"] = "actions.tree_toggle_recursive",
				["zA"] = "actions.tree_toggle_recursive",
				["l"] = "actions.tree_open",
				["zo"] = "actions.tree_open",
				["L"] = "actions.tree_open_recursive",
				["zO"] = "actions.tree_open_recursive",
				["h"] = "actions.tree_close",
				["zc"] = "actions.tree_close",
				["H"] = "actions.tree_close_recursive",
				["zC"] = "actions.tree_close_recursive",
				["zr"] = "actions.tree_increase_fold_level",
				["zR"] = "actions.tree_open_all",
				["zm"] = "actions.tree_decrease_fold_level",
				["zM"] = "actions.tree_close_all",
				["zx"] = "actions.tree_sync_folds",
				["zX"] = "actions.tree_sync_folds",
			},

			-- Highlights
			highlight_mode = "split_width",
			highlight_closest = true,
			highlight_on_hover = true,
			highlight_on_jump = 300,

			-- Show in statusline (mini.statusline compatible)
			show_guides = true,
			guides = {
				mid_item = "├─",
				last_item = "└─",
				nested_top = "│ ",
				whitespace = "  ",
			},
		},
		config = function(_, opts)
			require("aerial").setup(opts)
			-- Register telescope extension
			require("telescope").load_extension("aerial")
		end,
	},
}
