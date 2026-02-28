-- ==============================
-- lua/plugins/mini-modules.lua
-- ==============================
-- GOALS:
-- - Use nvim-mini modules (icons, files, surround, ai, completion)
-- - Keep plugin specs lean; lazy-load on first keypress/insert
-- - Honor transparent UI for mini.files & completion across ANY theme

return {
	-- Icons early (and devicons shim for other plugins)
	{
		"nvim-mini/mini.icons",
		version = false,
		lazy = false,
		config = function()
			require("mini.icons").setup() -- init icon set
			require("mini.icons").mock_nvim_web_devicons() -- devicons shim
		end,
	},

	-- Statusline (simple default; customize later)
	{
		"nvim-mini/mini.statusline",
		version = false,
		lazy = false,
		config = function()
			require("mini.statusline").setup({ use_icons = true })
			vim.opt.laststatus = 3
		end,
	},

	-- File explorer (lazy on keys)
	{
		"nvim-mini/mini.files",
		version = false,
		keys = {
			{
				"<leader>e",
				function()
					require("mini.files").open()
				end,
				desc = "MiniFiles: explore CWD",
			},
			{ "<leader>E", desc = "MiniFiles: reveal current file" },
		},
		config = function()
			local mf = require("mini.files")
			mf.setup({
				options = { use_as_default_explorer = true, permanent_delete = true },
				windows = { preview = true, width_focus = 40, width_nofocus = 25, width_preview = 60 },
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

			-- Reveal current file (graceful fallback for no-name buffers)
			local function reveal_current_file()
				local path = vim.api.nvim_buf_get_name(0)
				if path == "" then
					mf.open()
					return
				end
				mf.open(vim.fn.fnamemodify(path, ":h"))
				if type(mf.reveal) == "function" then
					pcall(mf.reveal, path, { focus = true, open = true })
				end
			end
			vim.keymap.set("n", "<leader>E", reveal_current_file, { desc = "MiniFiles: reveal current file" })
		end,
	},

	-- Completion (lazy on first Insert; defaults are good)
	{
		"nvim-mini/mini.completion",
		version = false,
		event = "InsertEnter",
		config = function()
			require("mini.completion").setup() -- enable minimal, LSP-friendly completion

			-- Transparent popup menu/doc across themes
			local grp = vim.api.nvim_create_augroup("Allen_MiniCompletion_Transparent", { clear = true })
			vim.api.nvim_create_autocmd("ColorScheme", {
				group = grp,
				callback = function()
					local set = vim.api.nvim_set_hl
					pcall(set, 0, "Pmenu", { bg = "NONE" })
					pcall(set, 0, "PmenuSel", { bg = "NONE" })
					pcall(set, 0, "PmenuSbar", { bg = "NONE" })
					pcall(set, 0, "PmenuThumb", { bg = "NONE" })
					pcall(set, 0, "PmenuBorder", { bg = "NONE" })
				end,
			})
			vim.api.nvim_exec_autocmds("ColorScheme", {})
		end,
	},

	-- =========================================================================
	-- GAP 1 CLOSED: mini.surround — custom pairs replacing bare  config = true
	-- =========================================================================
	{
		"nvim-mini/mini.surround",
		version = false,
		event = "VeryLazy",
		config = function()
			require("mini.surround").setup({
				-- sa sd sr sf sF sh sn — all default keys kept as-is
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

				n_lines = 30, -- search up to 30 lines for a surrounding pair
				highlight_duration = 500, -- flash duration in ms when using sh

				-- cover_or_next: if cursor isn't inside a pair, search forward
				-- instead of doing nothing — much more ergonomic
				search_method = "cover_or_next",

				custom_surroundings = {

					-- t: HTML/JSX tag  (sat prompts for tag name, sdt strips nearest tag)
					-- input pattern matches <tag ...>content</tag> as a balanced pair
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

	-- =========================================================================
	-- GAP 2 CLOSED: mini.ai — custom text objects replacing bare  config = true
	-- =========================================================================
	{
		"nvim-mini/mini.ai",
		version = false,
		event = "VeryLazy",
		config = function()
			local ai = require("mini.ai")

			ai.setup({
				-- cover_or_next mirrors the surround search_method:
				-- if cursor is outside an object, find the next one forward
				search_method = "cover_or_next",

				n_lines = 50, -- how many lines to search around cursor for an object

				mappings = {
					around = "a",
					inside = "i",
					around_next = "an",
					inside_next = "in",
					around_last = "al",
					inside_last = "il",
					goto_left = "g[", -- jump cursor to left  edge of object
					goto_right = "g]", -- jump cursor to right edge of object
				},

				custom_textobjects = {

					-- e: entire buffer  (dae = delete all, yae = yank all, vae = select all)
					-- returns fixed from/to positions spanning the whole file
					e = function()
						local from = { line = 1, col = 1 }
						local to = {
							line = vim.fn.line("$"),
							col = math.max(vim.fn.getline("$"):len(), 1),
						}
						return { from = from, to = to }
					end,

					-- a: function ARGUMENT  (dia = delete one arg, caa = change + its comma)
					-- gen_spec.argument handles the comma-aware boundary logic automatically
					a = ai.gen_spec.argument({
						brackets = { "(", "[", "{" },
						separator = ",",
						-- don't split on commas that sit inside nested quotes or brackets
						exclude_regions = { '"', "'", "`", "(", "[", "{" },
					}),

					-- f: function CALL parens + body  (dif = delete args, caf = change whole call)
					-- gen_spec.function_call targets the parens of a call, not the definition
					f = ai.gen_spec.function_call(),

					-- F: function DEFINITION body  (diF = delete body, viF = select body)
					-- treesitter-based so it understands language structure precisely
					-- pcall guards against buffers where treesitter isn't active
					F = function(ai_type)
						local ok, ts = pcall(ai.gen_spec.treesitter, {
							a = "@function.outer",
							i = "@function.inner",
						})
						if not ok then
							return nil
						end
						return ts(ai_type)
					end,

					-- c: class definition  (dic = delete class body, vac = select whole class)
					c = function(ai_type)
						local ok, ts = pcall(ai.gen_spec.treesitter, {
							a = "@class.outer",
							i = "@class.inner",
						})
						if not ok then
							return nil
						end
						return ts(ai_type)
					end,

					-- t: HTML/JSX tag  (dit = delete tag content, vat = tag + content)
					-- treesitter gives accurate tag matching even for nested components
					t = function(ai_type)
						local ok, ts = pcall(ai.gen_spec.treesitter, {
							a = "@block.outer",
							i = "@block.inner",
						})
						if not ok then
							return nil
						end
						return ts(ai_type)
					end,
				},
			})
		end,
	},

	-- =========================================================================
	-- GAP 3 CLOSED: mini.operators — explicit setup replacing bare  config = true
	-- =========================================================================
	{
		"nvim-mini/mini.operators",
		version = false,
		event = "VeryLazy",
		config = function()
			require("mini.operators").setup({
				-- All five operators use their default keys.
				-- Each supports dot-repeat and takes any motion or text object.

				-- gx{motion}: EXCHANGE — two consecutive gx calls swap the regions
				-- gx is doubled for linewise exchange (gxx = exchange current line)
				exchange = { prefix = "gx" },

				-- gr{motion}: REPLACE with register content (default register = unnamed)
				-- gr is doubled for linewise (grr = replace current line)
				-- tip: yiw first, then griw on each target — register is preserved
				replace = { prefix = "gr" },

				-- gs{motion}: SORT lines or delimited words covered by the motion
				-- gs is doubled for linewise sort (gss = sort current line's words)
				-- uses default Lua string sort (case-sensitive, alphabetical)
				sort = {
					prefix = "gs",
					-- reindent_linewise keeps indent level stable after a line sort
					func = nil, -- nil = use default sort; override with custom fn if needed
				},

				-- gm{motion}: MULTIPLY (duplicate) the covered text in place
				-- gm is doubled for linewise duplicate (gmm = duplicate current line)
				multiply = { prefix = "gm" },

				-- g={motion}: EVALUATE the covered text as a Lua expression
				-- replaces the text with its computed result
				-- g== evaluates the current line
				evaluate = {
					prefix = "g=",
					-- func receives the selected text as a string and must return a string
					func = nil, -- nil = default Lua loadstring evaluator
				},
			})
		end,
	},

	-- mini.pairs: auto-close — no custom config needed, defaults cover all pairs
	{ "nvim-mini/mini.pairs", version = false, event = "InsertEnter", config = true },

	-- Comments: gc / gcc / gb motions (tiny & fast)
	{
		"nvim-mini/mini.comment",
		version = false,
		event = "VeryLazy",
		config = function()
			require("mini.comment").setup() -- defaults: gcc (line), gc{motion}, gb (block)
		end,
	},

	-- Indent guides: subtle, transparent-friendly
	{
		"nvim-mini/mini.indentscope",
		version = false,
		event = { "BufReadPre", "BufNewFile" },
		init = function()
			vim.b.miniindentscope_disable = false -- per-buffer toggle (leave enabled by default)
		end,
		config = function()
			require("mini.indentscope").setup({
				symbol = "￤", -- thin guide; easy on transparent themes
				draw = { delay = 50, animation = require("mini.indentscope").gen_animation.none() },
				options = { try_as_border = true }, -- use existing indent as scope when possible
			})

			-- Make indent guides blend on any theme
			local grp = vim.api.nvim_create_augroup("Allen_Indent_Transparent", { clear = true })
			vim.api.nvim_create_autocmd("ColorScheme", {
				group = grp,
				callback = function()
					local set = vim.api.nvim_set_hl
					set(
						0,
						"MiniIndentscopeSymbol",
						{ bg = "NONE", fg = vim.api.nvim_get_hl_by_name("Comment", true).foreground or nil }
					)
					set(0, "MiniIndentscopePrefix", { bg = "NONE", fg = "NONE" })
				end,
			})
			vim.api.nvim_exec_autocmds("ColorScheme", {})
		end,
	},
}
