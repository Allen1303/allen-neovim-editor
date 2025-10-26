-- ==============================
-- init.lua
-- ==============================

-- Set leaders early so all keymaps/plugins see them
vim.g.mapleader = " " -- this variable sets <Leader> to space (used by many mappings)
vim.g.maplocalleader = " " -- we use this variable to mirror the same for local mappings

-- Light sanity check on version (optional, non-fatal)
if vim.fn.has("nvim-0.9") ~= 1 then
	vim.notify("This config targets Neovim ≥ 0.9 for best results.", vim.log.levels.WARN)
end

-- Load core settings before plugins.
require("config.options") -- this file sets editor options (number, tabs, splits, etc.)
pcall(require, "config.keymaps") -- this tries to load keymaps
require("config.autocmds")
-- Floating terminal (native)
require("config.floating_terminal")

-- Bootstrap lazy.nvim (package manager)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim" -- this variable holds the install path for lazy.nvim
local uv = vim.uv or vim.loop -- we use this variable to support both 0.10 (uv) and older (loop)
if not uv.fs_stat(lazypath) then -- this condition checks if lazy is missing
	vim.fn.system({ -- this function does a shallow clone of lazy.nvim (stable branch)
		"git",
		"clone",
		"--filter=blob:none",
		"--single-branch",
		"https://github.com/folke/lazy.nvim.git",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath) -- this line adds lazy.nvim to runtimepath so we can require it

-- Configure lazy to import every plugin spec from lua/plugins/*
require("lazy").setup({
	spec = { { import = "plugins" } }, -- this tells lazy to merge all specs from lua/plugins/*.lua
	defaults = { lazy = false, version = nil }, -- we use this to load plugins on startup and track latest commits
	install = { colorscheme = { "catppuccin", "tokyonight", "gruvbox", "rose-pine" } }, -- this gives a fallback scheme if none is set
	checker = { enabled = true, notify = false }, -- this enables background plugin update checks (quiet)
	change_detection = { enabled = true, notify = false }, -- this auto-applies spec changes (handy while editing)
	performance = {
		rtp = {
			disabled_plugins = { -- this table lists built-ins we don’t need (faster startup)
				"gzip",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
			},
		},
	},
})

-- (Optional) Very small quality-of-life autocommand
-- vim.api.nvim_create_autocmd("TextYankPost", { -- this autocommand highlights yanked text for quick feedback
-- 	desc = "Briefly highlight on yank",
-- 	callback = function()
-- 		vim.highlight.on_yank()
-- 	end,
-- })
