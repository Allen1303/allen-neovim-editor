-- ==============================
-- lua/plugins/project.lua
-- ==============================
-- - Auto-detect project root (git / common markers)
-- - Integrate with Telescope (project picker)
return {
	{
		"ahmedkhalf/project.nvim", -- this plugin sets cwd using project root patterns
		version = false,
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			detection_methods = { "lsp", "pattern" }, -- this option uses LSP root first, then patterns
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
			}, -- this list covers common project markers
			silent_chdir = true, -- this option avoids noisy messages when cwd changes
			scope_chdir = "global", -- this option uses a single cwd for all windows
		},
		config = function(_, opts)
			require("project_nvim").setup(opts) -- this call enables project root auto-chdir

			-- Telescope integration (optional but handy): :Telescope projects
			pcall(require("telescope").load_extension, "projects")
		end,
	},
}
