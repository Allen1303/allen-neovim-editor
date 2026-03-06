-- ==============================
-- lua/plugins/treesitter.lua
-- ==============================

return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },
		dependencies = {
			-- FIX: use new standalone API — old treesitter module integration is deprecated
			-- Provides correct comment type per language region (// in JS, {/* */} in JSX)
			{
				"JoosepAlviste/nvim-ts-context-commentstring",
				config = function()
					require("ts_context_commentstring").setup({})
					-- skip the deprecated nvim-treesitter module shim (speeds up loading)
					vim.g.skip_ts_context_commentstring_module = true
				end,
			},
		},
		opts = {
			ensure_installed = {
				-- Neovim internals
				"lua",
				"vim",
				"vimdoc",
				"query",
				-- Shell / docs
				"bash",
				"markdown",
				"markdown_inline",
				-- Config files
				"json",
				"yaml",
				"toml",
				-- Web stack
				"html",
				"css",
				"javascript",
				"jsdoc",
				"typescript",
				"tsx",
				-- Uncomment as needed:
				-- "python", "go", "rust", "java",
			},

			auto_install = true, -- auto-installs missing parsers on buffer open (great for multi-machine)

			highlight = {
				enable = true,
				additional_vim_regex_highlighting = false, -- avoids duplicate highlights + slowdown
			},

			indent = {
				enable = true,
				-- NOTE: TS indent isn't perfect for all languages — disable per-ft if needed
			},

			-- FIX: was <CR> — conflicts with Enter behavior and dashboard keymap
			-- Using <C-space> / <C-s> / <M-space> (LazyVim standard)
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<C-space>",
					node_incremental = "<C-space>",
					scope_incremental = "<C-s>",
					node_decremental = "<M-space>",
				},
			},

			-- NOTE: context_commentstring configured via its own spec in dependencies above
		},

		config = function(_, opts)
			require("nvim-treesitter.configs").setup(opts)

			-- Treesitter-based folds (off by default per options.lua foldenable=false)
			-- Toggle per buffer with: :setlocal foldenable!
			local grp = vim.api.nvim_create_augroup("Allen_TreesitterFolds", { clear = true })
			vim.api.nvim_create_autocmd("FileType", {
				group = grp,
				callback = function()
					vim.opt_local.foldmethod = "expr"
					-- FIX: was nvim_treesitter#foldexpr() — old Vimscript API, deprecated
					-- Use the new Lua API (Neovim 0.9+)
					vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
				end,
			})
		end,
	},

	-- ── Auto-close & rename HTML/JSX tags ──────────────────────────────────
	{
		"windwp/nvim-ts-autotag",
		event = { "BufReadPost", "BufNewFile" },
		-- FIX: was opts = { enable = true } — outdated API, modern setup takes {}
		opts = {},
		config = function(_, opts)
			require("nvim-ts-autotag").setup(opts)
		end,
	},

	-- NOTE: nvim-treesitter/playground REMOVED — plugin was archived (deprecated)
	-- Use these built-in commands instead (available since Neovim 0.9+):
	--   :InspectTree                       → live AST viewer
	--   :Inspect                           → highlight capture groups under cursor
	--   :TSInstallInfo                     → parser status
}
