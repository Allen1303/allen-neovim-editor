-- ==============================
-- lua/config/autocmds.lua
-- ==============================
-- GOALS:
-- - Core quality-of-life autocmds that don’t fight plugins
-- - Play nice with transparent UI + our Mini/ToggleTerm/Trouble/DAP stack

local aug = vim.api.nvim_create_augroup("allen_auto_cmd", { clear = true })

-- 1) Highlight on yank (quick visual feedback)
vim.api.nvim_create_autocmd("TextYankPost", {
	group = aug,
	callback = function()
		vim.highlight.on_yank({ higroup = "IncSearch", timeout = 120 })
	end,
	desc = "Show highlight color on yank text",
})

-- 2) Restore last cursor position when reopening a file
vim.api.nvim_create_autocmd("BufReadPost", {
	group = aug,
	callback = function()
		if vim.bo.filetype ~= "gitcommit" and vim.fn.line([['"]]) > 1 and vim.fn.line([['"]]) <= vim.fn.line([[$]]) then
			vim.cmd([[silent! normal! g`"]])
			vim.cmd([[normal! zv]])
		end
	end,
	desc = "Restore cursor to last position",
})

-- 3) Create missing parent directories on save
vim.api.nvim_create_autocmd("BufWritePre", {
	group = aug,
	callback = function()
		local dir = vim.fn.expand([[%:p:h]])
		if vim.fn.isdirectory(dir) == 0 then
			vim.fn.mkdir(dir, "p")
		end
	end,
	desc = "Create parent directory on save",
})

-- 4) Equalize splits when the UI/terminal is resized
vim.api.nvim_create_autocmd("VimResized", {
	group = aug,
	callback = function()
		vim.cmd([[tabdo wincmd =]])
	end,
	desc = "Auto-resize splits on UI resize",
})

-- 5) Autoread when files change on disk (focus/term events)
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
	group = aug,
	callback = function()
		if vim.o.buftype == "" then
			vim.cmd("checktime")
		end
	end,
	desc = "Auto-reload changed files on focus/terminal events",
})

-- 6) Per-language indentation / view tweaks (kept simple)
vim.api.nvim_create_autocmd("FileType", {
	group = aug,
	pattern = {
		"javascript",
		"javascriptreact",
		"typescript",
		"typescriptreact",
		"json",
		"jsonc",
		"html",
		"css",
		"scss",
		"less",
		"lua",
		"yaml",
		"yml",
	},
	callback = function()
		vim.bo.shiftwidth = 4
		vim.bo.tabstop = 4
		vim.bo.expandtab = true
		vim.wo.wrap = false
	end,
	desc = "Web/Lua/YAML: 4-space soft tabs",
})

vim.api.nvim_create_autocmd("FileType", {
	group = aug,
	pattern = { "python" },
	callback = function()
		vim.bo.shiftwidth = 4
		vim.bo.tabstop = 4
		vim.bo.expandtab = true
		vim.wo.colorcolumn = "88"
		vim.wo.wrap = false
	end,
	desc = "Python: 4-space indents, 88-col guide",
})

vim.api.nvim_create_autocmd("FileType", {
	group = aug,
	pattern = { "markdown", "gitcommit" },
	callback = function()
		vim.wo.wrap = true
		vim.wo.linebreak = true
		vim.wo.spell = true
		vim.wo.conceallevel = 2
		vim.bo.shiftwidth = 4
		vim.bo.tabstop = 4
		vim.bo.expandtab = true
	end,
	desc = "Markdown/Git: wrap, linebreak, spell",
})

vim.api.nvim_create_autocmd("FileType", {
	group = aug,
	pattern = { "sh", "bash", "zsh" },
	callback = function()
		vim.bo.shiftwidth = 2
		vim.bo.tabstop = 2
		vim.bo.expandtab = true
		vim.wo.wrap = false
	end,
	desc = "Shell: 2-space indents",
})

vim.api.nvim_create_autocmd("FileType", {
	group = aug,
	pattern = { "make" },
	callback = function()
		vim.bo.expandtab = false
		vim.bo.tabstop = 8
		vim.bo.shiftwidth = 8
		vim.wo.wrap = false
	end,
	desc = "Makefile: hard tabs at width 8",
})

vim.api.nvim_create_autocmd("FileType", {
	group = aug,
	pattern = { "json", "jsonc" },
	callback = function()
		vim.wo.conceallevel = 0
	end,
	desc = "JSON: no conceal",
})

-- 7) Mini IndentScope: turn off in special UIs (prevents guides in panels)
vim.api.nvim_create_autocmd("FileType", {
	group = aug,
	pattern = {
		"help",
		"qf",
		"lspinfo",
		"checkhealth",
		"lazy",
		"mason",
		"minifiles",
		"trouble",
		"dapui_scopes",
		"dapui_breakpoints",
		"dapui_stacks",
		"dapui_watches",
		"dap-repl",
		"toggleterm",
	},
	callback = function()
		vim.b.miniindentscope_disable = true
	end,
	desc = "Disable mini.indentscope in side panels / special buffers",
})

return true
