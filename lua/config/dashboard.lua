-- dashboard.lua - Dynamic Weekly Dashboard for Neovim
-- Save this file and add to your init.lua: require('dashboard')

local M = {}

-- ASCII art for each day of the week
local ascii_art = {
	sunday = {
		[[    Neovim PDE                                        ]],
		[[                                                       ]],
		[[  ███████╗██╗   ██╗███╗   ██╗██████╗  █████╗ ██╗   ██  ]],
		[[  ██╔════╝██║   ██║████╗  ██║██╔══██╗██╔══██╗╚██╗ ██╔  ]],
		[[  ███████╗██║   ██║██╔██╗ ██║██║  ██║███████║ ╚████╔╝  ]],
		[[  ╚════██║██║   ██║██║╚██╗██║██║  ██║██╔══██║  ╚██╔╝   ]],
		[[  ███████║╚██████╔╝██║ ╚████║██████╔╝██║  ██║   ██║    ]],
		[[  ╚══════╝ ╚═════╝ ╚═╝  ╚═══╝╚═════╝ ╚═╝  ╚═╝   ╚═╝    ]],
	},
	monday = {
		[[    Neovim PDE                                           ]],
		[[                                                          ]],
		[[  ███╗   ███╗ ██████╗ ███╗   ██╗██████╗  █████╗ ██╗   ██  ]],
		[[  ████╗ ████║██╔═══██╗████╗  ██║██╔══██╗██╔══██╗╚██╗ ██╔  ]],
		[[  ██╔████╔██║██║   ██║██╔██╗ ██║██║  ██║███████║ ╚████╔╝  ]],
		[[  ██║╚██╔╝██║██║   ██║██║╚██╗██║██║  ██║██╔══██║  ╚██╔╝   ]],
		[[  ██║ ╚═╝ ██║╚██████╔╝██║ ╚████║██████╔╝██║  ██║   ██║    ]],
		[[  ╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚═════╝ ╚═╝  ╚═╝   ╚═╝    ]],
	},
	tuesday = {
		[[    Neovim PDE                                               ]],
		[[                                                              ]],
		[[  ████████╗██╗   ██╗███████╗███████╗██████╗  █████╗ ██╗   ██  ]],
		[[  ╚══██╔══╝██║   ██║██╔════╝██╔════╝██╔══██╗██╔══██╗╚██╗ ██╔  ]],
		[[     ██║   ██║   ██║█████╗  ███████╗██║  ██║███████║ ╚████╔╝  ]],
		[[     ██║   ██║   ██║██╔══╝  ╚════██║██║  ██║██╔══██║  ╚██╔╝   ]],
		[[     ██║   ╚██████╔╝███████╗███████║██████╔╝██║  ██║   ██║    ]],
		[[     ╚═╝    ╚═════╝ ╚══════╝╚══════╝╚═════╝ ╚═╝  ╚═╝   ╚═╝    ]],
	},
	wednesday = {
		[[    Neovim PDE                                                                 ]],
		[[                                                                                ]],
		[[  ██╗    ██╗███████╗██████╗ ███╗   ██╗███████╗███████╗██████╗  █████╗ ██╗   █ █ ]],
		[[  ██║    ██║██╔════╝██╔══██╗████╗  ██║██╔════╝██╔════╝██╔══██╗██╔══██╗╚██╗ ██ ╔ ]],
		[[  ██║ █╗ ██║█████╗  ██║  ██║██╔██╗ ██║█████╗  ███████╗██║  ██║███████║ ╚████╔ ╝ ]],
		[[  ██║███╗██║██╔══╝  ██║  ██║██║╚██╗██║██╔══╝  ╚════██║██║  ██║██╔══██║  ╚██╔╝   ]],
		[[  ╚███╔███╔╝███████╗██████╔╝██║ ╚████║███████╗███████║██████╔╝██║  ██║   ██║    ]],
		[[   ╚══╝╚══╝ ╚══════╝╚═════╝ ╚═╝  ╚═══╝╚══════╝╚══════╝╚═════╝ ╚═╝  ╚═╝   ╚═╝    ]],
	},
	thursday = {
		[[    Neovim PDE                                                          ]],
		[[                                                                         ]],
		[[  ████████╗██╗  ██╗██╗   ██╗██████╗ ███████╗██████╗  █████╗ ██╗   ██     ]],
		[[  ╚══██╔══╝██║  ██║██║   ██║██╔══██╗██╔════╝██╔══██╗██╔══██╗╚██╗ ██╔     ]],
		[[     ██║   ███████║██║   ██║██████╔╝███████╗██║  ██║███████║ ╚████╔╝     ]],
		[[     ██║   ██╔══██║██║   ██║██╔══██╗╚════██║██║  ██║██╔══██║  ╚██╔╝      ]],
		[[     ██║   ██║  ██║╚██████╔╝██║  ██║███████║██████╔╝██║  ██║   ██║       ]],
		[[     ╚═╝   ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═════╝ ╚═╝  ╚═╝   ╚═╝       ]],
	},
	friday = {

		[[    Neovim PDE                                    ]],
		[[                                                   ]],
		[[  ███████╗██████╗ ██╗██████╗  █████╗ ██╗   ██╗     ]],
		[[  ██╔════╝██╔══██╗██║██╔══██╗██╔══██╗╚██╗ ██╔╝     ]],
		[[  █████╗  ██████╔╝██║██║  ██║███████║ ╚████╔╝      ]],
		[[  ██╔══╝  ██╔══██╗██║██║  ██║██╔══██║  ╚██╔╝       ]],
		[[  ██║     ██║  ██║██║██████╔╝██║  ██║   ██║        ]],
		[[  ╚═╝     ╚═╝  ╚═╝╚═╝╚═════╝ ╚═╝  ╚═╝   ╚═╝        ]],
	},
	saturday = {

		[[    Neovim PDE
        [[                                                                      ]],
		[[  ███████╗ █████╗ ████████╗██╗   ██╗██████╗ ██████╗  █████╗ ██╗   ██╗ ]],
		[[  ██╔════╝██╔══██╗╚══██╔══╝██║   ██║██╔══██╗██╔══██╗██╔══██╗╚██╗ ██╔╝ ]],
		[[  ███████╗███████║   ██║   ██║   ██║██████╔╝██║  ██║███████║ ╚████╔╝  ]],
		[[  ╚════██║██╔══██║   ██║   ██║   ██║██╔══██╗██║  ██║██╔══██║  ╚██╔╝   ]],
		[[  ███████║██║  ██║   ██║   ╚██████╔╝██║  ██║██████╔╝██║  ██║   ██║    ]],
		[[  ╚══════╝╚═╝  ╚═╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝   ╚═╝    ]],
	},
}

-- Menu items with proper icons
local menu_items = {
	{
		icon = "🔎",
		desc = "Find file",
		key = "f",
		action = function()
			require("telescope.builtin").find_files()
		end,
	},
	{
		icon = "📑",
		desc = "New file",
		key = "n",
		action = function()
			vim.cmd("enew")
		end,
	},
	{
		icon = "🗂️",
		desc = "Recent files",
		key = "r",
		action = function()
			require("telescope.builtin").oldfiles()
		end,
	},
	{
		icon = "📝",
		desc = "Find text",
		key = "g",
		action = function()
			require("telescope.builtin").live_grep()
		end,
	},
	{
		icon = "⚙️",
		desc = "Config",
		key = "c",
		action = function()
			vim.cmd("edit ~/.config/nvim/init.lua")
		end,
	},
	{
		icon = "🔄",
		desc = "Restore Session",
		key = "s",
		action = function()
			vim.notify("Session restore not configured", vim.log.levels.INFO)
		end,
	},
	{
		icon = "📁",
		desc = "File Explorer",
		key = "e",
		action = function()
			local mini_files_ok = pcall(require, "mini.files")
			if mini_files_ok then
				require("mini.files").open()
			else
				vim.cmd("Explore")
			end
		end,
	},
	{
		icon = "🌐",
		desc = "Live Server",
		key = "v",
		action = function()
			-- Check if live-server is available
			if vim.fn.executable("live-server") == 1 then
				vim.notify("Starting Live Server...", vim.log.levels.INFO)
				vim.fn.jobstart("live-server", {
					detach = true,
					on_exit = function(_, code)
						if code == 0 then
							vim.notify("Live Server stopped", vim.log.levels.INFO)
						end
					end,
				})
			else
				vim.notify("Live Server not installed. Run: npm install -g live-server", vim.log.levels.WARN)
			end
		end,
	},
	{
		icon = "💤",
		desc = "Lazy",
		key = "l",
		action = function()
			vim.cmd("Lazy")
		end,
	},
	{
		icon = "📤",
		desc = "Quit",
		key = "q",
		action = function()
			vim.cmd("qa")
		end,
	},
}

-- Get current day of week
local function get_day_of_week()
	local days = { "sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday" }
	local day_num = tonumber(os.date("%w")) + 1
	return days[day_num]
end

-- Detect current colorscheme and return appropriate colors
local function get_theme_colors()
	local colorscheme = vim.g.colors_name or "default"

	-- Catppuccin
	if colorscheme:match("catppuccin") then
		return {
			header = "#89B4FA",
			icon = "#89B4FA",
			desc = "#CDD6F4",
			key = "#F38BA8",
			footer = "#6C7086",
		}
	-- OneDark
	elseif colorscheme:match("onedark") then
		return {
			header = "#61AFEF",
			icon = "#61AFEF",
			desc = "#ABB2BF",
			key = "#E06C75",
			footer = "#5C6370",
		}
	-- Tokyo Night
	elseif colorscheme:match("tokyonight") then
		return {
			header = "#7AA2F7",
			icon = "#7AA2F7",
			desc = "#C0CAF5",
			key = "#F7768E",
			footer = "#565F89",
		}
	-- Default fallback
	else
		return {
			header = "#61AFEF",
			icon = "#61AFEF",
			desc = "#ABB2BF",
			key = "#E06C75",
			footer = "#5C6370",
		}
	end
end

-- Center text properly in window
local function center_text(text, win_width)
	local text_width = vim.fn.strdisplaywidth(text)
	local padding = math.max(0, math.floor((win_width - text_width) / 2))
	return string.rep(" ", padding) .. text
end

-- Left align text with padding
local function left_align(text, win_width, left_margin)
	return string.rep(" ", left_margin) .. text
end

-- Setup buffer
local function setup_buffer()
	local buf = vim.api.nvim_create_buf(false, true)
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].swapfile = false
	vim.bo[buf].modifiable = false
	vim.bo[buf].filetype = "dashboard"
	vim.api.nvim_buf_set_name(buf, "Dashboard")

	return buf
end

-- Draw the dashboard
local function draw_dashboard(buf)
	local win_height = vim.api.nvim_win_get_height(0)
	local win_width = vim.api.nvim_win_get_width(0)
	local lines = {}

	-- Get ASCII art for current day
	local day = get_day_of_week()
	local art = ascii_art[day]

	-- Calculate total content height
	local art_height = #art
	local menu_height = #menu_items
	local spacing = 6
	local total_height = art_height + menu_height + spacing + 2

	-- Calculate starting line to center vertically
	local start_line = math.max(2, math.floor((win_height - total_height) / 2))

	-- Add top padding
	for _ = 1, start_line do
		table.insert(lines, "")
	end

	-- Add ASCII art (centered)
	for _, line in ipairs(art) do
		table.insert(lines, center_text(line, win_width))
	end

	-- Add spacing after art
	table.insert(lines, "")
	table.insert(lines, "")

	-- Calculate left margin to center menu items
	local left_margin = math.max(4, math.floor((win_width - 50) / 2))

	-- Add menu items with better spacing for two-column look
	for _, item in ipairs(menu_items) do
		local menu_line = string.format("%s  %-20s        %s", item.icon, item.desc, item.key)
		table.insert(lines, left_align(menu_line, win_width, left_margin))
	end

	-- Add spacing
	table.insert(lines, "")
	table.insert(lines, "")

	-- Add footer with plugin count
	local lazy_ok, lazy = pcall(require, "lazy")
	local pkg_count = lazy_ok and #lazy.plugins() or 0
	local lazy_stats = lazy_ok and lazy.stats() or { startuptime = 0 }
	local startup_time = string.format("%.2fms", lazy_stats.startuptime or 0)
	local footer = string.format("  Neovim loaded %d/%d plugins in %s", pkg_count, pkg_count, startup_time)
	table.insert(lines, left_align(footer, win_width, left_margin))

	-- Fill remaining space
	while #lines < win_height do
		table.insert(lines, "")
	end

	-- Write to buffer
	vim.bo[buf].modifiable = true
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].modifiable = false

	return start_line + 1
