-- ==============================
-- lua/plugins/bufferline.lua
-- ==============================
-- bufferline.nvim: VSCode-style buffer tabs at the top
-- Works with mini.icons for filetype icons
-- mini.statusline stays at the bottom — these don't conflict

return {
	{
		"akinsho/bufferline.nvim",
		version = "*",
		event = "VeryLazy",
		dependencies = {
			"nvim-tree/nvim-web-devicons", -- fallback icons if mini.icons unavailable
		},
		keys = {
			{ "<leader>bp", "<cmd>BufferLineTogglePin<CR>", desc = "Buffer: toggle pin" },
			{ "<leader>bP", "<cmd>BufferLineGroupClose ungrouped<CR>", desc = "Buffer: close unpinned" },
			{ "<leader>bo", "<cmd>BufferLineCloseOthers<CR>", desc = "Buffer: close others" },
			{ "<leader>br", "<cmd>BufferLineCloseRight<CR>", desc = "Buffer: close right" },
			{ "<leader>bl", "<cmd>BufferLineCloseLeft<CR>", desc = "Buffer: close left" },
			{ "<S-h>", "<cmd>BufferLineCyclePrev<CR>", desc = "Buffer: prev" },
			{ "<S-l>", "<cmd>BufferLineCycleNext<CR>", desc = "Buffer: next" },
			{ "[b", "<cmd>BufferLineCyclePrev<CR>", desc = "Buffer: prev" },
			{ "]b", "<cmd>BufferLineCycleNext<CR>", desc = "Buffer: next" },
			{ "[B", "<cmd>BufferLineMovePrev<CR>", desc = "Buffer: move left" },
			{ "]B", "<cmd>BufferLineMoveNext<CR>", desc = "Buffer: move right" },
		},
		opts = {
			options = {
				-- Use mini.icons if available, fallback to nvim-web-devicons
				get_element_icon = function(element)
					local ok, mini_icons = pcall(require, "mini.icons")
					if ok then
						local icon, hl = mini_icons.get("file", element.filename)
						return icon, hl
					end
				end,

				mode = "buffers", -- show buffers (not tabs)
				themable = true,
				numbers = "none", -- no numbers on tabs
				close_command = "bdelete! %d",
				right_mouse_command = "bdelete! %d",
				left_mouse_command = "buffer %d",

				indicator = {
					icon = "▎",
					style = "icon",
				},

				buffer_close_icon = "󰅖",
				modified_icon = "●",
				close_icon = "",
				left_trunc_marker = "",
				right_trunc_marker = "",

				diagnostics = "nvim_lsp", -- show LSP diagnostics on tabs
				diagnostics_update_in_insert = false,
				diagnostics_indicator = function(count, level)
					local icon = level:match("error") and " " or " "
					return " " .. icon .. count
				end,

				-- Don't show these in the bufferline
				offsets = {
					{
						filetype = "neo-tree",
						text = "File Explorer",
						highlight = "Directory",
						text_align = "left",
					},
				},

				color_icons = true,
				show_buffer_icons = true,
				show_buffer_close_icons = true,
				show_close_icon = true,
				show_tab_indicators = true,
				show_duplicate_prefix = true,
				persist_buffer_sort = true,
				separator_style = "slant", -- slant looks great with most themes
				enforce_regular_tabs = false,
				always_show_bufferline = false, -- hide when only 1 buffer open
				hover = {
					enabled = true,
					delay = 200,
					reveal = { "close" },
				},
			},
		},
	},
}
