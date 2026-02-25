-- ==============================
-- lua/plugins/lsp.lua
-- ==============================
-- - Use Mason to install LSP servers/tools
-- - Use mason-lspconfig to auto-enable installed servers (Neovim 0.11+)
-- - Define per-server configs via the new `vim.lsp.config()` API
-- - Attach clean, buffer-local LSP keymaps on LspAttach

return {
	-- Core package manager for LSP binaries
	{
		"mason-org/mason.nvim",
		version = false, -- this option tracks latest (stable enough)
		build = ":MasonUpdate", -- this command updates Mason registry
		cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUpdate" },
		opts = {
			ui = {
				border = "rounded", -- this option sets a nice bordered UI
				icons = { -- this table defines status icons
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		},
	},

	-- Bridge Mason ↔ LSPConfig (modern behavior on 0.11+)
	{
		"mason-org/mason-lspconfig.nvim",
		version = false,
		dependencies = {
			"mason-org/mason.nvim",
			"neovim/nvim-lspconfig",
		},
		opts = {
			-- this list auto-installs servers if missing
			ensure_installed = {
				"lua_ls",
				"ts_ls",
				"pyright",
				"eslint",
				"html",
				"cssls",
				"jsonls",
				"yamlls",
				"bashls",
				"marksman",
			},
			-- this setting auto-enables installed servers via :h vim.lsp.enable()
			automatic_enable = true,
		},
	},

	-- Server configs (modern Neovim API + lspconfig’s configs in rtp)
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			-- ========== capabilities ==========
			-- this variable augments LSP capabilities with nvim-cmp completion
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			local ok_cmp, cmp_caps = pcall(require, "cmp_nvim_lsp")
			if ok_cmp then
				capabilities = cmp_caps.default_capabilities(capabilities)
			end

			-- ========== on_attach ==========
			-- this function runs when a server attaches to a buffer (set buffer-local maps here)
			local function on_attach(client, bufnr)
				local function buf_keymap(mode, keys, action, desc)
					vim.keymap.set(mode, keys, action, { buffer = bufnr, silent = true, desc = desc })
				end

				-- Navigation & info
				buf_keymap("n", "gd", vim.lsp.buf.definition, "LSP: goto definition")
				buf_keymap("n", "gD", vim.lsp.buf.declaration, "LSP: goto declaration")
				buf_keymap("n", "gr", vim.lsp.buf.references, "LSP: list references")
				buf_keymap("n", "gi", vim.lsp.buf.implementation, "LSP: goto implementation")
				buf_keymap("n", "K", vim.lsp.buf.hover, "LSP: hover docs")
				buf_keymap("n", "<leader>k", vim.lsp.buf.signature_help, "LSP: signature help")

				-- Workspace
				buf_keymap("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, "LSP: workspace add folder")
				buf_keymap("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, "LSP: workspace remove folder")
				buf_keymap("n", "<leader>wl", function()
					print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
				end, "LSP: workspace list folders")

				-- Code actions / rename / format
				buf_keymap({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "LSP: code action")
				buf_keymap("n", "<leader>rn", vim.lsp.buf.rename, "LSP: rename symbol")
				buf_keymap("n", "<leader>f", function()
					vim.lsp.buf.format({ async = false })
				end, "LSP: format buffer")

				-- Diagnostics (buffer-local)
				buf_keymap("n", "gl", vim.diagnostic.open_float, "Diag: line diagnostics")
				buf_keymap("n", "[d", function()
					vim.diagnostic.jump({ count = -1 })
				end, "Diag: previous")
				buf_keymap("n", "]d", function()
					vim.diagnostic.jump({ count = 1 })
				end, "Diag: next")
				buf_keymap("n", "<leader>qf", vim.diagnostic.setqflist, "Diag: to quickfix")

				if client.supports_method("textDocument/inlayHint") then
					vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
					buf_keymap("n", "<leader>ih", function()
						vim.lsp.inlay_hint.enable(
							not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }),
							{ bufnr = bufnr }
						)
					end, "LSP: toggle inlay hints")
				end
			end
			-- On_attach function ends here..

			-- ========== ESLint auto-fix on save ==========
			-- This runs EslintFixAll automatically before writing .js/.jsx/.ts/.tsx files
			vim.api.nvim_create_autocmd("BufWritePre", {
				group = vim.api.nvim_create_augroup("Allen_EslintFix", { clear = true }),
				pattern = { "*.js", "*.jsx", "*.ts", "*.tsx" },
				callback = function()
					-- Guard: only run if eslint is actually attached to this buffer
					local clients = vim.lsp.get_clients({ bufnr = 0, name = "eslint" })
					if #clients > 0 then
						vim.cmd("EslintFixAll")
					end
				end,
			})

			-- Attach maps automatically when any LSP connects
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("Allen_LspKeymaps", { clear = true }),
				callback = function(args)
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					if not client then
						return
					end
					on_attach(client, args.buf)
				end,
			})

			-- ========== per-server configs (modern API) ==========
			--  Lspconfig  exposes server definitions; and register options with vim.lsp.config
			-- Docs: repo notes that `require('lspconfig')` wrapper is deprecated.
			-- Lua: make the server understand Neovim runtime and globals
			vim.lsp.config("lua_ls", {
				capabilities = capabilities, -- this table adds completion capabilities
				settings = {
					Lua = {
						runtime = { version = "LuaJIT" },
						workspace = {
							checkThirdParty = false, -- this option avoids prompts about love2d/etc.
							library = {
								-- this list adds Neovim runtime files to the server's library
								vim.env.VIMRUNTIME,
								"${3rd}/luv/library",
							},
						},
						diagnostics = { globals = { "vim", "require" } }, -- this list silences “undefined global” for vim/require
						hint = { enable = true },
						telemetry = { enable = false },
					},
				},
			})

			-- TypeScript/JavaScript
			--  nvim-lspconfig renamed `tsserver` → `ts_ls` in newer version.
			vim.lsp.config("ts_ls", {
				capabilities = capabilities,
				settings = {
					javascript = { inlayHints = { includeInlayParameterNameHints = "all" } },
					typescript = { inlayHints = { includeInlayParameterNameHints = "all" } },
				},
			})

			-- HTML/CSS/JSON/YAML/Bash/Markdown (simple defaults)
			vim.lsp.config("html", { capabilities = capabilities })
			vim.lsp.config("cssls", { capabilities = capabilities })
			vim.lsp.config("jsonls", { capabilities = capabilities })
			vim.lsp.config("yamlls", { capabilities = capabilities })
			vim.lsp.config("bashls", { capabilities = capabilities })
			vim.lsp.config("marksman", { capabilities = capabilities })

			-- ESLint (optional but handy in web projects)
			vim.lsp.config("eslint", {
				capabilities = capabilities,
				settings = { format = true },
			})
		end,
	},
}
