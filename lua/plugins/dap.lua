-- ==============================
-- lua/plugins/dap.lua
-- ==============================
-- - Make JS/TS debugging easy on macOS (Node + Chrome via vscode-js-debug)
-- - Small, annotated setup with a friendly UI and inline values
-- - Auto-install the JS adapter via Mason; keep highlights transparent

-- <leader>d namespace: diagnostics + DAP
-- <leader>dq — diagnostic to quickfix (lsp-config.lua)
-- <leader>dB — DAP conditional breakpoint
-- <leader>dl — DAP log point
-- <leader>du — DAP UI toggle
-- <leader>dr — DAP REPL toggle

-- Filetype split:
--   javascriptreact / typescriptreact → Chrome configs only (Node can't run JSX)
--   javascript / typescript           → Chrome + Node configs

return {
	-- ── Core DAP + UI + inline values ──────────────────────────────────────
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"theHamsta/nvim-dap-virtual-text",
			"nvim-neotest/nvim-nio",
		},

		keys = {
			-- ── Session control ───────────────────────────────────────
			{
				"<F5>",
				function()
					require("dap").continue()
				end,
				desc = "DAP: Start/Continue",
			},
			{
				"<F6>",
				function()
					require("dap").terminate()
				end,
				desc = "DAP: Terminate",
			},
			{
				"<F10>",
				function()
					require("dap").step_over()
				end,
				desc = "DAP: Step Over",
			},
			{
				"<F11>",
				function()
					require("dap").step_into()
				end,
				desc = "DAP: Step Into",
			},
			{
				"<S-F11>",
				function()
					require("dap").step_out()
				end,
				desc = "DAP: Step Out",
			},
			{
				"<F12>",
				function()
					require("dap").step_out()
				end,
				desc = "DAP: Step Out (alt)",
			},

			-- ── Breakpoints ───────────────────────────────────────────
			{
				"<F9>",
				function()
					require("dap").toggle_breakpoint()
				end,
				desc = "DAP: Toggle Breakpoint",
			},
			{
				"<leader>dB",
				function()
					vim.ui.input({ prompt = "Condition > " }, function(cond)
						if cond and #cond > 0 then
							require("dap").set_breakpoint(cond)
						end
					end)
				end,
				desc = "DAP: Conditional Breakpoint",
			},
			{
				"<leader>dl",
				function()
					vim.ui.input({ prompt = "Log message > " }, function(msg)
						if msg and #msg > 0 then
							require("dap").set_breakpoint(nil, nil, msg)
						end
					end)
				end,
				desc = "DAP: Log Point",
			},

			-- ── UI & REPL ─────────────────────────────────────────────
			{
				"<leader>du",
				function()
					require("dapui").toggle()
				end,
				desc = "DAP UI: Toggle",
			},
			{
				"<leader>dr",
				function()
					require("dap").repl.toggle()
				end,
				desc = "DAP: REPL Toggle",
			},
		},

		config = function()
			local dap = require("dap")
			local dapui = require("dapui")

			-- ── UI setup ──────────────────────────────────────────────
			dapui.setup({
				controls = { enabled = true, element = "repl" },
				layouts = {
					{
						elements = { "scopes", "breakpoints", "stacks", "watches" },
						size = 40,
						position = "left",
					},
					{
						elements = { "repl", "console" },
						size = 10,
						position = "bottom",
					},
				},
				floating = { border = "rounded" },
			})

			-- Inline variable values next to each line
			require("nvim-dap-virtual-text").setup({})

			-- Auto-open/close UI with sessions
			dap.listeners.after.event_initialized["dapui_open"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui_close"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_close"] = function()
				dapui.close()
			end

			-- ── Transparency ──────────────────────────────────────────
			local function apply_dap_transparent()
				local set = vim.api.nvim_set_hl
				pcall(set, 0, "DapUIFloatNormal", { bg = "NONE" })
				pcall(set, 0, "DapUIFloatBorder", { bg = "NONE" })
				pcall(set, 0, "DapUIScope", { bg = "NONE" })
				pcall(set, 0, "DapUIType", { bg = "NONE" })
				pcall(set, 0, "DapUIModifiedValue", { bg = "NONE" })
				pcall(set, 0, "DapUIWinSelect", { bg = "NONE" })
			end
			vim.api.nvim_create_autocmd("ColorScheme", {
				group = vim.api.nvim_create_augroup("Allen_Dap_Transparent", { clear = true }),
				callback = apply_dap_transparent,
			})
			apply_dap_transparent()

			-- ── Signs ─────────────────────────────────────────────────
			-- FIX: Unicode chars — Nerd Font icons don't render in signcolumn
			-- FIX: vim.schedule ensures signs apply after all plugins load
			vim.schedule(function()
				vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticSignError" })
				vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticSignWarn" })
				vim.fn.sign_define("DapLogPoint", { text = "◎", texthl = "DiagnosticSignInfo" })
				vim.fn.sign_define("DapStopped", { text = "→", texthl = "DiagnosticSignHint", linehl = "Visual" })
			end)

			-- ── Adapters ─────────────────────────────────────────────
			-- FIX: mason-nvim-dap doesn't always auto-register pwa-node/pwa-chrome
			-- Hardcoding the Mason install path ensures reliable detection
			local js_debug_path =
				vim.fn.expand("~/.local/share/nvim/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js")

			for _, adapter in ipairs({ "pwa-node", "pwa-chrome" }) do
				dap.adapters[adapter] = {
					type = "server",
					host = "localhost",
					port = "${port}",
					executable = {
						command = "node",
						args = { js_debug_path, "${port}" },
					},
				}
			end

			-- ── Chrome configs: JSX/TSX + JS/TS ─────────────────────
			-- FIX: JSX/TSX only get Chrome configs — Node.js can't run JSX files
			-- JS/TS get both Chrome AND Node configs
			local chrome_configs = {
				{
					type = "pwa-chrome",
					request = "launch",
					name = "Chrome: Launch http://localhost:5173",
					url = "http://localhost:5173",
					webRoot = "${workspaceFolder}",
					-- Uncomment if Chrome auto-detect fails on macOS:
					-- runtimeExecutable = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
				},
				{
					type = "pwa-chrome",
					request = "attach",
					name = "Chrome: Attach (9222)",
					port = 9222,
					webRoot = "${workspaceFolder}",
				},
			}

			local node_configs = {
				{
					type = "pwa-node",
					request = "launch",
					name = "Node: Launch current file",
					program = "${file}",
					cwd = "${workspaceFolder}",
					console = "integratedTerminal",
					sourceMaps = true,
				},
				{
					type = "pwa-node",
					request = "attach",
					name = "Node: Attach to process",
					processId = require("dap.utils").pick_process,
					cwd = "${workspaceFolder}",
				},
				{
					type = "pwa-node",
					request = "launch",
					name = "Node: Launch TS via ts-node",
					program = "${file}",
					cwd = "${workspaceFolder}",
					runtimeExecutable = "node",
					runtimeArgs = { "-r", "ts-node/register" },
					sourceMaps = true,
					skipFiles = { "<node_internals>/**" },
				},
			}

			-- JSX/TSX — Chrome only
			for _, lang in ipairs({ "javascriptreact", "typescriptreact" }) do
				dap.configurations[lang] = chrome_configs
			end

			-- JS/TS — Chrome + Node
			for _, lang in ipairs({ "javascript", "typescript" }) do
				dap.configurations[lang] = vim.list_extend(vim.deepcopy(chrome_configs), node_configs)
			end
		end,
	},

	-- ── Mason bridge: installs vscode-js-debug ─────────────────────────────
	{
		"jay-babu/mason-nvim-dap.nvim",
		dependencies = { "mason-org/mason.nvim" },
		opts = {
			ensure_installed = { "js" },
			automatic_installation = true,
			handlers = {
				function(cfg)
					require("mason-nvim-dap").default_setup(cfg)
				end,
				js = function(cfg)
					require("mason-nvim-dap").default_setup(cfg)
				end,
			},
		},
	},
}
