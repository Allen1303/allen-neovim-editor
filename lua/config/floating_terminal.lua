-- ╭──────────────────────────────────────────────────────────────────────────╮
-- │ Floating Terminal | lua/config/floating_terminal.lua                     │
-- ╰──────────────────────────────────────────────────────────────────────────╯
-- WHAT: Plugin-free floating terminal + “run code” workflow (VS Code–style).
-- WHY : Run current file / line / selection neatly; keep vim motions in term.
-- NOTE: We auto-cd to the project root (git root if present) before runs.
local M = {}

-- ── User options ───────────────────────────────────────────────────────────
M.config = {
	path_style = "relative", -- "name" | "relative" | "full" (header label style)
	run_path = "relative", -- "relative" | "full"   (path used in the shell command)
	show_cwd = false, -- print cwd line in the header when true
	suppress_command_echo = true, -- keep only program output visible (no raw command)

	layouts = {
		float = { width = 0.80, height = 0.80, anchor = "center" }, -- big centered toggle
		run = { width = 0.55, height = 0.40, anchor = "right", right_margin = 5 }, -- smaller right-anchored run
	},
}

-- ── Module state ───────────────────────────────────────────────────────────
local term_buf ---@type integer|nil  -- terminal buffer handle
local term_win ---@type integer|nil  -- terminal window handle
local prev_win ---@type integer|nil  -- window we came from
local last_cmd ---@type string|nil   -- last executed shell command
local last_workdir ---@type string|nil   -- working directory of last_cmd
local current_layout_key = "float" -- active layout ("float"|"run")

-- ── Paths, runners & workdir helpers ───────────────────────────────────────
local function first_exe(list)
	-- this function returns the first executable in $PATH from a list
	for _, exe in ipairs(list) do
		if vim.fn.executable(exe) == 1 then
			return exe
		end
	end
end

local function build_run_cmd(ft, abs_path)
	-- this function builds a shell command to run a file by its filetype
	local use_rel = (M.config.run_path == "relative")
	local shell_path = use_rel and vim.fn.fnamemodify(abs_path, ":.") or abs_path
	local escaped = vim.fn.fnameescape(shell_path)

	if ft == "javascript" then
		local exe = first_exe({ "bun", "node" }) or "node"
		return exe .. " " .. escaped
	elseif ft == "typescript" then
		local exe = first_exe({ "tsx", "bunx", "ts-node", "node" }) or "node"
		if exe == "tsx" then
			return "tsx " .. escaped
		elseif exe == "bunx" then
			return "bunx tsx " .. escaped
		elseif exe == "ts-node" then
			return "ts-node " .. escaped
		else
			return "node " .. escaped
		end
	elseif ft == "python" then
		return (first_exe({ "python3", "python" }) or "python3") .. " " .. escaped
	elseif ft == "lua" then
		return "lua " .. escaped
	elseif ft == "go" then
		return "go run " .. escaped
	elseif ft == "ruby" then
		return "ruby " .. escaped
	elseif ft == "sh" or ft == "bash" or ft == "zsh" then
		local exe = first_exe({ ft, "bash", "sh", "zsh" }) or "bash"
		return exe .. " " .. escaped
	end
	return nil
end

local function pick_workdir(abs_path)
	-- this function returns the git root for a file, else the file’s directory
	local dir = vim.fn.fnamemodify(abs_path, ":h")
	local git = vim.fs.find(".git", { upward = true, path = dir })[1]
	return git and vim.fn.fnamemodify(git, ":h") or dir
end

-- small helper: relative path against a base (git root), else fallback
local function relpath_to(base, abs)
	if not base or base == "" then
		return vim.fn.fnamemodify(abs, ":~:.")
	end
	local norm_base = vim.fs.normalize(base)
	local norm_abs = vim.fs.normalize(abs)
	local base_slash = norm_base:sub(-1) == "/" and norm_base or (norm_base .. "/")
	if norm_abs:sub(1, #base_slash) == base_slash then
		local rel = norm_abs:sub(#base_slash + 0)
		return (rel == "" and vim.fn.fnamemodify(abs, ":t")) or rel
	end
	return vim.fn.fnamemodify(abs, ":~:.")
end

-- render the header label according to user preference
local function header_path(abs_path, workdir_for_label)
	local style = M.config.path_style
	if style == "name" then
		return vim.fn.fnamemodify(abs_path, ":t")
	end
	if style == "relative" then
		return relpath_to(workdir_for_label, abs_path)
	end
	return abs_path
end

-- ── Float geometry & transparency ──────────────────────────────────────────
local function make_float_config(layout_key)
	local L = M.config.layouts[layout_key] or M.config.layouts.float
	local ww = math.floor(vim.o.columns * (L.width or 0.80))
	local hh = math.floor(vim.o.lines * (L.height or 0.80))

	local anchor = L.anchor or "center"
	local col
	if anchor == "right" then
		col = math.max(0, vim.o.columns - ww - (tonumber(L.right_margin) or 2))
	elseif anchor == "left" then
		col = math.max(0, (tonumber(L.left_margin) or 2))
	else
		col = math.floor((vim.o.columns - ww) / 2)
	end
	local row = math.floor((vim.o.lines - hh) / 2)

	return {
		relative = "editor",
		width = ww,
		height = hh,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
		title = " Terminal ",
		title_pos = "center",
	}
end

local function apply_float_transparency(win)
	pcall(vim.api.nvim_set_hl, 0, "NormalFloat", { bg = "NONE" })
	pcall(vim.api.nvim_set_hl, 0, "FloatBorder", { bg = "NONE" })
	vim.api.nvim_set_option_value(
		"winhighlight",
		"Normal:NormalFloat,FloatBorder:FloatBorder,EndOfBuffer:NormalFloat",
		{ win = win }
	)
end

-- ── Terminal setup & I/O ───────────────────────────────────────────────────
local function set_term_keymaps(buf)
	-- this function enables vim motions / quick exit in term-mode
	local o = { buffer = buf, silent = true, noremap = true }
	vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], o)
	vim.keymap.set("t", "<C-h>", [[<C-\><C-n><C-w>h]], o)
	vim.keymap.set("t", "<C-j>", [[<C-\><C-n><C-w>j]], o)
	vim.keymap.set("t", "<C-k>", [[<C-\><C-n><C-w>k]], o)
	vim.keymap.set("t", "<C-l>", [[<C-\><C-n><C-w>l]], o)
	vim.keymap.set("t", "<C-c>", function()
		if term_win and vim.api.nvim_win_is_valid(term_win) then
			vim.api.nvim_win_close(term_win, true)
			term_win = nil
		end
	end, o)
