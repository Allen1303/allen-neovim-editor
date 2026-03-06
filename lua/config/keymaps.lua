-- ==============================
-- lua/config/keymaps.lua
-- ==============================
-- NOTE: Leaders are set in init.lua (early) so plugins/mappings see them.

-- Helper: declare keymaps with clear semantics --------------------------
local function map(mode, keys, action, opts)
	if type(opts) == "string" then
		opts = { desc = opts }
	end
	local defaults = { noremap = true, silent = true }
	local merged = vim.tbl_extend("force", defaults, opts or {})
	vim.keymap.set(mode, keys, action, merged)
end

-- Prevent accidental <Space> from doing anything in Normal/Visual -------
map({ "n", "v" }, "<Space>", "<Nop>", "No-op for space in normal/visual modes")

-- Better visual block ergonomics ----------------------------------------
map("n", "<leader>v", "<C-v>", "Visual block mode")

-- ╭──────────────────────────────╮
-- │ 1) Quality-of-life basics    │
-- ╰──────────────────────────────╯

map("n", "<Esc>", "<cmd>nohlsearch<CR>", "Clear search highlight")
map("n", "<leader>w", "<cmd>update<CR>", "File: save (only if modified)")
map("n", "<leader>qq", "<cmd>quit<CR>", "Window: quit")
map("n", "<leader>qQ", "<cmd>qall!<CR>", "Session: quit all (force)")
map("n", "Y", "y$", "Yank to end of line (like D/C)")

-- FIX: was <leader>d — conflicts with <leader>d DAP namespace
-- Changed to <leader>D for delete without yanking
map({ "n", "v" }, "<leader>D", '"_d', "Delete without yanking")

map("n", "Q", "<Nop>", "Disable Ex mode")

-- ╭──────────────────────────────╮
-- │ 2) Centered navigation       │
-- ╰──────────────────────────────╯

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

map("n", "<A-j>", "<cmd>m .+1<CR>==", "Move line down")
map("n", "<A-k>", "<cmd>m .-2<CR>==", "Move line up")
map("i", "<A-j>", "<Esc><cmd>m .+1<CR>==gi", "Move line down (insert)")
map("i", "<A-k>", "<Esc><cmd>m .-2<CR>==gi", "Move line up (insert)")
map("v", "<A-j>", ":m '>+1<CR>gv=gv", "Move selection down")
map("v", "<A-k>", ":m '<-2<CR>gv=gv", "Move selection up")

-- Keep visual selection when indenting
map("v", "<", "<gv", "Indent left (keep selection)")
map("v", ">", ">gv", "Indent right (keep selection)")

-- Better paste in visual mode
map("x", "<leader>p", [["_dP]], "Paste without yanking")

-- ╭──────────────────────────────╮
-- │ 4) Windows & splits          │
-- ╰──────────────────────────────╯

map("n", "<C-h>", "<C-w>h", "Focus left window")
map("n", "<C-j>", "<C-w>j", "Focus lower window")
map("n", "<C-k>", "<C-w>k", "Focus upper window")
map("n", "<C-l>", "<C-w>l", "Focus right window")

map("n", "<leader>sv", "<cmd>vsplit<CR>", "Split: vertical")
map("n", "<leader>sh", "<cmd>split<CR>", "Split: horizontal")
map("n", "<leader>se", "<C-w>=", "Split: equalize")
map("n", "<leader>sx", "<cmd>close<CR>", "Split: close")

-- FIX: was <C-Arrow> — intercepted by macOS Mission Control
-- Changed to <leader><Arrow> which works reliably on macOS
map("n", "<leader><Up>", "<cmd>resize +2<CR>", "Window: increase height")
map("n", "<leader><Down>", "<cmd>resize -2<CR>", "Window: decrease height")
map("n", "<leader><Left>", "<cmd>vertical resize -2<CR>", "Window: decrease width")
map("n", "<leader><Right>", "<cmd>vertical resize +2<CR>", "Window: increase width")

-- ╭──────────────────────────────╮
-- │ 5) Buffers                   │
-- ╰──────────────────────────────╯
-- NOTE: buffer cycling handled by bufferline (<S-h>/<S-l> and [b/]b)
-- NOTE: buffer close/pin handled by bufferline (<leader>bp/bo/br/bl)
-- Only keeping delete-all here as bufferline doesn't have that

map("n", "<leader>ba", "<cmd>bufdo bd<CR>", "Buffer: delete all")

-- ╭──────────────────────────────╮
-- │ 6) Search & Replace          │
-- ╰──────────────────────────────╯

-- FIX: removed duplicate <leader>ch (same as <Esc> nohlsearch above)

map("n", "<leader>sr", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], "Search & replace word under cursor")

map("v", "<leader>sr", [[:s/\%V]], "Search & replace in selection")

-- ╭──────────────────────────────╮
-- │ 7) Quickfix list             │
-- ╰──────────────────────────────╯

map("n", "<leader>qo", "<cmd>copen<CR>", "Quickfix: open")
map("n", "<leader>qc", "<cmd>cclose<CR>", "Quickfix: close")
map("n", "[q", "<cmd>cprevious<CR>", "Quickfix: previous item")
map("n", "]q", "<cmd>cnext<CR>", "Quickfix: next item")

-- ╭──────────────────────────────╮
-- │ 8) Location list             │
-- ╰──────────────────────────────╯

map("n", "<leader>xo", "<cmd>lopen<CR>", "Location list: open")
map("n", "<leader>xc", "<cmd>lclose<CR>", "Location list: close")
map("n", "[l", "<cmd>lprevious<CR>", "Location list: previous item")
map("n", "]l", "<cmd>lnext<CR>", "Location list: next item")

-- ╭──────────────────────────────╮
-- │ 9) Diagnostics               │
-- ╰──────────────────────────────╯
-- FIX: removed <leader>xd and <leader>xq — both defined in lsp-config on_attach
-- FIX: removed [d/]d — defined in lsp-config on_attach
-- Keeping here as fallback for buffers without LSP attached

map("n", "[d", function()
	vim.diagnostic.jump({ count = -1, float = true })
end, "Diagnostic: previous")

map("n", "]d", function()
	vim.diagnostic.jump({ count = 1, float = true })
end, "Diagnostic: next")

-- ╭──────────────────────────────╮
-- │ 10) File path utilities      │
-- ╰──────────────────────────────╯

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
-- │ 11) Misc ergonomics          │
-- ╰──────────────────────────────╯

-- j/k respect wrapped lines
map("n", "j", [[v:count == 0 ? 'gj' : 'j']], { expr = true, desc = "Move down (respect wraps)" })
map("n", "k", [[v:count == 0 ? 'gk' : 'k']], { expr = true, desc = "Move up (respect wraps)" })

-- Join lines keeping cursor position
map("n", "J", "mzJ`z", "Join lines (keep cursor position)")

-- Select all
map("n", "<leader>a", "ggVG", "Select all")

-- ╭──────────────────────────────╮
-- │ 12) Noice UI                 │
-- ╰──────────────────────────────╯

map("n", "<leader>nd", "<cmd>NoiceDismiss<CR>", "Noice: dismiss messages")
map("n", "<leader>nh", "<cmd>NoiceHistory<CR>", "Noice: show history")
