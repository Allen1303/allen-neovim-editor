return {
	"folke/noice.nvim",
	event = "VeryLazy",
	dependencies = {
		"MunifTanjim/nui.nvim",
		"rcarriga/nvim-notify", -- Optional: for better notifications
	},
	opts = {
		lsp = {
			-- Override markdown rendering so that **cmp** and other plugins use **Treesitter**
			override = {
				["vim.lsp.util.convert_input_to_markdown_lines"] = true,
				["vim.lsp.util.stylize_markdown"] = true,
				["cmp.entry.get_documentation"] = true,
			},
		},
		-- Presets for easier configuration
		presets = {
			bottom_search = true, -- Use a classic bottom cmdline for search
			command_palette = true, -- Position the cmdline and popupmenu together
			long_message_to_split = true, -- Long messages will be sent to a split
			inc_rename = false, -- Enables an input dialog for inc-rename.nvim
			lsp_doc_border = false, -- Add a border to hover docs and signature help
		},
	},
	config = function(_, opts)
		require("noice").setup(opts)

		-- Honor transparency for Noice components
		vim.api.nvim_create_autocmd("ColorScheme", {
			pattern = "*",
			callback = function()
				-- Make Noice backgrounds transparent
				vim.api.nvim_set_hl(0, "NoiceCmdlinePopup", { bg = "NONE" })
				vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorder", { bg = "NONE" })
				vim.api.nvim_set_hl(0, "NoiceCmdlinePopupTitle", { bg = "NONE" })
				vim.api.nvim_set_hl(0, "NoiceCmdlineIcon", { bg = "NONE" })
				vim.api.nvim_set_hl(0, "NoiceConfirm", { bg = "NONE" })
				vim.api.nvim_set_hl(0, "NoiceConfirmBorder", { bg = "NONE" })
				vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorderSearch", { bg = "NONE" })

				-- Notify (notification popups)
				vim.api.nvim_set_hl(0, "NotifyBackground", { bg = "NONE" })
			end,
		})

		-- Apply immediately on load
		vim.api.nvim_set_hl(0, "NoiceCmdlinePopup", { bg = "NONE" })
		vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorder", { bg = "NONE" })
		vim.api.nvim_set_hl(0, "NoiceCmdlinePopupTitle", { bg = "NONE" })
		vim.api.nvim_set_hl(0, "NoiceConfirm", { bg = "NONE" })
		vim.api.nvim_set_hl(0, "NotifyBackground", { bg = "NONE" })
	end,
}
