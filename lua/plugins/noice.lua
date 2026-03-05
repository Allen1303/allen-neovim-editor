-- ==============================
-- lua/plugins/noice.lua
-- ==============================

return {
	-- ── nvim-notify: notification backend ──────────────────────────────────
	-- ADD: was a dependency but never configured — needs background_colour
	-- when Normal has no bg (transparent themes) or nvim-notify warns on startup
	{
		"rcarriga/nvim-notify",
		opts = {
			background_colour = "#000000", -- required when Normal bg = NONE
			render = "wrapped-compact",
			stages = "fade",
			timeout = 3000,
			max_width = 60,
		},
	},

	-- ── Noice: cmdline, messages, notifications UI ──────────────────────────
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
		},
		opts = {
			lsp = {
				-- Override markdown rendering so cmp and other plugins use Treesitter
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true,
				},
			},

			-- ADD: route noisy LSP/editor messages to /dev/null
			-- prevents "written N lines", undo/redo counts etc. cluttering the UI
			routes = {
				{
					filter = {
						event = "msg_show",
						any = {
							{ find = "%d+L, %d+B" }, -- written lines/bytes
							{ find = "; after #%d+" }, -- undo messages
							{ find = "; before #%d+" }, -- redo messages
							{ find = "%d fewer lines" },
							{ find = "%d more lines" },
						},
					},
					opts = { skip = true },
				},
			},

			-- ADD: explicit notify view routing with mini fallback
			views = {
				notify = {
					backend = "notify",
					fallback = "mini",
				},
			},

			presets = {
				bottom_search = true, -- classic bottom cmdline for search
				command_palette = true, -- cmdline + popupmenu together
				long_message_to_split = true, -- long messages go to a split
				inc_rename = false, -- no inc-rename.nvim
				-- FIX: was false — changed to true for consistency with rounded
				-- borders used everywhere else (cmp, mason, floating terminal)
				lsp_doc_border = true,
			},
		},

		config = function(_, opts)
			require("noice").setup(opts)

			-- Transparency for all Noice UI components
			-- FIX: added augroup to prevent duplicate autocmds on config reload
			local function apply_noice_transparent()
				local set = vim.api.nvim_set_hl
				set(0, "NoiceCmdlinePopup", { bg = "NONE" })
				set(0, "NoiceCmdlinePopupBorder", { bg = "NONE" })
				set(0, "NoiceCmdlinePopupTitle", { bg = "NONE" })
				set(0, "NoiceCmdlineIcon", { bg = "NONE" })
				set(0, "NoiceConfirm", { bg = "NONE" })
				set(0, "NoiceConfirmBorder", { bg = "NONE" })
				set(0, "NoiceCmdlinePopupBorderSearch", { bg = "NONE" })
				-- FIX: was bg = "NONE" — causes nvim-notify background warning
				-- Use opaque fallback color instead
				set(0, "NotifyBackground", { bg = "#000000" })
			end

			vim.api.nvim_create_autocmd("ColorScheme", {
				group = vim.api.nvim_create_augroup("Allen_Noice_Transparent", { clear = true }),
				pattern = "*",
				callback = apply_noice_transparent,
			})

			-- Apply immediately on first load
			apply_noice_transparent()
		end,
	},
}
