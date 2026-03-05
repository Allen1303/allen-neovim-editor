-- ==============================
-- lua/plugins/project.lua
-- ==============================
-- - Auto-detect project root (git / common markers)
-- - Integrate with Telescope (project picker)

return {
	{
		"ahmedkhalf/project.nvim",
		version = "*",
		-- FIX: was BufReadPre/BufNewFile — too early for telescope extension load
		-- VeryLazy ensures telescope is ready before we register the extension
		event = "VeryLazy",
		opts = {
			-- LSP root detection first, pattern fallback second
			detection_methods = { "lsp", "pattern" },

			-- Common project root markers across languages
			patterns = {
				".git",
				"package.json",
				"pyproject.toml",
				"setup.py",
				"Pipfile",
				"requirements.txt",
				"composer.json",
				"go.mod",
				"Cargo.toml",
				"Makefile",
				".hg",
			},

			-- ADD: prevent project.nvim from treating noise dirs as project roots
			-- (e.g. opening a file inside node_modules won't hijack cwd)
			exclude_dirs = {
				"~/.cargo/*",
				"*/node_modules/*",
				"~/.local/*",
				"~/.rustup/*",
			},

			silent_chdir = true, -- no cwd-changed messages
			scope_chdir = "global", -- single cwd for all windows
			-- NOTE: scope_chdir = "global" and floating_terminal's pick_workdir()
			-- both resolve git root independently — they agree in most cases but
			-- may differ if you open a file outside the current project boundary
		},
		config = function(_, opts)
			require("project_nvim").setup(opts)
			-- Load :Telescope projects picker (safe — pcall guards against load order)
			pcall(require("telescope").load_extension, "projects")
		end,
	},
}
