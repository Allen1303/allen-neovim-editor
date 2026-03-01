-- ==============================
-- lua/config/keymaps.lua
-- ==============================
-- NOTE: Leaders are set in init.lua (early) so plugins/mappings see them.

-- Helper: declare keymaps with clear semantics --------------------------
-- this function sets a mapping using (mode, keys, action, desc-or-opts)
local function set_keymaps(mode, keys, action, opts)
	-- this block allows passing a plain string as description
	if type(opts) == "string" then
		opts = { desc = opts }
	end
	-- this variable holds default mapping options (non-recursive + silent)
	local defaults = { noremap = true, silent = true }
	-- this call merges user opts into defaults (force = user wins on conflicts)
	local merged = vim.tbl_extend("force", defaults, opts or {})
	-- this call handles single mode string or a table of modes
	vim.keymap.set(mode, keys, action, merged)
end

-- Prevent accidental <Space> from doing anything in Normal/Visual --------
set_keymaps({ "n", "v" }, "<Space>", "<Nop>", "No-op for space in normal/visual modes")

-- Better visual Block ergonomics for editing text objetcs
set_keymaps("n", "<leader>v", "<C-v>", "Visual block mode")
-- ╭──────────────────────────────╮
-- │ 1) Quality-of-life basics    │
-- ╰──────────────────────────────╯
-- this block collects common day-to-day actions with clear names

set_keymaps("n", "<Esc>", "<cmd>nohlsearch<CR>", "Clear search highlight")
set_keymaps("n", "<leader>w", "<cmd>update<CR>", "File save (only if modified)")
set_keymaps("n", "<leader>q", "<cmd>quit<CR>", "Window: quit")
set_keymaps("n", "<leader>Q", "<cmd>qall!<CR>", "Session: quit all (force)")
set_keymaps("n", "Y", "y$", "Yank to end of line (like D/C)")
set_keymaps({ "n", "v" }, "<leader>d", '"_d', "Delete without yanking")
set_keymaps("n", "Q", "<Nop>", "Disable Ex mode")

-- ╭──────────────────────────────╮
-- │ 2) Centered navigation       │
-- ╰──────────────────────────────╯
-- this block keeps the cursor centered after jumps/searches (adds zzzv)

set_keymaps({ "n", "x", "o" }, "n", "nzzzv", "Next match (centered)")
set_keymaps({ "n", "x", "o" }, "N", "Nzzzv", "Prev match (centered)")
set_keymaps("n", "*", "*zzzv", "Search word forward (centered)")
set_keymaps("n", "#", "#zzzv", "Search word backward (centered)")
set_keymaps("n", "gg", "ggzz", "Goto top (centered)")
set_keymaps("n", "G", "Gzz", "Goto end (centered)")
set_keymaps("n", "<C-d>", "<C-d>zz", "Half page down (centered)")
set_keymaps("n", "<C-u>", "<C-u>zz", "Half page up (centered)")

-- ╭──────────────────────────────╮
-- │ 3) Move lines up/down        │
-- ╰──────────────────────────────╯
-- this block reorders lines/blocks with Alt-j/k across modes

set_keymaps("n", "<A-j>", "<cmd>m .+1<CR>==", "Move line down")
set_keymaps("n", "<A-k>", "<cmd>m .-2<CR>==", "Move line up")
set_keymaps("i", "<A-j>", "<Esc><cmd>m .+1<CR>==gi", "Move line down (insert)")
set_keymaps("i", "<A-k>", "<Esc><cmd>m .-2<CR>==gi", "Move line up (insert)")
set_keymaps("v", "<A-j>", ":m '>+1<CR>gv=gv", "Move selection down")
set_keymaps("v", "<A-k>", ":m '<-2<CR>gv=gv", "Move selection up")

-- Keep visual selection when indenting
set_keymaps("v", "<", "<gv", "Indent left (keep selection)")
set_keymaps("v", ">", ">gv", "Indent right (keep selection)")

-- Better paste in visual mode (replace without yanking the replaced text)
set_keymaps("x", "<leader>p", [["_dP]], "Paste without yanking")

-- ╭──────────────────────────────╮
-- │ 4) Windows & splits          │
-- ╰──────────────────────────────╯
-- this block mirrors common IDE/tmux navigation & split management

set_keymaps("n", "<C-h>", "<C-w>h", "Focus left window")
set_keymaps("n", "<C-j>", "<C-w>j", "Focus lower window")
set_keymaps("n", "<C-k>", "<C-w>k", "Focus upper window")
set_keymaps("n", "<C-l>", "<C-w>l", "Focus right window")

set_keymaps("n", "<leader>sv", "<cmd>vsplit<CR>", "Vertical split")
set_keymaps("n", "<leader>sh", "<cmd>split<CR>", "Horizontal split")
set_keymaps("n", "<leader>se", "<C-w>=", "Equalize splits")
set_keymaps("n", "<leader>sx", "<cmd>close<CR>", "Close split")

-- Window resizing with arrows
set_keymaps("n", "<C-Up>", "<cmd>resize +2<CR>", "Increase window height")
set_keymaps("n", "<C-Down>", "<cmd>resize -2<CR>", "Decrease window height")
set_keymaps("n", "<C-Left>", "<cmd>vertical resize -2<CR>", "Decrease window width")
set_keymaps("n", "<C-Right>", "<cmd>vertical resize +2<CR>", "Increase window width")

-- ╭──────────────────────────────╮
-- │ 5) Buffers                   │
-- ╰──────────────────────────────╯
-- this block navigates and manages open buffers (files in memory)

set_keymaps("n", "<leader>bn", "<cmd>bnext<CR>", "Next buffer")
set_keymaps("n", "<leader>bp", "<cmd>bprevious<CR>", "Previous buffer")
set_keymaps("n", "<leader>bd", "<cmd>bdelete<CR>", "Delete buffer")
set_keymaps("n", "<leader>ba", "<cmd>bufdo bd<CR>", "Delete all buffers")
set_keymaps("n", "<leader>bl", "<cmd>ls<CR>", "List buffers")

-- ╭──────────────────────────────╮
-- │ 7) Built-in file explorer    │
-- ╰──────────────────────────────╯
-- this block toggles netrw (built-in) on the right as a minimal explorer