end

-- Setup highlighting with theme colors
local function setup_highlights()
	local colors = get_theme_colors()

	vim.api.nvim_set_hl(0, "DashboardHeader", { fg = colors.header, bold = true })
	vim.api.nvim_set_hl(0, "DashboardIcon", { fg = colors.icon })
	vim.api.nvim_set_hl(0, "DashboardDesc", { fg = colors.desc })
	vim.api.nvim_set_hl(0, "DashboardKey", { fg = colors.key, bold = true })
	vim.api.nvim_set_hl(0, "DashboardFooter", { fg = colors.footer })
end

-- Apply highlights to buffer
local function apply_highlights(buf, start_line)
	local ns_id = vim.api.nvim_create_namespace("dashboard")
	vim.api.nvim_buf_clear_namespace(buf, ns_id, 0, -1)

	local current_line = start_line - 1

	-- Highlight ASCII art
	local day = get_day_of_week()
	local art = ascii_art[day]

	for i = 0, #art - 1 do
		local line_idx = current_line + i
		local line_text = vim.api.nvim_buf_get_lines(buf, line_idx, line_idx + 1, false)[1]
		if line_text and #line_text > 0 then
			vim.api.nvim_buf_set_extmark(buf, ns_id, line_idx, 0, {
				end_line = line_idx,
				end_col = #line_text,
				hl_group = "DashboardHeader",
			})
		end
	end

	current_line = current_line + #art + 2

	-- Highlight menu items
	for i = 0, #menu_items - 1 do
		local line_idx = current_line + i
		local line_text = vim.api.nvim_buf_get_lines(buf, line_idx, line_idx + 1, false)[1]

		if line_text and #line_text > 0 then
			local item = menu_items[i + 1]

			-- Find icon position (first few characters)
			local icon_str = item.icon
			local icon_len = #icon_str
			local icon_end = icon_len + 2 -- icon + spacing

			-- Highlight icon with DashboardIcon color
			if icon_end <= #line_text then
				vim.api.nvim_buf_set_extmark(buf, ns_id, line_idx, 0, {
					end_line = line_idx,
					end_col = icon_end,
					hl_group = "DashboardIcon",
				})
			end

			-- Highlight description (middle part)
			local desc_start = icon_end
			local desc_end = #line_text - 10
			if desc_start < desc_end then
				vim.api.nvim_buf_set_extmark(buf, ns_id, line_idx, desc_start, {
					end_line = line_idx,
					end_col = desc_end,
					hl_group = "DashboardDesc",
				})
			end

			-- Highlight key (last character)
			if #line_text > 0 then
				vim.api.nvim_buf_set_extmark(buf, ns_id, line_idx, #line_text - 1, {
					end_line = line_idx,
					end_col = #line_text,
					hl_group = "DashboardKey",
				})
			end
		end
	end

	-- Highlight footer
	local footer_line = current_line + #menu_items + 2
	local line_text = vim.api.nvim_buf_get_lines(buf, footer_line, footer_line + 1, false)[1]
	if line_text and #line_text > 0 then
		vim.api.nvim_buf_set_extmark(buf, ns_id, footer_line, 0, {
			end_line = footer_line,
			end_col = #line_text,
			hl_group = "DashboardFooter",
		})
	end
