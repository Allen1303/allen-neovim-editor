-- ==============================
-- lua/plugins/telescope.lua
-- ==============================

return {
	{
		"nvim-telescope/telescope.nvim",
		-- FIX: tag → version, more idiomatic and consistent with rest of config
		version = "0.1.8",
		dependencies = {
			"nvim-lua/plenary.nvim",
			-- ADD: native fzf sorter — massive performance improvement on large projects
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		},
		-- Telescope loads when a keymap is triggered or :Telescope is typed
		cmd = "Telescope",
		keys = {
			-- ── Core pickers ───────────────────────────────────────────
			{
				"<leader>ff",
				function()
					require("telescope.builtin").find_files()
				end,
				desc = "Telescope: find files",
			},
			{
				"<leader>fg",
				function()
					require("telescope.builtin").live_grep()
				end,
				desc = "Telescope: live grep",
			},
			{
				"<leader>fb",
				function()
					require("telescope.builtin").buffers()
				end,
				desc = "Telescope: buffers",
			},
			{
				"<leader>fh",
				function()
					require("telescope.builtin").help_tags()
				end,
				desc = "Telescope: help tags",
			},

			-- ADD: recent files, commands, dashboard, projects
			{
				"<leader>fr",
				function()
					require("telescope.builtin").oldfiles()
				end,
				desc = "Telescope: recent files",
			},
			{
				"<leader>fc",
				function()
					require("telescope.builtin").commands()
				end,
				desc = "Telescope: commands",
			},
			{
				"<leader>fd",
				"<cmd>Dashboard<CR>",
				desc = "Open dashboard",
			},
			{
				"<leader>fp",
				function()
					require("telescope").extensions.projects.projects()
				end,
				desc = "Telescope: projects",
			},
			{
				"<leader>fC",
				function()
					require("telescope.builtin").colorscheme()
				end,
				desc = "Telescope: colorschemes (live preview)",
			},

			-- ADD: git pickers (complement gitsigns buffer-local keymaps)
			{
				"<leader>gf",
				function()
					require("telescope.builtin").git_status()
				end,
				desc = "Git: status (telescope)",
			},
			{
				"<leader>gc",
				function()
					require("telescope.builtin").git_commits()
				end,
				desc = "Git: commits (telescope)",
			},
		},

		opts = {
			defaults = {
				sorting_strategy = "ascending",
				layout_strategy = "horizontal",
				layout_config = {
					prompt_position = "top",
					width = 0.80,
					height = 0.70,
					preview_width = 0.50,
				},
				winblend = 0,

				-- ADD: ignore noise directories in all pickers
				file_ignore_patterns = {
					"node_modules/",
					".git/",
					"dist/",
					"build/",
					"%.lock",
					"lazy%-lock%.json",
				},

				-- ADD: ergonomic insert-mode mappings
				-- <C-j>/<C-k> navigate results (muscle memory from vim)
				-- <C-u>/<C-d> scroll preview (consistent with editor scroll)
				-- <Esc> closes without switching to normal mode first
				mappings = {
					i = {
						["<C-j>"] = "move_selection_next",
						["<C-k>"] = "move_selection_previous",
						["<C-u>"] = "preview_scrolling_up",
						["<C-d>"] = "preview_scrolling_down",
						["<Esc>"] = { "<Esc>", type = "command" }, -- exit insert, stay in picker
					},
					n = {
						["q"] = "close", -- q to fully close from normal mode
						["<Esc>"] = "close", -- Esc also closes from normal mode
					},
				},
			},
		},

		config = function(_, opts)
			local telescope = require("telescope")

			-- Colorscheme picker: preview themes as you move through the list.
			-- Lazy-loaded themes are missing from getcompletion("", "color") until
			-- they load, so list every installed plugin's colors/ files up front.
			local function installed_colorschemes()
				local names = {}
				for _, plugin in pairs(require("lazy.core.config").plugins) do
					for _, file in ipairs(vim.fn.glob(plugin.dir .. "/colors/*.{lua,vim}", false, true)) do
						table.insert(names, vim.fn.fnamemodify(file, ":t:r"))
					end
				end
				table.sort(names)
				return names
			end

			opts.pickers = opts.pickers or {}
			opts.pickers.colorscheme = {
				enable_preview = true,
				colors = installed_colorschemes(),
			}

			telescope.setup(opts)

			-- ADD: load fzf native sorter for faster fuzzy matching
			pcall(telescope.load_extension, "fzf")

			-- Load projects extension (registered by project.nvim on VeryLazy)
			pcall(telescope.load_extension, "projects")

			-- Transparency: keep all telescope windows bg-free
			-- FIX: was nvim_exec_autocmds("ColorScheme") — fired all listeners
			-- Extracted to a function and called directly instead
			local function apply_telescope_transparent()
				local set = vim.api.nvim_set_hl
				set(0, "TelescopeNormal", { bg = "NONE" })
				set(0, "TelescopeBorder", { bg = "NONE" })
				set(0, "TelescopePromptNormal", { bg = "NONE" })
				set(0, "TelescopePromptBorder", { bg = "NONE" })
				set(0, "TelescopeResultsNormal", { bg = "NONE" })
				set(0, "TelescopeResultsBorder", { bg = "NONE" })
				set(0, "TelescopePreviewNormal", { bg = "NONE" })
				set(0, "TelescopePreviewBorder", { bg = "NONE" })
			end

			vim.api.nvim_create_autocmd("ColorScheme", {
				group = vim.api.nvim_create_augroup("Allen_Telescope_Transparent", { clear = true }),
				callback = apply_telescope_transparent,
			})

			-- Apply immediately on first load
			apply_telescope_transparent()
		end,
	},
}
