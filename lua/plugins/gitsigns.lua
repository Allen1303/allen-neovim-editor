-- ==============================
-- lua/plugins/gitsigns.lua
-- ==============================
-- - Show inline git changes (signs) with handy hunk actions
-- - Keep visuals subtle & transparent-friendly
-- - Lazy-load on file open and attach buffer-local keymaps

return {
	{
		"lewis6991/gitsigns.nvim", -- this plugin draws git change signs and provides hunk actions
		event = { "BufReadPre", "BufNewFile" }, -- this option loads when you open/edit files
		opts = {
			-- Signs: thin bars for add/change; light underline for deletions (easy on the eyes)
			signs = {
				add = { text = "▎" }, -- this mark shows added lines
				change = { text = "▎" }, -- this mark shows modified lines
				delete = { text = "▁" }, -- this mark shows deleted lines (baseline)
				topdelete = { text = "▔" }, -- this mark shows top-line deletions
				changedelete = { text = "▎" }, -- this mark shows modified+deleted lines
				untracked = { text = "▎" }, -- this mark shows untracked lines
			},
			signcolumn = true, -- this option shows signs in the sign column
			numhl = false,
			linehl = false,
			word_diff = false, -- these options keep visuals minimal & fast
			attach_to_untracked = true, -- this option still shows signs for new files
			preview_config = { border = "rounded" }, -- this option makes hunk preview window tidy

			-- Inline blame: helpful but not too noisy
			current_line_blame = true, -- this option shows blame text for the current line
			current_line_blame_opts = {
				virt_text = true,
				virt_text_pos = "eol",
				delay = 700,
				ignore_whitespace = false,
			},
			current_line_blame_formatter = "<author>, <author_time:%R> • <summary>", -- this format shows who/when/what

			-- Buffer-local keymaps when gitsigns attaches
			on_attach = function(bufnr)
				local gs = package.loaded.gitsigns
				local function bmap(mode, lhs, rhs, desc)
					vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
				end

				-- Navigation
				bmap("n", "]h", function()
					gs.nav_hunk("next")
				end, "Git: next hunk")
				bmap("n", "[h", function()
					gs.nav_hunk("prev")
				end, "Git: previous hunk")

				-- Stage / reset selected hunk (works in normal & visual)
				bmap({ "n", "v" }, "<leader>hs", ":Gitsigns stage_hunk<CR>", "Git: stage hunk")
				bmap({ "n", "v" }, "<leader>hr", ":Gitsigns reset_hunk<CR>", "Git: reset hunk")

				-- Buffer-level actions
				bmap("n", "<leader>hS", gs.stage_buffer, "Git: stage buffer")
				bmap("n", "<leader>hR", gs.reset_buffer, "Git: reset buffer")
				bmap("n", "<leader>hu", gs.undo_stage_hunk, "Git: undo stage hunk")

				-- Peek & blame
				bmap("n", "<leader>hp", gs.preview_hunk_inline, "Git: preview hunk inline")
				bmap("n", "<leader>hb", function()
					gs.blame_line({ full = true })
				end, "Git: blame line (full)")
				bmap("n", "<leader>tb", gs.toggle_current_line_blame, "Git: toggle line blame")

				-- Diff against index / last commit
				bmap("n", "<leader>hd", gs.diffthis, "Git: diff against index")
				bmap("n", "<leader>hD", function()
					gs.diffthis("~")
				end, "Git: diff against last commit")
			end,
		},

		config = function(_, opts)
			require("gitsigns").setup(opts)

			-- Transparency hardening: clear bg on GitSigns groups so themes don’t add blocks
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
			vim.api.nvim_exec_autocmds("ColorScheme", {})
		end,
	},
}
