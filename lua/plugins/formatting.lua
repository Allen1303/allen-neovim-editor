-- ==============================
-- lua/plugins/formatting.lua
-- ==============================
-- - Run fast, reliable formatters per filetype
-- - Format on save with LSP fallback (so you always get something)
-- - Auto-install formatters via mason-tool-installer

return {
	-- ── Auto-install formatters via Mason ───────────────────────────────────
	-- ADD: Mason handles LSP servers (lsp-config.lua) but formatters need this
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "mason-org/mason.nvim" },
		opts = {
			ensure_installed = {
				"stylua", -- Lua formatter
				"prettierd", -- Fast prettier daemon (JS/TS/HTML/CSS/JSON/YAML/MD)
				"shfmt", -- Shell formatter
				"ruff", -- Python linter + formatter (fast)
				"black", -- Python formatter fallback
			},
		},
	},

	-- ── conform.nvim: formatter runner ──────────────────────────────────────
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" }, -- load before saving a file
		cmd = { "ConformInfo" }, -- :ConformInfo shows resolved formatters
		opts = {
			-- Map filetypes → preferred formatters
			-- FIX: added stop_after_first = true — prevents conform trying all
			--      formatters in the list instead of stopping at first available
			formatters_by_ft = {
				lua = { "stylua" },

				-- Python: ruff_format first (fast), black as fallback
				python = { "ruff_format", "black", stop_after_first = true },

				-- JS/TS: prettierd first (daemon = fast), prettier, biome last
				-- Note: biome only activates if biome.json exists in the project
				javascript = { "prettierd", "prettier", "biome", stop_after_first = true },
				typescript = { "prettierd", "prettier", "biome", stop_after_first = true },
				javascriptreact = { "prettierd", "prettier", "biome", stop_after_first = true },
				typescriptreact = { "prettierd", "prettier", "biome", stop_after_first = true },

				json = { "prettierd", "prettier", "biome", stop_after_first = true },
				yaml = { "prettierd", "prettier", stop_after_first = true },
				html = { "prettierd", "prettier", stop_after_first = true },
				css = { "prettierd", "prettier", stop_after_first = true },
				markdown = { "prettierd", "prettier", stop_after_first = true },

				-- ADD: bash was missing — sh and bash both use shfmt
				sh = { "shfmt" },
				bash = { "shfmt" },
			},

			-- Format on save with graceful LSP fallback
			-- FIX: lsp_fallback = true is deprecated — renamed to lsp_format = "fallback"
			-- FIX: timeout raised from 1000ms → 3000ms (black/prettier on large files)
			format_on_save = function()
				return { lsp_format = "fallback", timeout_ms = 3000 }
			end,

			-- Per-formatter arguments
			formatters = {
				shfmt = { prepend_args = { "-i", "2", "-ci" } }, -- 2-space indent, case indent
				black = { prepend_args = { "--quiet", "--line-length", "100" } },
			},
		},
		config = function(_, opts)
			require("conform").setup(opts)

			-- :Format — run formatter manually on current buffer
			-- FIX: lsp_fallback = true → lsp_format = "fallback"
			vim.api.nvim_create_user_command("Format", function()
				require("conform").format({ async = false, lsp_format = "fallback" })
			end, { desc = "Format current buffer" })
		end,
	},
}
