-- ==============================
-- lua/plugins/harpoon.lua
-- ==============================
-- harpoon2: pin up to 5 files and jump instantly
-- Think of it as bookmarks for your current work session
--
-- Usage:
--   <leader>ha        → add current file to harpoon
--   <leader>hh        → open harpoon menu
--   <C-1> to <C-5>    → jump directly to pinned file

return {
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		version = false, -- harpoon2 has no stable tags yet
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = {
			{
				"<leader>ha",
				function()
					require("harpoon"):list():add()
				end,
				desc = "Harpoon: add file",
			},
			{
				"<leader>hh",
				function()
					local harpoon = require("harpoon")
					harpoon.ui:toggle_quick_menu(harpoon:list())
				end,
				desc = "Harpoon: menu",
			},
			-- Jump to pinned files 1-5
			{
				"<C-1>",
				function()
					require("harpoon"):list():select(1)
				end,
				desc = "Harpoon: file 1",
			},
			{
				"<C-2>",
				function()
					require("harpoon"):list():select(2)
				end,
				desc = "Harpoon: file 2",
			},
			{
				"<C-3>",
				function()
					require("harpoon"):list():select(3)
				end,
				desc = "Harpoon: file 3",
			},
			{
				"<C-4>",
				function()
					require("harpoon"):list():select(4)
				end,
				desc = "Harpoon: file 4",
			},
			{
				"<C-5>",
				function()
					require("harpoon"):list():select(5)
				end,
				desc = "Harpoon: file 5",
			},
			-- Cycle through pinned files
			{
				"<leader>hn",
				function()
					require("harpoon"):list():next()
				end,
				desc = "Harpoon: next",
			},
			{
				"<leader>hp",
				function()
					require("harpoon"):list():prev()
				end,
				desc = "Harpoon: prev",
			},
		},
		opts = {},
	},
}