end

local function ensure_term_buf()
	-- this function creates the terminal buffer once and wires keymaps
	if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
		return
	end
	term_buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_set_option_value("bufhidden", "hide", { buf = term_buf })
	vim.api.nvim_buf_call(term_buf, function()
		vim.fn.termopen(vim.o.shell)
	end)
	set_term_keymaps(term_buf)
end

local function term_job()
	return term_buf and vim.b[term_buf] and vim.b[term_buf].terminal_job_id or nil
end

local function term_send(line)
	local job = term_job()
	if job then
		vim.fn.chansend(job, line .. "\n")
	end
end

-- helper: wrap a script in a non-interactive login shell (no command echo)
local function shell_wrap(script)
	-- this function selects bash→zsh→sh and wraps:  SHELL -lc 'script'
	local shell = first_exe({ "bash", "zsh", "sh" }) or "sh"
	local quoted = vim.fn.shellescape(script) -- safe single-quoted string
	return string.format("%s -lc %s", shell, quoted)
end

-- run a command in workdir; when suppressing echo, run via SHELL -lc '…'
local function run_in_workdir(workdir, cmd)
	if M.config.suppress_command_echo then
		local script = string.format("cd %s; %s", vim.fn.fnameescape(workdir), cmd)
		term_send(shell_wrap(script)) -- only program output will show
	else
		term_send(("cd %s && %s"):format(vim.fn.fnameescape(workdir), cmd))
	end
end

local function print_header(title, subtitle)
	local bar = string.rep("─", 8)
	term_send(("%s %s %s"):format(bar, title or "Run", bar))
	if subtitle and #subtitle > 0 then
		term_send(subtitle)
	end
	if M.config.show_cwd then
		term_send("cwd: " .. (vim.fn.getcwd(0, 0) or vim.loop.cwd()))
	end
end

-- ── Float open/resize + save guard ─────────────────────────────────────────
local function open_float(layout_key)
	current_layout_key = layout_key or "float"
	ensure_term_buf()
	local cfg = make_float_config(current_layout_key)

	if not term_win or not vim.api.nvim_win_is_valid(term_win) then
		term_win = vim.api.nvim_open_win(term_buf, true, cfg)
		apply_float_transparency(term_win)
	else
		local info = vim.api.nvim_win_get_config(term_win)
		if info.relative ~= "" then
			vim.api.nvim_win_set_config(term_win, cfg)
			apply_float_transparency(term_win)
		else
			pcall(vim.api.nvim_win_close, term_win, true)
			term_win = vim.api.nvim_open_win(term_buf, true, cfg)
			apply_float_transparency(term_win)
		end
	end

	vim.cmd("startinsert")
end

local function focus_or_open(layout_key)
	if not (term_win and vim.api.nvim_win_is_valid(term_win)) then
		prev_win = vim.api.nvim_get_current_win()
	end
	open_float(layout_key)
end

local function save_current_file_if_needed()
	local buf = 0
	local name = vim.api.nvim_buf_get_name(buf)
	local is_file = (vim.bo[buf].buftype == "") and (name ~= "")
	if is_file and vim.bo[buf].modifiable and not vim.bo[buf].readonly and vim.bo[buf].modified then
		pcall(function()
			vim.cmd("silent write")
		end)
	end
	return is_file, name
end

-- ── Public actions ─────────────────────────────────────────────────────────
function M.toggle_terminal()
	if term_win and vim.api.nvim_win_is_valid(term_win) then
		vim.api.nvim_win_close(term_win, true)
		term_win = nil
		if prev_win and vim.api.nvim_win_is_valid(prev_win) then
			vim.api.nvim_set_current_win(prev_win)
		end
		return
	end
	prev_win = vim.api.nvim_get_current_win()
	open_float("float")
