-- ==============================
-- lua/plugins/persistence.lua
-- ==============================
-- persistence.nvim: automatic session save and restore
-- Saves your session (buffers, splits, layout, cursor) on exit
-- and restores it when you reopen Neovim in the same directory
--
-- Usage:
--   <leader>qs  → restore session for current directory
--   <leader>qS  → select a session to restore (Telescope)
--   <leader>ql  → restore last session
--   <leader>qd  → stop persistence (don't save this session)

return {
	{
		"folke/persistence.nvim",
		version = "*",
		event = "BufReadPre", -- restore session before first buffer loads
		keys = {
			{
				"<leader>qs",
				function()
					require("persistence").load()
				end,
				desc = "Session: restore (cwd)",
			},
			{
				"<leader>ql",
				function()
					require("persistence").load({ last = true })
				end,
				desc = "Session: restore last",
			},
			{
				"<leader>qd",
				function()
					require("persistence").stop()
				end,
				desc = "Session: stop (don't save)",
			},
		},
		opts = {
			-- Where sessions are saved
			dir = vim.fn.stdpath("state") .. "/sessions/",

			-- What to save in the session
			options = {
				"buffers", -- open buffers
				"curdir", -- current directory
				"tabpages", -- tab pages
				"winsize", -- window sizes
				"folds", -- fold state
				"globals", -- global variables
			},

			-- Save session when Neovim exits
			need = 1, -- minimum number of buffers to save session (avoid saving empty sessions)
		},
	},
}
