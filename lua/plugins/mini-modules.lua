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
			require("mini.statusline").setup({ use_icons = true })
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
			-- FIX: was defined twice (placeholder here + vim.keymap.set in config)
			-- Now has its action defined directly here — no duplicate in config
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
					-- FIX: was true — permanent delete skips trash, too destructive
					permanent_delete = false,
				},
				windows = {
					preview = true,
					width_focus = 40,
					width_nofocus = 25,
					width_preview = 60,
				},
			})

			-- Transparent UI for mini.files (theme-agnostic)
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
			-- NOTE: <leader>E keymap is defined in the keys table above (no duplicate here)
		end,
	},

	-- NOTE: mini.completion REMOVED — conflicts with nvim-cmp (cmp.lua)
	-- Both hook InsertEnter and provide completion causing duplicate menus.
	-- nvim-cmp is our completion engine — see lua/plugins/cmp.lua

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
					-- t: HTML/JSX tag  (sat prompts for tag name, sdt strips nearest tag)
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
					-- $: template expression  (sa$ → ${}, sd$ strips it)
					["$"] = {
						input = { "%${(.-)}" },
						output = { left = "${", right = "}" },
					},
					-- l: console.log wrapper  (sal wraps, sdl unwraps)
					l = {
						input = { "console%.log%((.-)%)" },
						output = { left = "console.log(", right = ")" },
					},
					-- c: /* block comment */  (sac wraps, sdc strips)
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
					-- e: entire buffer  (dae / yae / vae)
					e = function()
						local from = { line = 1, col = 1 }
						local to = {
							line = vim.fn.line("$"),
							col = math.max(vim.fn.getline("$"):len(), 1),
						}
						return { from = from, to = to }
					end,

					-- a: function argument (dia / caa — comma-aware)
					a = ai.gen_spec.argument({
						brackets = { "(", "[", "{" },
						separator = ",",
						exclude_regions = { '"', "'", "`", "(", "[", "{" },
					}),

					-- f: function call parens + body  (dif / caf)
					f = ai.gen_spec.function_call(),

					-- F: function definition body  (diF / viF)
					-- pcall guard: treesitter errors lazily if no query for filetype
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

					-- c: class definition  (dic / vac)
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

					-- t: HTML/JSX tag — pattern-based, no treesitter dependency
					-- works in JS, JSX, TSX, HTML without needing query files
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
				exchange = { prefix = "gx" }, -- gx{motion}: swap two regions
				replace = { prefix = "gr" }, -- gr{motion}: replace with register
				sort = { prefix = "gs", func = nil }, -- gs{motion}: sort lines/words
				multiply = { prefix = "gm" }, -- gm{motion}: duplicate in place
				evaluate = { prefix = "g=", func = nil }, -- g={motion}: eval as Lua
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
	-- NOTE: Neovim 0.10+ has a built-in gc/gcc operator — mini.comment overrides
	-- it with identical behavior plus a few extras. Remove if you prefer built-in.
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

			-- Blend indent guides on any theme
			local grp = vim.api.nvim_create_augroup("Allen_Indent_Transparent", { clear = true })
			vim.api.nvim_create_autocmd("ColorScheme", {
				group = grp,
				callback = function()
					local set = vim.api.nvim_set_hl
					-- FIX: nvim_get_hl_by_name deprecated — use nvim_get_hl (0.9+)
					set(0, "MiniIndentscopeSymbol", {
						bg = "NONE",
						fg = vim.api.nvim_get_hl(0, { name = "Comment" }).fg or nil,
					})
					set(0, "MiniIndentscopePrefix", { bg = "NONE", fg = "NONE" })
				end,
			})

			-- FIX: was nvim_exec_autocmds("ColorScheme") — fires ALL listeners
			-- Apply directly on first load instead
			local set = vim.api.nvim_set_hl
			set(0, "MiniIndentscopeSymbol", {
				bg = "NONE",
				fg = vim.api.nvim_get_hl(0, { name = "Comment" }).fg or nil,
			})
			set(0, "MiniIndentscopePrefix", { bg = "NONE", fg = "NONE" })
		end,
	},
}