end

function M.run_current_file()
	local ok, abs = save_current_file_if_needed()
	if not ok then
		return vim.notify("Open a real file buffer first.", vim.log.levels.WARN)
	end

	local ft = vim.bo.filetype
	local cmd = build_run_cmd(ft, abs)
	if not cmd then
		return vim.notify("No runner configured for filetype: " .. ft, vim.log.levels.WARN)
	end

	last_cmd = cmd
	last_workdir = pick_workdir(abs)

	focus_or_open("run")
	print_header("Run File", "file: " .. header_path(abs, last_workdir))
	run_in_workdir(last_workdir, cmd)
end

function M.run_line_or_selection()
	local ft = vim.bo.filetype
	local buf_path = vim.api.nvim_buf_get_name(0)
	local workdir = pick_workdir(buf_path)
	local label = header_path(buf_path, workdir)

	if vim.fn.mode():match("[vV]") then
		local srow, erow = vim.fn.line("'<"), vim.fn.line("'>")
		local lines = vim.api.nvim_buf_get_lines(0, srow - 1, erow, false)
		local tmp = vim.fn.tempname()
		vim.fn.writefile(lines, tmp)

		local cmd = build_run_cmd(ft, tmp) or ("bash " .. vim.fn.fnameescape(tmp))
		last_cmd, last_workdir = cmd, workdir

		focus_or_open("run")
		print_header("Run Selection", "file: " .. label)
		run_in_workdir(workdir, cmd)
	else
		local line = vim.api.nvim_get_current_line()
		local tmp = vim.fn.tempname()
		vim.fn.writefile({ line }, tmp)

		local cmd = build_run_cmd(ft, tmp) or ("bash " .. vim.fn.fnameescape(tmp))
		last_cmd, last_workdir = cmd, workdir

		focus_or_open("run")
		print_header("Run Line", "file: " .. label)
		run_in_workdir(workdir, cmd)
	end
end

function M.rerun_last_command()
	if not last_cmd then
		return vim.notify("Nothing to re-run yet.", vim.log.levels.WARN)
	end
	local buf_path = vim.api.nvim_buf_get_name(0)
	local label = header_path(buf_path, last_workdir)
	focus_or_open("run")
	print_header("Run Previous", "file: " .. label)
	run_in_workdir(last_workdir or (vim.loop.cwd() or "."), last_cmd)
end

-- ── Commands & keymaps ─────────────────────────────────────────────────────
vim.api.nvim_create_user_command("RunFile", M.run_current_file, { desc = "Run current file" })
vim.api.nvim_create_user_command("RunLine", M.run_line_or_selection, { desc = "Run current line" })
vim.api.nvim_create_user_command("RunSelection", function(o)
	local srow, erow = o.line1, o.line2
	local ft = vim.bo.filetype
	local buf_path = vim.api.nvim_buf_get_name(0)
	local workdir = pick_workdir(buf_path)
	local label = header_path(buf_path, workdir)

	local lines = vim.api.nvim_buf_get_lines(0, srow - 1, erow, false)
	local tmp = vim.fn.tempname()
	vim.fn.writefile(lines, tmp)

	local cmd = build_run_cmd(ft, tmp) or ("bash " .. vim.fn.fnameescape(tmp))
	last_cmd, last_workdir = cmd, workdir

	focus_or_open("run")
	print_header("Run Selection", "file: " .. label)
	run_in_workdir(workdir, cmd)
end, { range = true, desc = "Run visual selection" })
vim.api.nvim_create_user_command("RunLast", M.rerun_last_command, { desc = "Run last command" })

vim.keymap.set("n", "<leader>t", M.toggle_terminal, { desc = "Terminal: toggle (big float)", silent = true })
vim.keymap.set("n", "<leader>rc", M.run_current_file, { desc = "Run: current file", silent = true })
vim.keymap.set("n", "<leader>rl", M.run_line_or_selection, { desc = "Run: current line", silent = true })
vim.keymap.set("x", "<leader>rv", M.run_line_or_selection, { desc = "Run: visual selection", silent = true })
vim.keymap.set("n", "<leader>rp", M.rerun_last_command, { desc = "Run: previous (re-run last)", silent = true })

-- ── Keep sizing/transparency on resize/theme change ────────────────────────
vim.api.nvim_create_autocmd("VimResized", {
	callback = function()
		if term_win and vim.api.nvim_win_is_valid(term_win) then
			local info = vim.api.nvim_win_get_config(term_win)
			if info.relative ~= "" then
				vim.api.nvim_win_set_config(term_win, make_float_config(current_layout_key))
			end
		end
	end,
})
vim.api.nvim_create_autocmd("ColorScheme", {
	callback = function()
		if term_win and vim.api.nvim_win_is_valid(term_win) then
			local info = vim.api.nvim_win_get_config(term_win)
			if info.relative ~= "" then
				apply_float_transparency(term_win)
			end
		end
	end,
})

return M
