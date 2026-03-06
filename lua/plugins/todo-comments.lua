-- ==============================
-- lua/plugins/todo-comments.lua
-- ==============================
-- todo-comments: highlights TODO/FIXME/HACK/NOTE/PERF/WARN in code
-- Also integrates with Telescope and Trouble for searching all todos

-- Usage:
--   ]t / [t          → jump to next/prev todo
--   <leader>xt       → show all todos in Trouble
--   <leader>ft       → search todos with Telescope

return {
	{
		"folke/todo-comments.nvim",
		version = "*",
		event = "VeryLazy",
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = {
			{
				"]t",
				function()
					require("todo-comments").jump_next()
				end,
				desc = "Todo: next",
			},
			{
				"[t",
				function()
					require("todo-comments").jump_prev()
				end,
				desc = "Todo: prev",
			},
			{
				"<leader>xt",
				"<cmd>Trouble todo toggle<CR>",
				desc = "Todo: Trouble list",
			},
			{
				"<leader>xT",
				"<cmd>Trouble todo toggle filter = {tag = {TODO,FIX,FIXME}}<CR>",
				desc = "Todo: Trouble (TODO/FIX only)",
			},
			{
				"<leader>ft",
				"<cmd>TodoTelescope<CR>",
				desc = "Find: todos",
			},
		},
		opts = {
			signs = true, -- show icons in sign column
			sign_priority = 8,

			keywords = {
				FIX = { icon = " ", color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
				TODO = { icon = " ", color = "info" },
				HACK = { icon = " ", color = "warning" },
				WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
				PERF = { icon = " ", color = "default", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
				NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
				TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
			},

			gui_style = {
				fg = "NONE",
				bg = "BOLD",
			},

			merge_keywords = true,

			highlight = {
				multiline = true,
				multiline_pattern = "^.",
				multiline_context = 10,
				before = "",
				keyword = "wide",
				after = "fg",
				pattern = [[.*<(KEYWORDS)\s*:]],
				comments_only = true,
				max_line_len = 400,
				exclude = {},
			},

			colors = {
				error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
				warning = { "DiagnosticWarn", "WarningMsg", "#FBBF24" },
				info = { "DiagnosticInfo", "#2563EB" },
				hint = { "DiagnosticHint", "#10B981" },
				default = { "Identifier", "#7C3AED" },
				test = { "Identifier", "#FF006E" },
			},

			search = {
				command = "rg",
				args = {
					"--color=never",
					"--no-heading",
					"--with-filename",
					"--line-number",
					"--column",
				},
				pattern = [[\b(KEYWORDS):]],
			},
		},
	},
}
