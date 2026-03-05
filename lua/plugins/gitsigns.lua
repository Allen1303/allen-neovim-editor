-- ==============================
-- lua/plugins/gitsigns.lua
-- ==============================
-- - Show inline git changes (signs) with handy hunk actions
-- - Keep visuals subtle & transparent-friendly
-- - Lazy-load on file open and attach buffer-local keymaps

return {
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			-- Signs: thin bars for add/change; light underline for deletions
			signs = {
				add = { text = "▎" },
				change = { text = "▎" },
				delete = { text = "▁" },
				topdelete = { text = "▔" },
				changedelete = { text = "▎" },
				untracked = { text = "▎" },
			},

			signcolumn = true,
			numhl = false,
			linehl = false,
			word_diff = false, -- keep visuals minimal & fast
			attach_to_untracked = true, -- show signs on new files before first commit
			preview_config = { border = "rounded" },

			-- Inline blame: helpful but not too noisy
			current_line_blame = true,
			current_line_blame_opts = {
				virt_text = true,
				virt_text_pos = "eol",
				delay = 700,
				ignore_whitespace = false,
			},
			current_line_blame_formatter = "<author>, <author_time:%R> • <summary>",

			-- Buffer-local keymaps when gitsigns attaches
			on_attach = function(bufnr)
				-- FIX: was package.loaded.gitsigns — fragile if not yet fully loaded
				local gs = require("gitsigns")

				local function bmap(mode, lhs, rhs, desc)
					vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
				end

				-- ── Hunk navigation ───────────────────────────────────────
				-- Kept as ]h / [h — standard convention, no conflicts
				bmap("n", "]h", function()
					gs.nav_hunk("next")
				end, "Git: next hunk")
				bmap("n", "[h", function()
					gs.nav_hunk("prev")
				end, "Git: previous hunk")

				-- ── Stage / reset ─────────────────────────────────────────
				-- FIX: moved from <leader>h* to <leader>g* namespace
				-- <leader>g = git, semantic and conflict-free
				bmap({ "n", "v" }, "<leader>gs", ":Gitsigns stage_hunk<CR>", "Git: stage hunk")
				bmap({ "n", "v" }, "<leader>gr", ":Gitsigns reset_hunk<CR>", "Git: reset hunk")
				bmap("n", "<leader>gS", gs.stage_buffer, "Git: stage buffer")
				bmap("n", "<leader>gR", gs.reset_buffer, "Git: reset buffer")
				bmap("n", "<leader>gu", gs.undo_stage_hunk, "Git: undo stage hunk")

				-- ── Preview & blame ───────────────────────────────────────
				bmap("n", "<leader>gp", gs.preview_hunk_inline, "Git: preview hunk inline")

				-- FIX: was <leader>hb — moved to <leader>gb (git blame, semantic)
				bmap("n", "<leader>gb", function()
					gs.blame_line({ full = true })
				end, "Git: blame line (full)")

				-- FIX: was <leader>tb — conflicted with <leader>t terminal namespace
				-- Renamed to <leader>gt (git toggle blame)
				bmap("n", "<leader>gt", gs.toggle_current_line_blame, "Git: toggle line blame")

				-- ── Diff ──────────────────────────────────────────────────
				bmap("n", "<leader>gd", gs.diffthis, "Git: diff against index")
				bmap("n", "<leader>gD", function()
					gs.diffthis("~")
				end, "Git: diff against last commit")

				-- ── Hunk text object ──────────────────────────────────────
				-- ADD: ih = "inner hunk" — use with vih, dih, cih etc.
				bmap({ "o", "x" }, "ih", ":<C-u>Gitsigns select_hunk<CR>", "Git: select hunk (text object)")
			end,
		},

		config = function(_, opts)
			require("gitsigns").setup(opts)

			-- Transparency hardening: clear bg on GitSigns groups
			-- FIX: was vim.api.nvim_exec_autocmds("ColorScheme", {}) which fires
			--      ALL ColorScheme listeners — replaced with direct hl calls
			local grp = vim.api.nvim_create_augroup("Allen_Gitsigns_Transparent", { clear = true })
			vim.api.nvim_create_autocmd("ColorScheme", {
				group = grp,
				callback = function()
					local set = vim.api.nvim_set_hl
					pcall(set, 0, "GitSignsAdd", { bg = "NONE" })
					pcall(set, 0, "GitSignsChange", { bg = "NONE" })
					pcall(set, 0, "GitSignsDelete", { bg = "NONE" })
				end,
			})

			-- Apply immediately on first load without firing other listeners
			local set = vim.api.nvim_set_hl
			pcall(set, 0, "GitSignsAdd", { bg = "NONE" })
			pcall(set, 0, "GitSignsChange", { bg = "NONE" })
			pcall(set, 0, "GitSignsDelete", { bg = "NONE" })
		end,
	},
}
