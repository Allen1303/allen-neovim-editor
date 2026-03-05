-- ==============================
-- lua/config/keymaps.lua
-- ==============================
-- NOTE: Leaders are set in init.lua (early) so plugins/mappings see them.

-- Helper: declare keymaps with clear semantics --------------------------
-- this function sets a mapping using (mode, keys, action, desc-or-opts)
local function map(mode, keys, action, opts)
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
map({ "n", "v" }, "<Space>", "<Nop>", "No-op for space in normal/visual modes")

-- Better visual block ergonomics for editing text objects ----------------
map("n", "<leader>v", "<C-v>", "Visual block mode")

-- ╭──────────────────────────────╮
-- │ 1) Quality-of-life basics    │
-- ╰──────────────────────────────╯
-- this block collects common day-to-day actions with clear names

map("n", "<Esc>", "<cmd>nohlsearch<CR>", "Clear search highlight")
map("n", "<leader>w", "<cmd>update<CR>", "File: save (only if modified)")
map("n", "<leader>qq", "<cmd>quit<CR>", "Window: quit") -- FIX: was <leader>q, conflicted with <leader>qo/<leader>qc
map("n", "<leader>Q", "<cmd>qall!<CR>", "Session: quit all (force)")
map("n", "Y", "y$", "Yank to end of line (like D/C)")
map({ "n", "v" }, "<leader>d", '"_d', "Delete without yanking")
map("n", "Q", "<Nop>", "Disable Ex mode")

-- ╭──────────────────────────────╮
-- │ 2) Centered navigation       │
-- ╰──────────────────────────────╯
-- this block keeps the cursor centered after jumps/searches (adds zzzv)

map({ "n", "x", "o" }, "n", "nzzzv", "Next match (centered)")
map({ "n", "x", "o" }, "N", "Nzzzv", "Prev match (centered)")
map("n", "*", "*zzzv", "Search word forward (centered)")
map("n", "#", "#zzzv", "Search word backward (centered)")
map("n", "gg", "ggzz", "Goto top (centered)")
map("n", "G", "Gzz", "Goto end (centered)")
map("n", "<C-d>", "<C-d>zz", "Half page down (centered)")
map("n", "<C-u>", "<C-u>zz", "Half page up (centered)")

-- ╭──────────────────────────────╮
-- │ 3) Move lines up/down        │
-- ╰──────────────────────────────╯
-- this block reorders lines/blocks with Alt-j/k across modes

map("n", "<A-j>", "<cmd>m .+1<CR>==", "Move line down")
map("n", "<A-k>", "<cmd>m .-2<CR>==", "Move line up")
map("i", "<A-j>", "<Esc><cmd>m .+1<CR>==gi", "Move line down (insert)")
map("i", "<A-k>", "<Esc><cmd>m .-2<CR>==gi", "Move line up (insert)")
map("v", "<A-j>", ":m '>+1<CR>gv=gv", "Move selection down")
map("v", "<A-k>", ":m '<-2<CR>gv=gv", "Move selection up")

-- Keep visual selection when indenting
map("v", "<", "<gv", "Indent left (keep selection)")
map("v", ">", ">gv", "Indent right (keep selection)")

-- Better paste in visual mode (replace without yanking the replaced text)
map("x", "<leader>p", [["_dP]], "Paste without yanking")

-- ╭──────────────────────────────╮
-- │ 4) Windows & splits          │
-- ╰──────────────────────────────╯
-- this block mirrors common IDE/tmux navigation & split management

map("n", "<C-h>", "<C-w>h", "Focus left window")
map("n", "<C-j>", "<C-w>j", "Focus lower window")
map("n", "<C-k>", "<C-w>k", "Focus upper window")
map("n", "<C-l>", "<C-w>l", "Focus right window")

map("n", "<leader>sv", "<cmd>vsplit<CR>", "Split: vertical")
map("n", "<leader>sh", "<cmd>split<CR>", "Split: horizontal")
map("n", "<leader>se", "<C-w>=", "Split: equalize")
map("n", "<leader>sx", "<cmd>close<CR>", "Split: close")

-- Window resizing with arrows
map("n", "<C-Up>", "<cmd>resize +2<CR>", "Window: increase height")
map("n", "<C-Down>", "<cmd>resize -2<CR>", "Window: decrease height")
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", "Window: decrease width")
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", "Window: increase width")

-- ╭──────────────────────────────╮
-- │ 5) Buffers                   │
-- ╰──────────────────────────────╯
-- this block navigates and manages open buffers (files in memory)

map("n", "<leader>bn", "<cmd>bnext<CR>", "Buffer: next")
map("n", "<leader>bp", "<cmd>bprevious<CR>", "Buffer: previous")
map("n", "<leader>bd", "<cmd>bdelete<CR>", "Buffer: delete")
map("n", "<leader>ba", "<cmd>bufdo bd<CR>", "Buffer: delete all")
map("n", "<leader>bl", "<cmd>ls<CR>", "Buffer: list")

-- ╭──────────────────────────────╮
-- │ 6) Built-in file explorer    │
-- ╰──────────────────────────────╯
-- NOTE: netrw vim.g settings live in options.lua (config only, no mappings)
-- Toggle is commented out; mini.files or telescope handles file browsing

