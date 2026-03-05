-- ==============================
-- lua/plugins/trouble.lua
-- ==============================
-- - One-key diagnostics panel (workspace / buffer), plus symbols, qflist, LSP refs
-- - Panel is transparent across themes

return {
	{
		"folke/trouble.nvim",
		version = "*",
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
			-- NOTE: <leader>xq kept here — trouble's qflist view is richer than
			-- vim.diagnostic.setqflist. lsp-config.lua uses <leader>dq instead.
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
			-- ADD: <leader>xR for LSP refs in panel (complement to gr below)
			{
				"<leader>xR",
				function()
					require("trouble").toggle("lsp_references")
				end,
				desc = "Trouble: LSP references (panel)",
			},
			{
				-- NOTE: intentionally overrides lsp-config.lua gr (vim.lsp.buf.references)
				-- Trouble's lsp_references view is richer than the quickfix list
				"gr",
				function()
					require("trouble").toggle("lsp_references")
				end,
				desc = "Trouble: LSP references",
			},
		},

		-- ADD: focus = true so trouble auto-focuses the panel when opened
		opts = {
			focus = true,
		},

		config = function(_, opts)
			require("trouble").setup(opts)

			-- Transparency hardening (theme-agnostic)
			-- FIX: was nvim_exec_autocmds("ColorScheme") — fired all listeners
			-- Extracted to function and called directly on load instead
			local function apply_trouble_transparent()
				local set = vim.api.nvim_set_hl
				pcall(set, 0, "TroubleNormal", { bg = "NONE" }) -- main window bg
				pcall(set, 0, "TroubleNormalNC", { bg = "NONE" }) -- inactive window bg
				pcall(set, 0, "TroubleWinSeparator", { bg = "NONE" }) -- splitter bg
				pcall(set, 0, "TroubleBorder", { bg = "NONE" }) -- border bg
			end

			vim.api.nvim_create_autocmd("ColorScheme", {
				group = vim.api.nvim_create_augroup("Allen_Trouble_Transparent", { clear = true }),
				callback = apply_trouble_transparent,
			})

			-- Apply immediately on first load
			apply_trouble_transparent()

			-- Ensure each Trouble window uses the cleared highlight groups
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
