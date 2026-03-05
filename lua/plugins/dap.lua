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

return {
	-- ── Core DAP + UI + inline values ──────────────────────────────────────
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"theHamsta/nvim-dap-virtual-text",
			"nvim-neotest/nvim-nio", -- required by dap-ui >= 3.x
			-- FIX: mason-nvim-dap removed from here — it has its own top-level
			-- spec below; declaring it twice caused Lazy to load it twice
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

			-- FIX: <S-F11> is often intercepted by macOS Mission Control
			-- <F12> added as a reliable alternative for step out
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

			-- UI: left pane for info, bottom for REPL/console
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

			-- Inline variable values
			require("nvim-dap-virtual-text").setup({})

			-- Auto-open/close UI with sessions (hands-free)
			dap.listeners.after.event_initialized["dapui_open"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui_close"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_close"] = function()
				dapui.close()
			end

			-- Transparency hardening (theme-agnostic)
			-- FIX: was nvim_exec_autocmds("ColorScheme") — fired all listeners
			-- Extracted to function and called directly on load
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

			-- Apply immediately on first load
			apply_dap_transparent()

			-- Signs: inherit colors from DiagnosticSign* (theme-agnostic)
			vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DiagnosticSignError" })
			vim.fn.sign_define("DapBreakpointCondition", { text = "", texthl = "DiagnosticSignWarn" })
			vim.fn.sign_define("DapLogPoint", { text = "", texthl = "DiagnosticSignInfo" })
			vim.fn.sign_define("DapStopped", { text = "", texthl = "DiagnosticSignHint", linehl = "Visual" })

			-- ── JS / TS debug configurations (Node + Chrome on macOS) ────────
			-- Adapters provided by vscode-js-debug (installed via mason-nvim-dap)
			local js_langs = { "javascript", "javascriptreact", "typescript", "typescriptreact" }

			for _, lang in ipairs(js_langs) do
				dap.configurations[lang] = {
					-- 1) Node: launch current file (scripts, CLIs)
					{
						type = "pwa-node",
						request = "launch",
						name = "Node: Launch current file",
						program = "${file}",
						cwd = "${workspaceFolder}",
						console = "integratedTerminal",
						sourceMaps = true,
					},

					-- 2) Node: attach to running process (choose PID)
					{
						type = "pwa-node",
						request = "attach",
						name = "Node: Attach to process",
						processId = require("dap.utils").pick_process,
						cwd = "${workspaceFolder}",
					},

					-- 3) Chrome: launch to dev server
					-- FIX: added port note — Vite: 5173 | Next.js/CRA: 3000
					{
						type = "pwa-chrome",
						request = "launch",
						name = "Chrome: Launch http://localhost:5173",
						url = "http://localhost:5173", -- Vite: 5173 | Next.js/CRA: 3000
						webRoot = "${workspaceFolder}",
						-- Uncomment if Chrome auto-detect fails on macOS:
						-- runtimeExecutable = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
					},

					-- 4) Chrome: attach to existing session (--remote-debugging-port=9222)
					{
						type = "pwa-chrome",
						request = "attach",
						name = "Chrome: Attach (9222)",
						port = 9222,
						webRoot = "${workspaceFolder}",
					},

					-- 5) TypeScript via ts-node (requires ts-node + typescript devDeps)
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
			end
		end,
	},

	-- ── Mason bridge: installs vscode-js-debug (pwa-node / pwa-chrome) ─────
	{
		"jay-babu/mason-nvim-dap.nvim",
		-- FIX: was williamboman/mason.nvim — correct org is mason-org (matches lsp-config.lua)
		dependencies = { "mason-org/mason.nvim" },
		opts = {
			ensure_installed = { "js" }, -- installs vscode-js-debug adapter
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