-- local function toggle_file_explorer()
--   local is_netrw = (vim.bo.filetype == "netrw")
--   if is_netrw then
--     vim.cmd("quit")
--   else
--     vim.cmd("Vexplore")
--   end
-- end
-- map("n", "<leader>e", toggle_file_explorer, "Toggle file explorer")

-- ╭──────────────────────────────╮
-- │ 7) Search & Replace          │
-- ╰──────────────────────────────╯
-- this block adds ergonomic search/replace helpers

map("n", "<leader>ch", "<cmd>nohlsearch<CR>", "Clear search highlights")

-- this mapping prepares a project-wide replace for the word under cursor
map( -- FIX: was <leader>s, conflicted with <leader>sv/<leader>sh
	"n",
	"<leader>sr",
	[[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
	"Search & replace word under cursor"
)

-- this mapping prepares a selection-limited replace (visual range only)
map("v", "<leader>sr", [[:s/\%V]], "Search & replace in selection") -- FIX: was <leader>s

-- ╭──────────────────────────────╮
-- │ 8) Quickfix list             │
-- ╰──────────────────────────────╯
-- this block navigates error lists and grep results via the quickfix list

map("n", "<leader>qo", "<cmd>copen<CR>", "Quickfix: open")
map("n", "<leader>qc", "<cmd>cclose<CR>", "Quickfix: close")
map("n", "[q", "<cmd>cprevious<CR>", "Quickfix: previous item")
map("n", "]q", "<cmd>cnext<CR>", "Quickfix: next item")

-- ╭──────────────────────────────╮
-- │ 9) Location list             │
-- ╰──────────────────────────────╯
-- this block navigates per-window location lists (LSP-safe namespace <leader>x)

map("n", "<leader>xo", "<cmd>lopen<CR>", "Location list: open") -- FIX: was <leader>lo, conflicts with LSP <leader>l namespace
map("n", "<leader>xc", "<cmd>lclose<CR>", "Location list: close") -- FIX: was <leader>lc
map("n", "[l", "<cmd>lprevious<CR>", "Location list: previous item")
map("n", "]l", "<cmd>lnext<CR>", "Location list: next item")

-- ╭──────────────────────────────╮
-- │ 10) Diagnostics              │
-- ╰──────────────────────────────╯
-- this block navigates LSP diagnostics (errors, warnings, hints)

map("n", "[d", function()
	vim.diagnostic.jump({ count = -1, float = true })
end, "Diagnostic: previous")
map("n", "]d", function()
	vim.diagnostic.jump({ count = 1, float = true })
end, "Diagnostic: next")

map("n", "<leader>xd", vim.diagnostic.open_float, "Diagnostic: show float") -- ADD: was missing
map("n", "<leader>xq", vim.diagnostic.setloclist, "Diagnostic: send to location list")

-- ╭──────────────────────────────╮
-- │ 11) File path utilities      │
-- ╰──────────────────────────────╯
-- this block copies various path forms to the system clipboard
-- FIX: moved from <leader>c prefix (reserved for LSP code actions) to <leader>y (yank)

map("n", "<leader>yp", function()
	local path = vim.fn.expand("%:p")
	vim.fn.setreg("+", path)
	vim.notify("Copied full path: " .. path)
end, "Yank: full file path")

map("n", "<leader>yr", function()
	local path = vim.fn.expand("%:.")
	vim.fn.setreg("+", path)
	vim.notify("Copied relative path: " .. path)
end, "Yank: relative file path")

map("n", "<leader>yn", function()
	local name = vim.fn.expand("%:t")
	vim.fn.setreg("+", name)
	vim.notify("Copied filename: " .. name)
end, "Yank: filename only")

map("n", "<leader>yd", function()
	local dir = vim.fn.expand("%:p:h")
	vim.fn.setreg("+", dir)
	vim.notify("Copied directory: " .. dir)
end, "Yank: file directory")

-- ╭──────────────────────────────╮
-- │ 12) Misc ergonomics          │
-- ╰──────────────────────────────╯
-- this block smooths out movement and joins without losing position

-- make j/k respect wrapped lines when no count (expr mapping)
map("n", "j", [[v:count == 0 ? 'gj' : 'j']], { expr = true, desc = "Move down (respect wraps)" })
map("n", "k", [[v:count == 0 ? 'gk' : 'k']], { expr = true, desc = "Move up (respect wraps)" })

-- join lines but keep cursor location stable
map("n", "J", "mzJ`z", "Join lines (keep cursor position)")

-- select-all convenience
map("n", "<leader>a", "ggVG", "Select all")

-- ╭──────────────────────────────╮
-- │ 13) Noice UI                 │
-- ╰──────────────────────────────╯
-- this block controls Noice message display (requires noice.nvim)

map("n", "<leader>nd", "<cmd>NoiceDismiss<CR>", "Noice: dismiss messages")
map("n", "<leader>nh", "<cmd>NoiceHistory<CR>", "Noice: show history")
