-- ==============================
-- lua/plugins/mini-modules.lua
-- ==============================
-- GOALS:
-- - Use nvim-mini modules (icons, files, surround, ai, completion)
-- - Keep plugin specs lean; lazy-load on first keypress/insert
-- - Honor transparent UI for mini.files & completion across ANY theme

return {
	-- Icons early (and devicons shim for other plugins)
	{
		"nvim-mini/mini.icons",
		version = false,
		lazy = false,
		config = function()
			require("mini.icons").setup() -- init icon set
			require("mini.icons").mock_nvim_web_devicons() -- devicons shim
		end,
	},

	-- Statusline (simple default; customize later)
	{
		"nvim-mini/mini.statusline",
		version = false,
		lazy = false,
		config = function()
			require("mini.statusline").setup({ use_icons = true })
			vim.opt.laststatus = 3
		end,
	},

	-- File explorer (lazy on keys)
	{
		"nvim-mini/mini.files",
		version = false,
		keys = {
			{
				"<leader>e",
				function()
					require("mini.files").open()
				end,
				desc = "MiniFiles: explore CWD",
			},
			{ "<leader>E", desc = "MiniFiles: reveal current file" },
		},
		config = function()
			local mf = require("mini.files")
			mf.setup({
				options = { use_as_default_explorer = true, permanent_delete = true },
				windows = { preview = true, width_focus = 40, width_nofocus = 25, width_preview = 60 },
			})

			-- Transparent UI for mini.files (theme-agnostic)
			local function mini_files_transparent()
				local set = vim.api.nvim_set_hl
				pcall(set, 0, "MiniFilesNormal", { bg = "NONE" })
				pcall(set, 0, "MiniFilesBorder", { bg = "NONE" })
				pcall(set, 0, "MiniFilesTitle", { bg = "NONE" })
			end
			vim.api.nvim_create_autocmd("ColorScheme", {
				group = vim.api.nvim_create_augroup("Allen_MiniFiles_Transparent", { clear = true }),
				callback = mini_files_transparent,
			})
			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("Allen_MiniFiles_WinHL", { clear = true }),
				pattern = "minifiles",
				callback = function()
					vim.wo.winhl = table.concat({
						"Normal:MiniFilesNormal",
						"NormalNC:MiniFilesNormal",
						"FloatBorder:MiniFilesBorder",
						"EndOfBuffer:MiniFilesNormal",
						"WinSeparator:MiniFilesBorder",
					}, ",")
				end,
			})
			mini_files_transparent()

			-- Reveal current file (graceful fallback for no-name buffers)
			local function reveal_current_file()
				local path = vim.api.nvim_buf_get_name(0)
				if path == "" then
					mf.open()
					return
				end
				mf.open(vim.fn.fnamemodify(path, ":h"))
				if type(mf.reveal) == "function" then
					pcall(mf.reveal, path, { focus = true, open = true })
				end
			end
			vim.keymap.set("n", "<leader>E", reveal_current_file, { desc = "MiniFiles: reveal current file" })
		end,
	},

	-- Completion (lazy on first Insert; defaults are good)
	{
		"nvim-mini/mini.completion",
		version = false,
		event = "InsertEnter",
		config = function()
			require("mini.completion").setup() -- enable minimal, LSP-friendly completion

			-- Transparent popup menu/doc across themes
			local grp = vim.api.nvim_create_augroup("Allen_MiniCompletion_Transparent", { clear = true })
			vim.api.nvim_create_autocmd("ColorScheme", {
				group = grp,
				callback = function()
					local set = vim.api.nvim_set_hl
					pcall(set, 0, "Pmenu", { bg = "NONE" })
					pcall(set, 0, "PmenuSel", { bg = "NONE" })
					pcall(set, 0, "PmenuSbar", { bg = "NONE" })
					pcall(set, 0, "PmenuThumb", { bg = "NONE" })
					pcall(set, 0, "PmenuBorder", { bg = "NONE" })
				end,
			})
			vim.api.nvim_exec_autocmds("ColorScheme", {})
		end,
	},

	-- Text-objects & surround (lazy on VeryLazy)
	{ "nvim-mini/mini.surround", version = false, event = "VeryLazy", config = true },
	{ "nvim-mini/mini.ai", version = false, event = "VeryLazy", config = true },
	{ "nvim-mini/mini.operators", version = false, event = "VeryLazy", config = true },
	{ "nvim-mini/mini.pairs", version = false, event = "InsertEnter", config = true }, -- this plugin auto-inserts matching pairs ()[]{}''""

	-- Comments: gc / gcc / gb motions (tiny & fast)
	{
		"nvim-mini/mini.comment",
		version = false,
		event = "VeryLazy", -- load when things are calm
		config = function()
			require("mini.comment").setup() -- defaults: gcc (line), gc{motion}, gb (block)
		end,
	},

	-- Indent guides: subtle, transparent-friendly
	{
		"nvim-mini/mini.indentscope",
		version = false,
		event = { "BufReadPre", "BufNewFile" }, -- show scopes as you open/edit files
		init = function()
			vim.b.miniindentscope_disable = false -- per-buffer toggle (leave enabled by default)
		end,
		config = function()
			require("mini.indentscope").setup({
				symbol = "￤", -- thin guide; easy on transparent themes
				draw = { delay = 50, animation = require("mini.indentscope").gen_animation.none() },
				options = { try_as_border = true }, -- use existing indent as scope when possible
			})

			-- Make indent guides blend on any theme
			local grp = vim.api.nvim_create_augroup("Allen_Indent_Transparent", { clear = true })
			vim.api.nvim_create_autocmd("ColorScheme", {
				group = grp,
				callback = function()
					local set = vim.api.nvim_set_hl
					-- Keep them faint; no solid backgrounds
					set(
						0,
						"MiniIndentscopeSymbol",
						{ bg = "NONE", fg = vim.api.nvim_get_hl_by_name("Comment", true).foreground or nil }
					)
					set(0, "MiniIndentscopePrefix", { bg = "NONE", fg = "NONE" }) -- no special color for the virtual prefix
				end,
			})
			vim.api.nvim_exec_autocmds("ColorScheme", {})
		end,
	},
}
