-- ==============================
-- lua/plugins/which-key.lua
-- ==============================
-- which-key: displays available keybindings in a popup
-- Press <leader> and wait ~500ms to see all your mappings
-- organized by namespace exactly like LazyVim

return {
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		version = "*",
		opts = {
			-- Appearance
			preset = "modern", -- clean modern look (LazyVim default)
			delay = 500, -- ms before popup appears

			win = {
				border = "rounded",
				padding = { 1, 2 },
				wo = { winblend = 0 }, -- respects your transparency setup
			},

			-- Icons matching your Nerd Font setup
			icons = {
				mappings = true,
				keys = {
					Up = " ",
					Down = " ",
					Left = " ",
					Right = " ",
					C = "󰘴 ",
					M = "󰘵 ",
					S = "󰘶 ",
					CR = "󰌑 ",
					Esc = "󱊷 ",
					Tab = "󰌒 ",
					BS = "󰁮 ",
				},
			},

			-- Namespace descriptions shown in the popup
			spec = {
				-- Files / Telescope
				{ "<leader>f", group = "Find" },

				-- files / Harpoon
				{ "<leader>h", group = "Harpoon" },

				-- LSP
				{ "<leader>l", group = "LSP" },
				{ "<leader>lw", group = "Workspace" },

				-- Git
				{ "<leader>g", group = "Git" },

				-- Diagnostics / Trouble
				{ "<leader>x", group = "Diagnostics" },

				-- DAP
				{ "<leader>d", group = "Debug" },

				-- Run / Terminal
				{ "<leader>r", group = "Run" },

				-- Open / Launch
				{ "<leader>o", group = "Open" },

				-- Window / Splits
				{ "<leader>s", group = "Splits" },

				-- Buffer
				{ "<leader>b", group = "Buffer" },

				-- Single mappings
				{ "<leader>w", desc = "Save file" },
				{ "<leader>e", desc = "Explorer (CWD)" },
				{ "<leader>E", desc = "Explorer (file)" },
				{ "<leader>ih", desc = "Toggle inlay hints" },
				{ "<leader>nh", desc = "Clear highlights" },
				{ "<leader>qq", desc = "Quit all" },
				{ "<leader>ca", desc = "Code action" },
				-- Git-suite keybindings
				{ "<leader>gC", desc = "Git: commit" },
				{ "<leader>gP", desc = "Git: push" },
				{ "<leader>gL", desc = "Git: log" },
				{ "<leader>gD", desc = "Git: diffview" },
				{ "<leader>gh", desc = "Git: file history" },
				{ "<leader>gH", desc = "Git: repo history" },
				{ "<leader>gx", desc = "Git: close diffview" },
				{ "<leader>gg", desc = "Git: Neogit" },
				-- TODO - Liniting - Aerial
				{ "<leader>c", group = "Code" },
				{ "<leader>xt", desc = "Todo: Trouble list" },
				{ "<leader>ft", desc = "Find: todos" },
				{ "<leader>q", group = "Session/Quit" },
				-- Persistence Save for session
				{ "<leader>qs", desc = "Session: restore" },
				{ "<leader>ql", desc = "Session: restore last" },
				{ "<leader>qd", desc = "Session: stop" },
				{ "<leader>qq", desc = "Quit all" },
				-- Leader Key Updates
				-- add these to the spec table in which-key.lua
				{ "<leader>D", desc = "Delete without yanking" },
				{ "<leader>n", group = "Noice" },
				{ "<leader>y", group = "Yank path" },
				{ "<leader>q", group = "Quit/Session/Quickfix" },
				{ "<leader>ba", desc = "Buffer: delete all" },
				-- Operators / goto
				{ "g", group = "Goto / Operators" },
			},
		},
	},
}
