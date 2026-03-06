-- ==============================
-- lua/plugins/git-suite.lua
-- ==============================
-- Full git suite to complement gitsigns:
--   neogit   → Magit-style git dashboard (stage, commit, push, branch)
--   diffview → Side-by-side diff viewer + file history
--
-- Workflow:
--   <leader>gg  → open neogit (full git dashboard)
--   <leader>gD  → open diffview (review all changes)
--   <leader>gh  → file history (every commit for current file)
--   <leader>gx  → close diffview

return {
	-- ── Neogit ────────────────────────────────────────────────────────────
	{
		"NeogitOrg/neogit",
		version = false,
		dependencies = {
			"nvim-lua/plenary.nvim",
			"sindrets/diffview.nvim", -- neogit uses diffview for its diff views
			"nvim-telescope/telescope.nvim",
		},
		keys = {
			{
				"<leader>gg",
				function()
					require("neogit").open()
				end,
				desc = "Git: Neogit",
			},
			{
				"<leader>gC",
				function()
					require("neogit").open({ "commit" })
				end,
				desc = "Git: commit",
			},
			{
				"<leader>gP",
				function()
					require("neogit").open({ "push" })
				end,
				desc = "Git: push",
			},
			{
				"<leader>gL",
				function()
					require("neogit").open({ "log" })
				end,
				desc = "Git: log",
			},
		},
		opts = {
			-- Use diffview for neogit's diff panels
			integrations = {
				diffview = true,
				telescope = true,
			},

			-- Graph style — unicode looks great with Nerd Fonts
			graph_style = "unicode",

			-- Signs in the neogit buffer
			signs = {
				hunk = { "", "" },
				item = { "", "" },
				section = { "", "" },
			},

			-- Open neogit in a floating window (consistent with your UI)
			kind = "floating",

			-- Floating window settings
			floating_window_use_plenary = false,

			commit_editor = {
				kind = "floating",
			},

			commit_select_view = {
				kind = "tab",
			},

			log_view = {
				kind = "floating",
			},

			rebase_editor = {
				kind = "floating",
			},

			reflog_view = {
				kind = "floating",
			},

			merge_editor = {
				kind = "floating",
			},

			-- Remember window positions
			remember_settings = true,
			traverse_parents = false,

			-- Sections shown in the neogit dashboard
			sections = {
				sequencer = { folded = false, hidden = false },
				untracked = { folded = false, hidden = false },
				unstaged = { folded = false, hidden = false },
				staged = { folded = false, hidden = false },
				stashes = { folded = true, hidden = false },
				unpulled_upstream = { folded = true, hidden = false },
				unmerged_upstream = { folded = false, hidden = false },
				unpulled_pushRemote = { folded = true, hidden = true },
				unmerged_pushRemote = { folded = false, hidden = true },
				recent = { folded = true, hidden = false },
				rebase = { folded = true, hidden = false },
			},
		},
	},

	-- ── Diffview ──────────────────────────────────────────────────────────
	{
		"sindrets/diffview.nvim",
		version = false,
		dependencies = { "nvim-lua/plenary.nvim" },
		cmd = {
			"DiffviewOpen",
			"DiffviewClose",
			"DiffviewToggleFiles",
			"DiffviewFocusFiles",
			"DiffviewFileHistory",
		},
		keys = {
			-- Review all current changes vs HEAD
			{
				"<leader>gD",
				"<cmd>DiffviewOpen<CR>",
				desc = "Git: diffview open",
			},
			-- File history — every commit that touched this file
			{
				"<leader>gh",
				"<cmd>DiffviewFileHistory %<CR>",
				desc = "Git: file history",
			},
			-- Full repo history
			{
				"<leader>gH",
				"<cmd>DiffviewFileHistory<CR>",
				desc = "Git: repo history",
			},
			-- Close diffview
			{
				"<leader>gx",
				"<cmd>DiffviewClose<CR>",
				desc = "Git: diffview close",
			},
		},
		opts = {
			diff_binaries = false,
			enhanced_diff_hl = true, -- better highlights for changed words
			use_icons = true,

			icons = {
				folder_closed = "",
				folder_open = "",
			},

			signs = {
				fold_closed = "",
				fold_open = "",
				done = "✓",
			},

			view = {
				-- Side-by-side diff (like VSCode)
				default = {
					layout = "diff2_horizontal",
					disable_diagnostics = true,
					winbar_info = false,
				},
				merge_tool = {
					layout = "diff3_horizontal",
					disable_diagnostics = true,
					winbar_info = true,
				},
				file_history = {
					layout = "diff2_horizontal",
					disable_diagnostics = true,
					winbar_info = false,
				},
			},

			file_panel = {
				listing_style = "tree",
				tree_options = {
					flatten_dirs = true,
					folder_statuses = "only_folded",
				},
				win_config = {
					position = "left",
					width = 35,
					win_opts = {},
				},
			},

			hooks = {},
			keymaps = {
				disable_defaults = false, -- keep diffview's default keymaps
			},
		},
	},
}
