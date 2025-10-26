-- ==============================
-- lua/config/options.lua
-- ==============================

-- Core UX ---------------------------------------------------------------

vim.opt.number = true                   -- this option turns on absolute line numbers (helps with navigation)
vim.opt.relativenumber = true           -- this option shows relative numbers (quicker jump counts with motions)
vim.opt.cursorline = true               -- this option highlights the current line (helps track the caret)
vim.opt.signcolumn = "yes"              -- this option keeps the sign column visible to avoid text jitter
vim.opt.colorcolumn = ""                -- this option disables a fixed ruler column (we’ll use formatters/linters instead)
vim.opt.wrap = false                    -- this option disables soft wrapping (keeps long lines on one row)
vim.opt.scrolloff = 10                  -- this option keeps N lines above/below the cursor while scrolling
vim.opt.sidescrolloff = 10              -- this option keeps N columns when horizontally scrolling
vim.opt.termguicolors = true            -- this option enables truecolor support in the terminal UI
vim.opt.splitright = true               -- this option opens vertical splits to the right (feels natural for code)
vim.opt.splitbelow = true               -- this option opens horizontal splits below (keeps flow top→bottom)
vim.opt.laststatus = 3                  -- this option uses a global statusline (cleaner layout for multiple windows)
vim.opt.winminwidth = 5                 -- this option prevents windows from shrinking too small
vim.opt.pumheight = 12                  -- this option limits popup menu height (keeps UI tidy)
vim.opt.showmode = false                -- this option hides the mode banner since statusline will show mode
vim.opt.conceallevel = 2                -- this option hides most markup/formatting chars where supported
vim.opt.virtualedit = "block"           -- this option lets the cursor move past end-of-line/into empty space in Visual Block mode 

-- Editing behavior ------------------------------------------------------

vim.opt.expandtab = true                -- this option converts tabs to spaces (standard for most codebases)
vim.opt.shiftwidth = 2                  -- this option sets indentation width when shifting (>> and <<)
vim.opt.tabstop = 2                     -- this option renders a tab character as N spaces
vim.opt.softtabstop = 2                 -- this option makes <BS>/<Tab> feel natural with spaces
vim.opt.smartindent = true              -- this option adds simple smart indentation on new lines
vim.opt.breakindent = true              -- this option visually indents wrapped lines (if wrapping is ever enabled)

vim.opt.undofile = true                 -- this option enables persistent undo across sessions
vim.opt.swapfile = false                -- this option disables swap files (leaner; we rely on undo/history)
vim.opt.backup = false                  -- this option disables backup files (avoid clutter)
vim.opt.writebackup = false             -- this option avoids making a backup before overwriting a file

-- Completion & UI latency -----------------------------------------------

vim.opt.updatetime = 200                -- this option lowers CursorHold/diagnostic delay (snappier LSP UI)
vim.opt.timeoutlen = 400                -- this option controls mapped key timeout (balance speed vs which-key)
vim.opt.completeopt = { "menu", "menuone", "noselect" } -- this option guides completion plugins for good UX
vim.opt.shortmess:append("c")           -- this option reduces completion messages (cleaner cmdline)

-- Search ----------------------------------------------------------------

vim.opt.ignorecase = true               -- this option makes search case-insensitive by default
vim.opt.smartcase = true                -- this option re-enables case-sensitivity if pattern has capitals
vim.opt.incsearch = true                -- this option shows incremental matches while typing a search
vim.opt.hlsearch = true                 -- this option keeps matches highlighted after a search (toggle with :nohl)

-- Files, encoding, clipboard -------------------------------------------

vim.opt.fileencoding = "utf-8"          -- this option ensures UTF-8 file encoding (sane default)
vim.opt.spelllang = { "en" }            -- this option sets the default spelling language (we’ll keep it simple)
vim.opt.clipboard = "unnamedplus"       -- this option uses the system clipboard for all yank/paste operations
vim.opt.mouse = "a"                     -- this option enables mouse support in all modes (handy in terminals)

-- Diagnostics & folds (baseline; Treesitter/LSP will refine) ------------

vim.diagnostic.config({
  underline = true,                     -- this setting underlines problematic text for quick visual hints
  virtual_text = { spacing = 2, prefix = "●" }, -- this setting shows inline virtual text markers for diagnostics
  signs = true,                         -- this setting mirrors diagnostics to the sign column
  update_in_insert = false,             -- this setting avoids noisy diagnostics while typing
  severity_sort = true,                 -- this setting sorts diagnostics by severity (top issues first)
})

vim.opt.foldenable = false              -- this option disables folding by default (we’ll enable per-file when needed)
vim.opt.foldlevel = 99                  -- this option keeps folds open (so Treesitter folds don’t auto-close everything)
vim.opt.foldlevelstart = 99             -- this option starts new buffers with folds open

-- Grep integration (use ripgrep if available) ---------------------------

if vim.fn.executable("rg") == 1 then
  vim.opt.grepprg = "rg --vimgrep --hidden --smart-case" -- this option makes :grep use ripgrep (fast project search)
  vim.opt.grepformat = "%f:%l:%c:%m"                      -- this option formats ripgrep results for quickfix parsing
end

-- Session behavior -------------------------------------------------------

vim.opt.sessionoptions = {              -- this option controls what is saved when making/restoring sessions
  "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp"
}

-- Minor niceties ---------------------------------------------------------

vim.opt.list = false                    -- this option hides invisible chars by default (toggle with :set list!)
vim.opt.listchars = {                   -- this option defines how invisible chars look when list=true
  tab = "» ", trail = "·", extends = "›", precedes = "‹", nbsp = "␣",
}
vim.opt.joinspaces = false              -- this option avoids adding double spaces after punctuation when joining
vim.opt.whichwrap:append("<,>,[,],h,l") -- this option allows arrow keys to wrap across lines at boundaries

-- Neovim 0.10+ niceties (guarded) ---------------------------------------

if vim.fn.has("nvim-0.10") == 1 then
  vim.opt.smoothscroll = true           -- this option enables smoother scrolling for long lines
  pcall(function() vim.opt.splitkeep = "screen" end) -- this option reduces scroll jump when splitting windows
end

-- Platform hints (optional; macOS pbcopy fallback happens via clipboard=unnamedplus) --
-- No extra setup here since unnamedplus covers macOS/Linux/WSL well.

-- End of options ---------------------------------------------------------

