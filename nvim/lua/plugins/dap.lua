-- ==============================
-- lua/plugins/dap.lua
-- ==============================
-- GOALS:
-- - Make JS/TS debugging easy on macOS (Node + Chrome via vscode-js-debug)
-- - Small, annotated setup with a friendly UI and inline values
-- - Auto-install the JS adapter via Mason; keep highlights transparent

return {
	-- Core DAP + UI + inline values + Mason bridge (with required nvim-nio)
	{
		"mfussenegger/nvim-dap", -- this plugin is the DAP client
		dependencies = {
			"rcarriga/nvim-dap-ui", -- this plugin provides sidebars (scopes/breakpoints/etc.)
			"theHamsta/nvim-dap-virtual-text", -- this plugin shows inline variable values
			"jay-babu/mason-nvim-dap.nvim", -- this plugin installs adapters (vscode-js-debug)
			"nvim-neotest/nvim-nio", -- this plugin is required by dap-ui >= 3.x
		},

		-- Simple, memorable keys for sessions, stepping, breakpoints, and UI
		keys = {
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
			local dap, dapui = require("dap"), require("dapui")

			-- UI: left pane for info, bottom for REPL/console (clean + predictable)
			dapui.setup({
				controls = { enabled = true, element = "repl" }, -- this option shows play/pause icons above REPL
				layouts = {
					{ elements = { "scopes", "breakpoints", "stacks", "watches" }, size = 40, position = "left" },
					{ elements = { "repl", "console" }, size = 10, position = "bottom" },
				},
				floating = { border = "rounded" }, -- this option keeps floats neat
			})
			require("nvim-dap-virtual-text").setup({}) -- this call enables inline variable values

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

			-- Transparent-friendly highlight tweaks (theme-agnostic)
			local grp = vim.api.nvim_create_augroup("Allen_Dap_Transparent", { clear = true })
			vim.api.nvim_create_autocmd("ColorScheme", {
				group = grp,
				callback = function()
					local set = vim.api.nvim_set_hl
					pcall(set, 0, "DapUIFloatNormal", { bg = "NONE" })
					pcall(set, 0, "DapUIFloatBorder", { bg = "NONE" })
					pcall(set, 0, "DapUIScope", { bg = "NONE" })
					pcall(set, 0, "DapUIType", { bg = "NONE" })
					pcall(set, 0, "DapUIModifiedValue", { bg = "NONE" })
					pcall(set, 0, "DapUIWinSelect", { bg = "NONE" })
				end,
			})
			vim.api.nvim_exec_autocmds("ColorScheme", {}) -- this call applies immediately

			-- Signs: use your theme’s DiagnosticSign* groups for colors
			vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DiagnosticSignError" })
			vim.fn.sign_define("DapBreakpointCondition", { text = "", texthl = "DiagnosticSignWarn" })
			vim.fn.sign_define("DapLogPoint", { text = "", texthl = "DiagnosticSignInfo" })
			vim.fn.sign_define("DapStopped", { text = "", texthl = "DiagnosticSignHint", linehl = "Visual" })

			-- ── JavaScript / TypeScript configurations (Node + Chrome on macOS) ────
			-- Adapters come from vscode-js-debug (installed via mason-nvim-dap as "js").
			local js_langs = { "javascript", "javascriptreact", "typescript", "typescriptreact" }

			for _, lang in ipairs(js_langs) do
				dap.configurations[lang] = {
					-- 1) Node: launch current file (great for scripts, CLIs)
					{
						type = "pwa-node",
						request = "launch",
						name = "Node: Launch current file",
						program = "${file}",
						cwd = "${workspaceFolder}",
						console = "integratedTerminal",
						sourceMaps = true,
					},

					-- 2) Node: attach to a running process (choose the PID)
					{
						type = "pwa-node",
						request = "attach",
						name = "Node: Attach to process",
						processId = require("dap.utils").pick_process,
						cwd = "${workspaceFolder}",
					},

					-- 3) Browser: launch Chrome to your dev server (mac-friendly)
					{
						type = "pwa-chrome",
						request = "launch",
						name = "Chrome: Launch http://localhost:5173",
						url = "http://localhost:5173", -- this variable should match your dev server (Vite often 5173, Next 3000)
						webRoot = "${workspaceFolder}", -- this variable points to your project root for source maps
						-- If auto-detect fails, set Chrome explicitly on macOS:
						-- runtimeExecutable = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
					},

					-- 4) Browser: attach to an existing Chrome started with --remote-debugging-port=9222
					{
						type = "pwa-chrome",
						request = "attach",
						name = "Chrome: Attach (9222)",
						port = 9222,
						webRoot = "${workspaceFolder}",
					},

					-- 5) (Optional) TypeScript via ts-node (requires ts-node + typescript dev deps)
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

	-- Mason bridge: installs and wires vscode-js-debug (pwa-node / pwa-chrome)
	{
		"jay-babu/mason-nvim-dap.nvim",
		dependencies = { "williamboman/mason.nvim" }, -- this plugin is the general Mason pkg manager
		opts = {
			ensure_installed = { "js" }, -- this option installs the JS debug adapter (vscode-js-debug)
			automatic_installation = true, -- this option installs on first use if missing
			handlers = {
				function(cfg)
					require("mason-nvim-dap").default_setup(cfg)
				end, -- this function sets up any adapter by default
				js = function(cfg)
					require("mason-nvim-dap").default_setup(cfg)
				end, -- this function is explicit for clarity, no extra tweaks
			},
		},
	},
}
