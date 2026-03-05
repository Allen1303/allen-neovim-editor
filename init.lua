-- ==============================
-- init.lua
-- ==============================
vim.g.mapleader = " "
vim.g.maplocalleader = " "

if vim.fn.has("nvim-0.9") ~= 1 then
	vim.notify("This config targets Neovim ≥ 0.9", vim.log.levels.WARN)
end

-- Core settings (no plugin dependencies)
require("config.options")
require("config.autocmds")
pcall(require, "config.keymaps")

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local uv = vim.uv or vim.loop
if not uv.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"--branch",
		"main",
		"https://github.com/folke/lazy.nvim.git",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	spec = { { import = "plugins" } },
	defaults = { lazy = true, version = false }, -- lazy=true for startup perf
	install = { colorscheme = { "catppuccin", "tokyonight" } },
	checker = { enabled = true, notify = false },
	change_detection = { enabled = true, notify = false },
	performance = {
		rtp = {
			disabled_plugins = {
				"gzip",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
			},
		},
	},
})

-- Load UI/tool modules AFTER plugins are available
require("config.floating_terminal")
require("config.dashboard").setup()
require("config.live-server").setup()
