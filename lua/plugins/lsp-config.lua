-- ==============================
-- lua/plugins/lsp-config.lua
-- ==============================
-- - Use Mason to install LSP servers/tools
-- - Use mason-lspconfig to auto-enable installed servers (Neovim 0.11+)
-- - Define per-server configs via the new `vim.lsp.config()` API
-- - Attach clean, buffer-local LSP keymaps on LspAttach

return {
	-- Core package manager for LSP binaries
	{
		"mason-org/mason.nvim",
		version = "*", -- FIX: was false (HEAD tracking) — "*" uses latest stable tag
		build = ":MasonUpdate",
		cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUpdate" },
		opts = {
			ui = {
				border = "rounded",
				icons = {
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
		version = "*", -- FIX: was false — use latest stable tag
		dependencies = {
			"mason-org/mason.nvim",
			"neovim/nvim-lspconfig",
		},
		opts = {
			-- auto-installs servers if missing
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
			-- auto-enables installed servers via :h vim.lsp.enable()
			automatic_enable = true,
		},
	},

	-- Server configs (modern Neovim API + lspconfig's configs in rtp)
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			-- ========== capabilities ==========
			-- augments LSP capabilities with nvim-cmp completion
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			local ok_cmp, cmp_caps = pcall(require, "cmp_nvim_lsp")
			if ok_cmp then
				capabilities = cmp_caps.default_capabilities(capabilities)
			end

			-- ========== on_attach ==========
			-- runs when a server attaches to a buffer — sets buffer-local keymaps
			local function on_attach(client, bufnr)
				local function map(mode, keys, action, desc)
					vim.keymap.set(mode, keys, action, { buffer = bufnr, silent = true, desc = desc })
				end

				-- ── Navigation & info ──────────────────────────────────────
				map("n", "gd", vim.lsp.buf.definition, "LSP: goto definition")
				map("n", "gD", vim.lsp.buf.declaration, "LSP: goto declaration")
				map("n", "gr", vim.lsp.buf.references, "LSP: list references")
				map("n", "gi", vim.lsp.buf.implementation, "LSP: goto implementation")
				map("n", "K", vim.lsp.buf.hover, "LSP: hover docs")

				-- FIX: was <leader>k — conflicts with k motion and future <leader>k* bindings
				-- Added insert mode <C-k> for signature help (LazyVim standard)
				map("n", "<leader>lh", vim.lsp.buf.signature_help, "LSP: signature help")
				map("i", "<C-k>", vim.lsp.buf.signature_help, "LSP: signature help (insert)")

				-- ── Workspace ─────────────────────────────────────────────
				-- FIX: was <leader>wa/wr/wl — conflicted with <leader>w (save file)
				-- Moved to <leader>lw* to stay in the clean LSP namespace
				map("n", "<leader>lwa", vim.lsp.buf.add_workspace_folder, "LSP: workspace add folder")
				map("n", "<leader>lwr", vim.lsp.buf.remove_workspace_folder, "LSP: workspace remove folder")
				map("n", "<leader>lwl", function()
					print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
				end, "LSP: workspace list folders")

				-- ── Code actions / rename / format ────────────────────────
				map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "LSP: code action")

				-- FIX: was <leader>rn — conflicted with <leader>rc/rl/rp (run commands)
				map("n", "<leader>lr", vim.lsp.buf.rename, "LSP: rename symbol")

				-- FIX: was <leader>f — conflicted with <leader>ff (telescope find files)
				map("n", "<leader>lf", function()
					vim.lsp.buf.format({ async = false })
				end, "LSP: format buffer")

				-- ── Diagnostics ───────────────────────────────────────────
				map("n", "gl", vim.diagnostic.open_float, "Diag: line diagnostics")

				-- FIX: was <leader>qf — conflicted with <leader>qo/<leader>qc (quickfix)
				-- Moved to <leader>xq to align with <leader>xd in keymaps.lua
				map("n", "<leader>xq", vim.diagnostic.setqflist, "Diag: send to quickfix")

				-- Note: [d / ]d global diagnostic nav lives in keymaps.lua
				-- These buffer-local ones override cleanly per-buffer when LSP is active
				map("n", "[d", function()
					vim.diagnostic.jump({ count = -1, float = true })
				end, "Diag: previous")
				map("n", "]d", function()
					vim.diagnostic.jump({ count = 1, float = true })
				end, "Diag: next")

				-- ── Inlay hints (0.10+ only) ──────────────────────────────
				if client.supports_method("textDocument/inlayHint") then
					vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
					map("n", "<leader>ih", function()
						vim.lsp.inlay_hint.enable(
							not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }),
							{ bufnr = bufnr }
						)
					end, "LSP: toggle inlay hints")
				end
			end

			-- ========== ESLint auto-fix on save ==========
			-- Runs EslintFixAll automatically before writing .js/.jsx/.ts/.tsx files
			vim.api.nvim_create_autocmd("BufWritePre", {
				group = vim.api.nvim_create_augroup("Allen_EslintFix", { clear = true }),
				pattern = { "*.js", "*.jsx", "*.ts", "*.tsx" },
				callback = function()
					local clients = vim.lsp.get_clients({ bufnr = 0, name = "eslint" })
					if #clients > 0 then
						pcall(function()
							vim.cmd("EslintFixAll")
						end)
					end
				end,
			})

			-- ========== LspAttach — wire on_attach to every server ==========
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

			-- ========== per-server configs ==========

			-- Lua: teach the server about Neovim runtime and globals
			vim.lsp.config("lua_ls", {
				capabilities = capabilities,
				settings = {
					Lua = {
						runtime = { version = "LuaJIT" },
						workspace = {
							checkThirdParty = false,
							library = {
								vim.env.VIMRUNTIME,
								"${3rd}/luv/library",
							},
						},
						diagnostics = { globals = { "vim", "require" } },
						hint = { enable = true },
						telemetry = { enable = false },
					},
				},
			})

			-- TypeScript / JavaScript
			-- Note: nvim-lspconfig renamed tsserver → ts_ls
			vim.lsp.config("ts_ls", {
				capabilities = capabilities,
				settings = {
					javascript = { inlayHints = { includeInlayParameterNameHints = "all" } },
					typescript = { inlayHints = { includeInlayParameterNameHints = "all" } },
				},
			})

			-- ADD: pyright was in ensure_installed but had no config block
			vim.lsp.config("pyright", {
				capabilities = capabilities,
				settings = {
					python = {
						analysis = {
							typeCheckingMode = "basic",
							autoSearchPaths = true,
							useLibraryCodeForTypes = true,
						},
					},
				},
			})

			-- HTML / CSS / JSON / YAML / Bash / Markdown (clean defaults)
			vim.lsp.config("html", { capabilities = capabilities })
			vim.lsp.config("cssls", { capabilities = capabilities })
			vim.lsp.config("jsonls", { capabilities = capabilities })
			vim.lsp.config("yamlls", { capabilities = capabilities })
			vim.lsp.config("bashls", { capabilities = capabilities })
			vim.lsp.config("marksman", { capabilities = capabilities })

			-- ESLint
			vim.lsp.config("eslint", {
				capabilities = capabilities,
				settings = { format = true },
			})
		end,
	},
}
