-- ==============================
-- lua/plugins/mini-modules.lua
-- ==============================
-- GOALS:
-- - Use nvim-mini modules (icons, files, surround, ai, completion)
-- - Keep plugin specs lean; lazy-load on first keypress/insert
-- - Honor transparent UI for mini.files across ANY theme

return {
	-- ── Icons (early load + devicons shim for other plugins) ───────────────
	{
		"nvim-mini/mini.icons",
		version = "*",
		lazy = false,
		config = function()
			require("mini.icons").setup()
			require("mini.icons").mock_nvim_web_devicons()
		end,
	},

	-- ── Statusline ─────────────────────────────────────────────────────────
	{
		"nvim-mini/mini.statusline",
		version = "*",
		lazy = false,
		config = function()
			local statusline = require("mini.statusline")

			-- ── Helpers ──────────────────────────────────────────────────

			-- Git branch via gitsigns head
			local function git_branch()
				local ok, head = pcall(function()
					return vim.b.gitsigns_head or vim.g.gitsigns_head
				end)
				if ok and head and head ~= "" then
					return "  " .. head
				end
				return ""
			end

			-- LSP diagnostics count
			local function lsp_diagnostics()
				local errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
				local warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
				local hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
				local parts = {}
				if errors > 0 then
					table.insert(parts, " " .. errors)
				end
				if warnings > 0 then
					table.insert(parts, " " .. warnings)
				end
				if hints > 0 then
					table.insert(parts, " " .. hints)
				end
				return table.concat(parts, " ")
			end

			-- Macro recording indicator — shows which register is being recorded
			local function macro_recording()
				local reg = vim.fn.reg_recording()
				if reg ~= "" then
					return "  @" .. reg
				end
				return ""
			end

			-- LSP client names attached to current buffer
			local function lsp_clients()
				local clients = vim.lsp.get_clients({ bufnr = 0 })
				if #clients == 0 then
					return ""
				end
				local names = {}
				for _, c in ipairs(clients) do
					-- skip noisy utility servers
					if c.name ~= "null-ls" and c.name ~= "copilot" then
						table.insert(names, c.name)
					end
				end
				if #names == 0 then
					return ""
				end
				return "󰒋 " .. table.concat(names, ", ")
			end

			-- ── Active content (focused window) ──────────────────────────
			local function active_content()
				local mode, mode_hl = statusline.section_mode({ trunc_width = 120 })
				local filename = statusline.section_filename({ trunc_width = 140 })
				local fileinfo = statusline.section_fileinfo({ trunc_width = 120 })
				local location = statusline.section_location({ trunc_width = 75 })
				local search = statusline.section_searchcount({ trunc_width = 75 })

				-- Custom sections
				local branch = git_branch()
				local diag = lsp_diagnostics()
				local recording = macro_recording()
				local lsp = lsp_clients()

				-- Combine — left | right pattern
				return statusline.combine_groups({
					-- ── Left ──────────────────────────────────────────────
					{ hl = mode_hl, strings = { mode } },
					{ hl = "MiniStatuslineDevinfo", strings = { branch } },
					{ hl = "MiniStatuslineFilename", strings = { filename } },
					{ hl = "MiniStatuslineDevinfo", strings = { recording } },

					-- ── Spacer ────────────────────────────────────────────
					"%<", -- truncation point
					"%=", -- right-align everything after this

					-- ── Right ─────────────────────────────────────────────
					{ hl = "MiniStatuslineDevinfo", strings = { diag } },
					{ hl = "MiniStatuslineDevinfo", strings = { lsp } },
					{ hl = "MiniStatuslineFileinfo", strings = { fileinfo } },
					{ hl = "MiniStatuslineDevinfo", strings = { search } },
					{ hl = mode_hl, strings = { location } },
				})
			end

			-- ── Inactive content (unfocused windows) ─────────────────────
			local function inactive_content()
				return statusline.combine_groups({
					{ hl = "MiniStatuslineInactive", strings = { "%f %m" } },
					"%=",
					{ hl = "MiniStatuslineInactive", strings = { "%l:%c" } },
				})
			end

			statusline.setup({
				content = {
					active = active_content,
					inactive = inactive_content,
				},
				use_icons = true,
				set_vim_settings = true,
			})

			-- Trigger statusline redraw when macro recording starts/stops
			-- so the @q indicator appears and disappears in real time
			vim.api.nvim_create_autocmd("RecordingEnter", {
				group = vim.api.nvim_create_augroup("Allen_StatusMacro", { clear = true }),
				callback = function()
					vim.cmd("redrawstatus")
				end,
			})
			vim.api.nvim_create_autocmd("RecordingLeave", {
				group = "Allen_StatusMacro",
				callback = function()
					vim.cmd("redrawstatus")
				end,
			})

			vim.opt.laststatus = 3
		end,
	},

	-- ── File explorer ───────────────────────────────────────────────────────
	{
		"nvim-mini/mini.files",
		version = "*",
		keys = {
			{
				"<leader>e",
				function()
					require("mini.files").open()
				end,
				desc = "MiniFiles: explore CWD",
			},
			{
				"<leader>E",
				function()
					local path = vim.api.nvim_buf_get_name(0)
					local mf = require("mini.files")
					if path == "" then
						mf.open()
						return
					end
					mf.open(vim.fn.fnamemodify(path, ":h"))
					if type(mf.reveal) == "function" then
						pcall(mf.reveal, path, { focus = true, open = true })
					end
				end,
				desc = "MiniFiles: reveal current file",
			},
		},
		config = function()
			local mf = require("mini.files")
			mf.setup({
				options = {
					use_as_default_explorer = true,
					permanent_delete = false,
				},
				windows = {
					preview = true,
					width_focus = 40,
					width_nofocus = 25,
					width_preview = 60,
				},
			})

			local function mini_files_transparent()
				local set = vim.api.nvim_set_hl
				pcall(set, 0, "MiniFilesNormal", { bg = "NONE" })
				pcall(set, 0, "MiniFilesBorder", { bg = "NONE" })
				pcall(set, 0, "MiniFilesTitle", { bg = "NONE" })
			end
			vim.api.nvim_create_autocmd("ColorScheme", {
				group = vim.api.nvim_create_augroup("Allen_MiniFiles_Transparent", { clear = true }),
				callback = mini_files_transparent,
			})
			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("Allen_MiniFiles_WinHL", { clear = true }),
				pattern = "minifiles",
				callback = function()
					vim.wo.winhl = table.concat({
						"Normal:MiniFilesNormal",
						"NormalNC:MiniFilesNormal",
						"FloatBorder:MiniFilesBorder",
						"EndOfBuffer:MiniFilesNormal",
						"WinSeparator:MiniFilesBorder",
					}, ",")
				end,
			})
			mini_files_transparent()
		end,
	},

	-- NOTE: mini.completion REMOVED — conflicts with nvim-cmp (cmp.lua)

	-- ── Surround ────────────────────────────────────────────────────────────
	{
		"nvim-mini/mini.surround",
		version = "*",
		event = "VeryLazy",
		config = function()
			require("mini.surround").setup({
				mappings = {
					add = "sa",
					delete = "sd",
					replace = "sr",
					find = "sf",
					find_left = "sF",
					highlight = "sh",
					update_n_lines = "sn",
					suffix_last = "l",
					suffix_next = "n",
				},
				n_lines = 30,
				highlight_duration = 500,
				search_method = "cover_or_next",

				custom_surroundings = {
					t = {
						input = { "<(%a[%a%d]*)%f[%s>].-</%1>", "^<.->().-()</.->$" },
						output = function()
							local tag = vim.fn.input("Tag: ")
							if tag == "" then
								return nil
							end
							return { left = "<" .. tag .. ">", right = "</" .. tag .. ">" }
						end,
					},
					["$"] = {
						input = { "%${(.-)}" },
						output = { left = "${", right = "}" },
					},
					l = {
						input = { "console%.log%((.-)%)" },
						output = { left = "console.log(", right = ")" },
					},
					c = {
						input = { "/%* ?(.-)%*/" },
						output = { left = "/* ", right = " */" },
					},
				},
			})
		end,
	},

	-- ── Extended text objects ───────────────────────────────────────────────
	{
		"nvim-mini/mini.ai",
		version = "*",
		event = "VeryLazy",
		config = function()
			local ai = require("mini.ai")

			ai.setup({
				search_method = "cover_or_next",
				n_lines = 50,

				mappings = {
					around = "a",
					inside = "i",
					around_next = "an",
					inside_next = "in",
					around_last = "al",
					inside_last = "il",
					goto_left = "g[",
					goto_right = "g]",
				},

				custom_textobjects = {
					e = function()
						local from = { line = 1, col = 1 }
						local to = {
							line = vim.fn.line("$"),
							col = math.max(vim.fn.getline("$"):len(), 1),
						}
						return { from = from, to = to }
					end,

					a = ai.gen_spec.argument({
						brackets = { "(", "[", "{" },
						separator = ",",
						exclude_regions = { '"', "'", "`", "(", "[", "{" },
					}),

					f = ai.gen_spec.function_call(),

					F = function(ai_type)
						local spec = ai.gen_spec.treesitter({
							a = "@function.outer",
							i = "@function.inner",
						})
						local ok, result = pcall(spec, ai_type)
						if not ok then
							return nil
						end
						return result
					end,

					c = function(ai_type)
						local spec = ai.gen_spec.treesitter({
							a = "@class.outer",
							i = "@class.inner",
						})
						local ok, result = pcall(spec, ai_type)
						if not ok then
							return nil
						end
						return result
					end,

					t = function(ai_type)
						local tag_pattern = "<(%w[%w%-:]*)%f[%s/>][^>]*>(.-)</%1>"
						local line_count = vim.api.nvim_buf_line_count(0)
						local cur_line = vim.api.nvim_win_get_cursor(0)[1]
						local search_start = math.max(1, cur_line - 30)
						local search_end = math.min(line_count, cur_line + 30)
						local lines = vim.api.nvim_buf_get_lines(0, search_start - 1, search_end, false)
						local combined = table.concat(lines, "\n")

						local s, e, tag_name, _ = combined:find(tag_pattern)
						if not s then
							return nil
						end

						local function offset_to_pos(offset, base_line)
							local prefix = combined:sub(1, offset - 1)
							local newlines = select(2, prefix:gsub("\n", ""))
							local last_nl = prefix:find("[^\n]*$")
							return {
								line = base_line + newlines,
								col = offset - (last_nl or 1),
							}
						end

						if ai_type == "i" then
							local content_start = s + combined:sub(s):find(">")
							local content_end = e - #("</" .. tag_name .. ">")
							return {
								from = offset_to_pos(content_start + 1, search_start),
								to = offset_to_pos(content_end, search_start),
							}
						else
							return {
								from = offset_to_pos(s, search_start),
								to = offset_to_pos(e + 1, search_start),
							}
						end
					end,
				},
			})
		end,
	},

	-- ── Operators ───────────────────────────────────────────────────────────
	{
		"nvim-mini/mini.operators",
		version = "*",
		event = "VeryLazy",
		config = function()
			require("mini.operators").setup({
				exchange = { prefix = "gx" },
				replace = { prefix = "gr" },
				sort = { prefix = "gs", func = nil },
				multiply = { prefix = "gm" },
				evaluate = { prefix = "g=", func = nil },
			})
		end,
	},

	-- ── Auto-pairs ──────────────────────────────────────────────────────────
	{
		"nvim-mini/mini.pairs",
		version = "*",
		event = "InsertEnter",
		config = true,
	},

	-- ── Comments ────────────────────────────────────────────────────────────
	{
		"nvim-mini/mini.comment",
		version = "*",
		event = "VeryLazy",
		config = function()
			require("mini.comment").setup()
		end,
	},

	-- ── Indent guides ───────────────────────────────────────────────────────
	{
		"nvim-mini/mini.indentscope",
		version = "*",
		event = { "BufReadPre", "BufNewFile" },
		init = function()
			vim.b.miniindentscope_disable = false
		end,
		config = function()
			require("mini.indentscope").setup({
				symbol = "￤",
				draw = {
					delay = 50,
					animation = require("mini.indentscope").gen_animation.none(),
				},
				options = { try_as_border = true },
			})

			local grp = vim.api.nvim_create_augroup("Allen_Indent_Transparent", { clear = true })
			vim.api.nvim_create_autocmd("ColorScheme", {
				group = grp,
				callback = function()
					local set = vim.api.nvim_set_hl
					set(0, "MiniIndentscopeSymbol", {
						bg = "NONE",
						fg = vim.api.nvim_get_hl(0, { name = "Comment" }).fg or nil,
					})
					set(0, "MiniIndentscopePrefix", { bg = "NONE", fg = "NONE" })
				end,
			})

			local set = vim.api.nvim_set_hl
			set(0, "MiniIndentscopeSymbol", {
				bg = "NONE",
				fg = vim.api.nvim_get_hl(0, { name = "Comment" }).fg or nil,
			})
			set(0, "MiniIndentscopePrefix", { bg = "NONE", fg = "NONE" })
		end,
	},

	-- ── Color highlighter ───────────────────────────────────────────────────
	{
		"nvim-mini/mini.hipatterns",
		version = "*",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			local hipatterns = require("mini.hipatterns")
			hipatterns.setup({
				highlighters = {
					hex_color = hipatterns.gen_highlighter.hex_color(),

					rgb_color = {
						pattern = "rgb%(%d+,?%s*%d+,?%s*%d+%)",
						group = function(_, match)
							local r, g, b = match:match("rgb%((%d+),?%s*(%d+),?%s*(%d+)%)")
							if r then
								return hipatterns.compute_hex_color_group(string.format("#%02x%02x%02x", r, g, b), "bg")
							end
						end,
					},

					hsl_color = {
						pattern = "hsl%(%d+,?%s*%d+%%?,?%s*%d+%%?%)",
						group = function(_, match)
							local h, s, l = match:match("hsl%((%d+),?%s*(%d+)%%?,?%s*(%d+)%%?%)")
							if not h then
								return nil
							end
							h, s, l = tonumber(h) / 360, tonumber(s) / 100, tonumber(l) / 100
							local function hue(p, q, t)
								if t < 0 then
									t = t + 1
								end
								if t > 1 then
									t = t - 1
								end
								if t < 1 / 6 then
									return p + (q - p) * 6 * t
								end
								if t < 1 / 2 then
									return q
								end
								if t < 2 / 3 then
									return p + (q - p) * (2 / 3 - t) * 6
								end
								return p
							end
							local q2 = l < 0.5 and l * (1 + s) or l + s - l * s
							local p2 = 2 * l - q2
							local r = math.floor(hue(p2, q2, h + 1 / 3) * 255)
							local g = math.floor(hue(p2, q2, h) * 255)
							local b = math.floor(hue(p2, q2, h - 1 / 3) * 255)
							return hipatterns.compute_hex_color_group(string.format("#%02x%02x%02x", r, g, b), "bg")
						end,
					},
				},
			})
		end,
	},
}
