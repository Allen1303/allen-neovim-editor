-- ==============================
-- lua/plugins/lint.lua
-- ==============================
-- nvim-lint: async linting separate from LSP and formatting
-- Runs linters on save and shows results as diagnostics
-- Complements conform.nvim (formatting) and eslint LSP

return {
	{
		"mfussenegger/nvim-lint",
		version = false,
		event = { "BufReadPost", "BufWritePost", "BufNewFile" },
		config = function()
			local lint = require("lint")

			-- ── Linter assignments per filetype ──────────────────────────
			lint.linters_by_ft = {
				-- JavaScript / TypeScript — eslint via LSP handles most of this
				-- but eslint_d gives faster feedback as a standalone linter
				javascript = { "eslint_d" },
				javascriptreact = { "eslint_d" },
				typescript = { "eslint_d" },
				typescriptreact = { "eslint_d" },

				-- Python
				python = { "ruff" },

				-- Lua (Neovim config)
				lua = { "luacheck" },

				-- Markdown
				markdown = { "markdownlint" },
			}

			-- ── Auto-lint triggers ────────────────────────────────────────
			local lint_augroup = vim.api.nvim_create_augroup("Allen_Lint", { clear = true })

			vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
				group = lint_augroup,
				callback = function()
					-- Only lint if a linter is configured for this filetype
					local ft = vim.bo.filetype
					local linters = lint.linters_by_ft[ft]
					if linters and #linters > 0 then
						lint.try_lint()
					end
				end,
			})

			-- ── Manual lint keymap ────────────────────────────────────────
			vim.keymap.set("n", "<leader>cl", function()
				lint.try_lint()
			end, { silent = true, desc = "Code: lint file" })
		end,
	},
}
