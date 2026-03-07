-- ==============================
-- lua/plugins/emmet.lua
-- ==============================
-- Emmet: expand abbreviations like VSCode
-- FIX: no custom trigger key needed — Tab expansion is handled in cmp.lua
-- cmp.lua uses emmet#expandAbbr(3, "") in the Tab mapping which handles
-- all complex abbreviations: p{text}+button*3, div.container>ul>li*3, etc.
--
-- This file only needs to:
--   1. Install emmet per filetype (EmmetInstall)
--   2. Configure JSX settings (className, self-closing tags)

return {
	{
		"mattn/emmet-vim",
		ft = {
			"html",
			"css",
			"scss",
			"less",
			"javascript",
			"javascriptreact",
			"typescript",
			"typescriptreact",
			"svelte",
			"vue",
		},
		init = function()
			-- Disable global install — enable per filetype only
			vim.g.user_emmet_install_global = 0

			-- Keep default leader (not used directly — cmp.lua handles expansion)
			vim.g.user_emmet_leader_key = "<C-y>"

			-- JSX: use className, self-closing tags, fragment support
			vim.g.user_emmet_settings = {
				javascript = { extends = "jsx" },
				typescript = { extends = "jsx" },
				javascriptreact = { extends = "jsx" },
				typescriptreact = { extends = "jsx" },
			}
		end,
		config = function()
			-- Enable Emmet for each supported filetype
			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("Allen_Emmet", { clear = true }),
				pattern = {
					"html",
					"css",
					"scss",
					"less",
					"javascript",
					"javascriptreact",
					"typescript",
					"typescriptreact",
					"svelte",
					"vue",
				},
				callback = function()
					vim.cmd("EmmetInstall")
				end,
			})
		end,
	},
}
