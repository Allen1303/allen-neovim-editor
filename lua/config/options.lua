-- ==============================
-- lua/config/options.lua
-- ==============================

-- Core UX ---------------------------------------------------------------

vim.opt.number         = true    -- absolute line numbers
vim.opt.relativenumber = true    -- relative numbers for quick jump counts
vim.opt.cursorline     = true    -- highlight current line
vim.opt.signcolumn     = "yes"   -- keep sign column visible (no jitter)
vim.opt.colorcolumn    = "80"    -- ruler at 80 chars
vim.opt.wrap           = false   -- no soft wrapping
vim.opt.scrolloff      = 10      -- keep N lines above/below cursor
vim.opt.sidescrolloff  = 10      -- keep N columns when scrolling horizontally
vim.opt.termguicolors  = true    -- truecolor support
vim.opt.splitright     = true    -- vertical splits open to the right
vim.opt.splitbelow     = true    -- horizontal splits open below
vim.opt.laststatus     = 3       -- global statusline
vim.opt.winminwidth    = 5       -- minimum window width
vim.opt.pumheight      = 12      -- popup menu max height
vim.opt.showmode       = false   -- hidden — statusline shows mode
vim.opt.conceallevel   = 2       -- hide markup chars where supported
vim.opt.virtualedit    = "block" -- cursor past end-of-line in Visual Block

-- Editing behavior ------------------------------------------------------

vim.opt.expandtab      = true -- tabs → spaces
vim.opt.shiftwidth     = 2   -- indent width
vim.opt.tabstop        = 2   -- tab display width
vim.opt.softtabstop    = 2   -- <BS>/<Tab> feel natural
vim.opt.smartindent    = true -- smart indent on new lines
vim.opt.breakindent    = true -- visually indent wrapped lines

vim.opt.undofile       = true -- persistent undo across sessions
vim.opt.swapfile       = false -- no swap files
vim.opt.backup         = false -- no backup files
vim.opt.writebackup    = false -- no pre-write backup

-- Completion & UI latency -----------------------------------------------

vim.opt.updatetime     = 200                             -- snappier LSP UI
vim.opt.timeoutlen     = 400                             -- mapped key timeout
vim.opt.completeopt    = { "menu", "menuone", "noselect" } -- completion UX
vim.opt.shortmess:append("c")                            -- reduce completion messages

-- Search ----------------------------------------------------------------

vim.opt.ignorecase   = true -- case-insensitive search by default
vim.opt.smartcase    = true -- case-sensitive if pattern has capitals
vim.opt.incsearch    = true -- incremental matches while typing
vim.opt.hlsearch     = true -- keep matches highlighted after search

-- Files, encoding, clipboard -------------------------------------------

vim.opt.fileencoding = "utf-8"
vim.opt.spelllang    = { "en" }
vim.opt.clipboard    = "unnamedplus" -- system clipboard for all yank/paste
vim.opt.mouse        = "a"           -- mouse support in all modes

-- Diagnostics -----------------------------------------------------------

vim.diagnostic.config({
  underline        = true,
  virtual_text     = { spacing = 2, prefix = "●" },
  signs            = true,
  update_in_insert = false,
  severity_sort    = true,
})

-- Folds — disabled by default, treesitter enables per-buffer ------------

vim.opt.foldenable     = false
vim.opt.foldlevel      = 99
vim.opt.foldlevelstart = 99

-- Grep — use ripgrep if available ---------------------------------------

if vim.fn.executable("rg") == 1 then
  vim.opt.grepprg    = "rg --vimgrep --hidden --smart-case"
  vim.opt.grepformat = "%f:%l:%c:%m"
end

-- Session ---------------------------------------------------------------

vim.opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp" }

-- Invisible chars (hidden by default) -----------------------------------

vim.opt.list           = false
vim.opt.listchars      = { tab = "» ", trail = "·", extends = "›", precedes = "‹", nbsp = "␣" }

-- Misc ------------------------------------------------------------------

vim.opt.joinspaces     = false
vim.opt.whichwrap:append("<,>,[,],h,l")
vim.opt.confirm    = true                       -- ask instead of erroring on unsaved changes
vim.opt.inccommand = "nosplit"                  -- live preview for :substitute
vim.opt.spell      = false
vim.opt.formatoptions:remove({ "c", "r", "o" }) -- no auto comment leaders

-- Neovim 0.10+ niceties ------------------------------------------------

if vim.fn.has("nvim-0.10") == 1 then
  vim.opt.smoothscroll = true
  pcall(function() vim.opt.splitkeep = "screen" end)
end

-- Per-project config ----------------------------------------------------

vim.opt.exrc   = true -- auto-load .nvim.lua from project root
vim.opt.secure = true -- sandbox it against malicious repos
