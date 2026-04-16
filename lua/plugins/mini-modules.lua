-- ==============================
-- lua/plugins/mini-modules.lua
-- ==============================

return {
  -- ── Icons ──────────────────────────────────────────────────────────────
  {
    "nvim-mini/mini.icons",
    version = "*",
    lazy    = false,
    config  = function()
      require("mini.icons").setup()
      require("mini.icons").mock_nvim_web_devicons()
    end,
  },

  -- ── File explorer ───────────────────────────────────────────────────────
  {
    "nvim-mini/mini.files",
    version = "*",
    keys = {
      {
        "<leader>e",
        function() require("mini.files").open() end,
        desc = "MiniFiles: explore CWD",
      },
      {
        "<leader>E",
        function()
          local path = vim.api.nvim_buf_get_name(0)
          local mf   = require("mini.files")
          if path == "" then
            mf.open(); return
          end
          mf.open(vim.fn.fnamemodify(path, ":h"))
          if type(mf.reveal) == "function" then
            pcall(mf.reveal, path, { focus = true, open = true })
          end
        end,
        desc = "MiniFiles: reveal current file",
      },
    },
    opts = {
      options = { use_as_default_explorer = true, permanent_delete = false },
      windows = { preview = true, width_focus = 40, width_nofocus = 25, width_preview = 60 },
    },
    config = function(_, opts)
      require("mini.files").setup(opts)

      local function set_transparent()
        local set = vim.api.nvim_set_hl
        pcall(set, 0, "MiniFilesNormal", { bg = "NONE" })
        pcall(set, 0, "MiniFilesBorder", { bg = "NONE" })
        pcall(set, 0, "MiniFilesTitle", { bg = "NONE" })
      end

      vim.api.nvim_create_autocmd("ColorScheme", {
        group    = vim.api.nvim_create_augroup("Allen_MiniFiles_Transparent", { clear = true }),
        callback = set_transparent,
      })
      vim.api.nvim_create_autocmd("FileType", {
        group    = vim.api.nvim_create_augroup("Allen_MiniFiles_WinHL", { clear = true }),
        pattern  = "minifiles",
        callback = function()
          vim.wo.winhl =
          "Normal:MiniFilesNormal,NormalNC:MiniFilesNormal,FloatBorder:MiniFilesBorder,EndOfBuffer:MiniFilesNormal,WinSeparator:MiniFilesBorder"
        end,
      })
      set_transparent()
    end,
  },

  -- ── Surround ────────────────────────────────────────────────────────────
  -- FIX: t input pattern — removed %1 backreference (Lua patterns don't support it)
  -- %1 was causing "unfinished capture" crash in mini.ai whenever any text object was used
  {
    "nvim-mini/mini.surround",
    version = "*",
    event   = "VeryLazy",
    opts    = {
      mappings            = {
        add            = "sa",
        delete         = "sd",
        replace        = "sr",
        find           = "sf",
        find_left      = "sF",
        highlight      = "sh",
        update_n_lines = "sn",
        suffix_last    = "l",
        suffix_next    = "n",
      },
      n_lines             = 30,
      highlight_duration  = 500,
      search_method       = "cover_or_next",
      custom_surroundings = {
        -- FIX: was "<(%a[%a%d]*)%f[%s>].-</%1>" — %1 backreference not valid in Lua
        -- New pattern matches open/close tags without backreference
        t     = {
          input  = { "<(%a[%a%d%-]*)%f[%s/>][^>]*>.-</%a[%a%d%-]*>", "^<.->().-()</.->$" },
          output = function()
            local tag = vim.fn.input("Tag: ")
            if tag == "" then return nil end
            return { left = "<" .. tag .. ">", right = "</" .. tag .. ">" }
          end,
        },
        ["$"] = { input = { "%${(.-)}" }, output = { left = "${", right = "}" } },
        l     = { input = { "console%.log%((.-)%)" }, output = { left = "console.log(", right = ")" } },
        c     = { input = { "/%* ?(.-)%*/" }, output = { left = "/* ", right = " */" } },
      },
    },
  },

  -- ── Text objects ────────────────────────────────────────────────────────
  {
    "nvim-mini/mini.ai",
    version = "*",
    event   = "VeryLazy",
    config  = function()
      local ai = require("mini.ai")
      ai.setup({
        search_method      = "cover_or_next",
        n_lines            = 50,
        mappings           = {
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
          -- e: entire buffer
          e = function()
            return {
              from = { line = 1, col = 1 },
              to   = { line = vim.fn.line("$"), col = math.max(vim.fn.getline("$"):len(), 1) },
            }
          end,
          -- a: function argument — using mini.ai defaults (no custom brackets/separator)
          -- FIX: custom brackets config was generating invalid internal pattern causing crash
          a = ai.gen_spec.argument(),
          -- f: function call
          f = ai.gen_spec.function_call(),
          -- F: function definition (treesitter)
          F = function(ai_type)
            local ok, result = pcall(ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }), ai_type)
            return ok and result or nil
          end,
          -- c: class definition (treesitter)
          c = function(ai_type)
            local ok, result = pcall(ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }), ai_type)
            return ok and result or nil
          end,
        },
      })
    end,
  },

  -- ── Operators ───────────────────────────────────────────────────────────
  {
    "nvim-mini/mini.operators",
    version = "*",
    event   = "VeryLazy",
    opts    = {
      exchange = { prefix = "gx" },
      replace  = { prefix = "gr" },
      sort     = { prefix = "gs" },
      multiply = { prefix = "gm" },
      evaluate = { prefix = "g=" },
    },
  },

  -- ── Auto-pairs ──────────────────────────────────────────────────────────
  {
    "nvim-mini/mini.pairs",
    version = "*",
    event   = "InsertEnter",
    config  = true,
  },

  -- ── Comments ────────────────────────────────────────────────────────────
  {
    "nvim-mini/mini.comment",
    version = "*",
    event   = "VeryLazy",
    config  = true,
  },

  -- ── Indent guides ───────────────────────────────────────────────────────
  {
    "nvim-mini/mini.indentscope",
    version = "*",
    event   = { "BufReadPre", "BufNewFile" },
    config  = function()
      require("mini.indentscope").setup({
        symbol  = "￤",
        draw    = { delay = 50, animation = require("mini.indentscope").gen_animation.none() },
        options = { try_as_border = true },
      })

      local function fix_hl()
        local set = vim.api.nvim_set_hl
        set(0, "MiniIndentscopeSymbol", { bg = "NONE", fg = vim.api.nvim_get_hl(0, { name = "Comment" }).fg or nil })
        set(0, "MiniIndentscopePrefix", { bg = "NONE", fg = "NONE" })
      end

      vim.api.nvim_create_autocmd("ColorScheme", {
        group    = vim.api.nvim_create_augroup("Allen_Indent_Transparent", { clear = true }),
        callback = fix_hl,
      })
      fix_hl()
    end,
  },

  -- ── Color highlighter ───────────────────────────────────────────────────
  {
    "nvim-mini/mini.hipatterns",
    version = "*",
    event   = { "BufReadPre", "BufNewFile" },
    config  = function()
      local hp = require("mini.hipatterns")
      hp.setup({ highlighters = { hex_color = hp.gen_highlighter.hex_color() } })
    end,
  },
}
