-- ==============================
-- lua/plugins/flash.lua
-- ==============================
-- flash.nvim: jump anywhere on screen in 2-3 keystrokes
-- LazyVim standard navigation plugin
--
-- Usage:
--   s        → flash jump (type 2 chars, pick label)
--   S        → flash treesitter (jump to any AST node)
--   r        → remote flash (in operator-pending mode)
--   R        → treesitter search
--   <C-s>    → toggle flash in telescope search results

return {
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		version = "*",
		opts = {
			-- Appearance
			labels = "asdfghjklqwertyuiopzxcvbnm",
			search = {
				multi_window = true, -- search across all visible windows
				forward = true,
				wrap = true,
			},
			jump = {
				jumplist = true, -- add jumps to jumplist (C-o to go back)
				pos = "start",
				autojump = false, -- don't auto-jump when only one match
			},
			label = {
				uppercase = false,
				rainbow = { enabled = true, shade = 5 }, -- colored labels
				style = "overlay", -- label overlays the match
			},
			highlight = {
				backdrop = true, -- dim everything except matches
				matches = true,
				priority = 5000,
				groups = {
					match = "FlashMatch",
					current = "FlashCurrent",
					backdrop = "FlashBackdrop",
					label = "FlashLabel",
				},
			},
			modes = {
				-- s keymap — standard flash jump
				search = {
					enabled = false, -- don't hijack / search
				},
				char = {
					enabled = true, -- enhance f/t/F/T with flash labels
					jump_labels = true, -- show labels on f/t targets
					multi_line = true,
					keys = { "f", "F", "t", "T", ";", "," },
				},
				treesitter = {
					labels = "asdfghjklqwertyuiopzxcvbnm",
					jump = { pos = "range" },
					search = { incremental = false },
					label = { before = true, after = true, style = "inline" },
					highlight = { backdrop = false, matches = false },
				},
			},
		},
		keys = {
			-- Normal + visual: s to flash jump
			{
				"s",
				mode = { "n", "x", "o" },
				function()
					require("flash").jump()
				end,
				desc = "Flash jump",
			},
			-- Treesitter jump — select any syntax node
			{
				"S",
				mode = { "n", "x", "o" },
				function()
					require("flash").treesitter()
				end,
				desc = "Flash treesitter",
			},
			-- Operator-pending: r for remote flash
			-- e.g. yr<flash> yanks to a remote location
			{
				"r",
				mode = "o",
				function()
					require("flash").remote()
				end,
				desc = "Flash remote",
			},
			-- Treesitter search in operator-pending + visual
			{
				"R",
				mode = { "o", "x" },
				function()
					require("flash").treesitter_search()
				end,
				desc = "Flash treesitter search",
			},
			-- Toggle flash search in Telescope
			{
				"<C-s>",
				mode = "c",
				function()
					require("flash").toggle()
				end,
				desc = "Flash toggle (Telescope)",
			},
		},
	},
}
