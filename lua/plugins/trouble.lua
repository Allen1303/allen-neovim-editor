-- ==============================
-- lua/plugins/trouble.lua
-- ==============================
-- - One-key diagnostics panel (workspace / buffer), plus symbols, qflist, LSP refs
-- -  Panel is transparent across themes

return {
	{
		"folke/trouble.nvim", -- this plugin shows a diagnostics/location panel
		version = "*", -- this variable tracks latest stable
		keys = {
			{
				"<leader>xx",
				function()
					require("trouble").toggle("diagnostics")
				end,
				desc = "Trouble: workspace diagnostics",
			},
			{
				"<leader>xb",
				function()
					require("trouble").toggle("diagnostics", { filter = { buf = 0 } })
				end,
				desc = "Trouble: buffer diagnostics",
			},
			{
				"<leader>xq",
				function()
					require("trouble").toggle("qflist")
				end,
				desc = "Trouble: quickfix list",
			},
			{
				"<leader>xl",
				function()
					require("trouble").toggle("loclist")
				end,
				desc = "Trouble: location list",
			},
			{
				"<leader>xs",
				function()
					require("trouble").toggle("symbols")
				end,
				desc = "Trouble: document symbols",
			},
			{
				"gr",
				function()
					require("trouble").toggle("lsp_references")
				end,
				desc = "Trouble: LSP references",
			},
		},
		opts = {}, -- this table uses defaults (good out of the box)
		config = function(_, opts)
			require("trouble").setup(opts) -- this call applies defaults

			-- Transparency hardening (theme-agnostic)
			local grp = vim.api.nvim_create_augroup("Allen_Trouble_Transparent", { clear = true })
			vim.api.nvim_create_autocmd("ColorScheme", {
				group = grp,
				callback = function()
					local set = vim.api.nvim_set_hl
					pcall(set, 0, "TroubleNormal", { bg = "NONE" }) -- main window bg
					pcall(set, 0, "TroubleNormalNC", { bg = "NONE" }) -- inactive bg (if split)
					pcall(set, 0, "TroubleWinSeparator", { bg = "NONE" }) -- splitter bg
					pcall(set, 0, "TroubleBorder", { bg = "NONE" }) -- border bg (if theme defines it)
				end,
			})
			vim.api.nvim_exec_autocmds("ColorScheme", {})

			-- Ensure each Trouble window uses the cleared groups
			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("Allen_Trouble_WinHL", { clear = true }),
				pattern = "trouble",
				callback = function()
					vim.wo.winhl = table.concat({
						"Normal:TroubleNormal",
						"NormalNC:TroubleNormalNC",
						"WinSeparator:TroubleWinSeparator",
					}, ",")
				end,
			})
		end,
	},
}