end

-- Setup keymaps for buffer
local function setup_keymaps(buf)
	local opts = { noremap = true, silent = true, buffer = buf }

	-- Setup menu item keymaps
	for _, item in ipairs(menu_items) do
		vim.keymap.set("n", item.key, function()
			local ok, err = pcall(item.action)
			if not ok then
				vim.notify("Error: " .. tostring(err), vim.log.levels.ERROR)
			end
		end, opts)
	end

	-- Additional convenience mappings
	vim.keymap.set("n", "<CR>", function()
		vim.cmd("enew")
	end, opts)

	vim.keymap.set("n", "<Esc>", function()
		vim.cmd("enew")
	end, opts)
end

-- Main open function
function M.open()
	setup_highlights()
	local buf = setup_buffer()
	vim.api.nvim_set_current_buf(buf)
	local start_line = draw_dashboard(buf)
	apply_highlights(buf, start_line)
	setup_keymaps(buf)

	-- Disable UI elements only for this buffer
	vim.opt_local.number = false
	vim.opt_local.relativenumber = false
	vim.opt_local.cursorline = false
	vim.opt_local.cursorcolumn = false
	vim.opt_local.colorcolumn = "0"
	vim.opt_local.signcolumn = "no"
	vim.opt_local.foldcolumn = "0"

	vim.cmd("normal! zz")
end

-- Setup autocommands
function M.setup(opts)
	opts = opts or {}
	local group = vim.api.nvim_create_augroup("Dashboard", { clear = true })

	vim.api.nvim_create_autocmd("VimEnter", {
		group = group,
		callback = function()
			if vim.fn.argc() == 0 and vim.fn.line2byte("$") == -1 then
				M.open()
			end
		end,
	})

	vim.api.nvim_create_autocmd("VimResized", {
		group = group,
		callback = function()
			if vim.bo.filetype == "dashboard" then
				local buf = vim.api.nvim_get_current_buf()
				local start_line = draw_dashboard(buf)
				apply_highlights(buf, start_line)
			end
		end,
	})

	vim.api.nvim_create_autocmd("ColorScheme", {
		group = group,
		callback = function()
			-- Only update highlights, don't redraw the entire dashboard
			setup_highlights()
		end,
	})
end

vim.api.nvim_create_user_command("Dashboard", function()
	M.open()
end, {})

return M
