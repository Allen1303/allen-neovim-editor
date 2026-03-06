-- ==============================
-- lua/plugins/emmet.lua
-- ==============================
-- Emmet: expand abbreviations like VSCode
-- Type:  p{InvestorInsights}+button*3  then press <Tab> to expand
-- Works in: html, css, jsx, tsx, js, ts

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
			-- Disable global install — we enable per filetype only
			vim.g.user_emmet_install_global = 0

			-- Use Tab as the expand key (VSCode-style)
			-- <C-y>, is the default but Tab feels more natural
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
			local emmet_ft = {
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
			}

			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("Allen_Emmet", { clear = true }),
				pattern = emmet_ft,
				callback = function()
					-- Enable Emmet for this buffer
					vim.cmd("EmmetInstall")

					-- Tab expands Emmet if cursor is at end of an abbreviation,
					-- otherwise falls through to normal Tab behavior (indent / cmp)
					vim.keymap.set("i", "<Tab>", function()
						-- Check if the character before cursor looks like an Emmet abbrev
						local col = vim.fn.col(".") - 1
						local line = vim.fn.getline(".")
						local char = line:sub(col, col)

						-- If there's a non-whitespace char before cursor → try Emmet expand
						if col > 0 and char:match("[%w%.#%{%}%+%*%>%^%[%]\"']") then
							-- Use emmet's expand function
							return vim.api.nvim_replace_termcodes("<plug>(emmet-expand-abbr)", true, false, true)
						end

						-- Otherwise fall through to normal Tab
						-- (cmp uses its own Tab mapping so this won't conflict)
						return "<Tab>"
					end, { buffer = true, expr = true, silent = true, desc = "Emmet expand or Tab" })
				end,
			})
		end,
	},
}