vim.g.netrw_banner = 0 -- this variable hides the netrw banner for a cleaner look
vim.g.netrw_liststyle = 3 -- this variable uses a tree view style
vim.g.netrw_winsize = 30 -- this variable sets the explorer width
vim.g.netrw_browse_split = 0 -- this variable opens files in the current window by default
vim.g.netrw_altv = 1 -- this variable moves vertical splits to the right side

-- this function toggles a right-side netrw explorer window
-- local function toggle_file_explorer()
--   local is_netrw = (vim.bo.filetype == "netrw")
--   if is_netrw then
--     vim.cmd("quit")                     -- this command closes the explorer window
--   else
--     vim.cmd("Vexplore")                 -- this command opens the explorer in a vertical split (right side)
--   end
-- end

-- set_keymaps("n", "<leader>e", toggle_file_explorer, "Toggle file explorer (right)")

-- ╭──────────────────────────────╮
-- │ 8) Search & Replace          │
-- ╰──────────────────────────────╯
-- this block adds ergonomic search/replace helpers

set_keymaps("n", "<leader>ch", "<cmd>nohlsearch<CR>", "Clear search highlights")

-- this mapping prepares a project-wide replace for the word under cursor
set_keymaps(
	"n",
	"<leader>s",
	[[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
	"Search & replace word under cursor"
)

-- this mapping prepares a selection-limited replace (visual range only)
set_keymaps("v", "<leader>s", [[:s/\%V]], "Search & replace in selection")

-- ╭──────────────────────────────╮
-- │ 9) Quickfix & Location       │
-- ╰──────────────────────────────╯
-- this block navigates error lists, grep results, and location lists

set_keymaps("n", "<leader>qo", "<cmd>copen<CR>", "Open quickfix list")
set_keymaps("n", "<leader>qc", "<cmd>cclose<CR>", "Close quickfix list")
set_keymaps("n", "[q", "<cmd>cprevious<CR>", "Previous quickfix item")
set_keymaps("n", "]q", "<cmd>cnext<CR>", "Next quickfix item")

set_keymaps("n", "<leader>lo", "<cmd>lopen<CR>", "Open location list")
set_keymaps("n", "<leader>lc", "<cmd>lclose<CR>", "Close location list")
set_keymaps("n", "[l", "<cmd>lprevious<CR>", "Previous location item")
set_keymaps("n", "]l", "<cmd>lnext<CR>", "Next location item")

-- ╭──────────────────────────────╮
-- │ 10) File path utilities      │
-- ╰──────────────────────────────╯
-- this block copies various path forms to the system clipboard

set_keymaps("n", "<leader>cf", function()
	local path = vim.fn.expand("%:p")
	vim.fn.setreg("+", path)
	vim.notify("Copied full path: " .. path)
end, "Copy full file path")

set_keymaps("n", "<leader>cr", function()
	local path = vim.fn.expand("%:.")
	vim.fn.setreg("+", path)
	vim.notify("Copied relative path: " .. path)
end, "Copy relative file path")

set_keymaps("n", "<leader>cn", function()
	local name = vim.fn.expand("%:t")
	vim.fn.setreg("+", name)
	vim.notify("Copied filename: " .. name)
end, "Copy filename only")

set_keymaps("n", "<leader>cd", function()
	local dir = vim.fn.expand("%:p:h")
	vim.fn.setreg("+", dir)
	vim.notify("Copied directory: " .. dir)
end, "Copy file directory")

-- ╭──────────────────────────────╮
-- │ 11) Misc ergonomics          │
-- ╰──────────────────────────────╯
-- this block smooths out movement and joins without losing position

-- make j/k respect wrapped lines when no count (expr mapping)
set_keymaps("n", "j", [[v:count == 0 ? 'gj' : 'j']], { expr = true, desc = "Move down (respect wraps)" })
set_keymaps("n", "k", [[v:count == 0 ? 'gk' : 'k']], { expr = true, desc = "Move up (respect wraps)" })

-- allow left/right to wrap to previous/next line at boundaries
vim.opt.whichwrap:append("<,>,[,],h,l")

-- join lines but keep cursor location stable
set_keymaps("n", "J", "mzJ`z", "Join lines (keep cursor position)")

-- select-all convenience
set_keymaps("n", "<leader>a", "ggVG", "Select all")

-- Dismiss Noice messages
set_keymaps("n", "<leader>nd", "<cmd>NoiceDismiss<CR>", "Dismiss Noice messages")

-- Show message history
set_keymaps("n", "<leader>nh", "<cmd>NoiceHistory<CR>", "Show message history")
-- Return truthy for module load check
return true
