
-- ==============================
-- lua/plugins/telescope.lua
-- ==============================

return {
  {
    "nvim-telescope/telescope.nvim",        -- this plugin provides fuzzy-finders (files, grep, buffers, help)
    tag = "0.1.8",                          -- this variable pins to a known-stable Telescope version
    dependencies = { "nvim-lua/plenary.nvim" }, -- this plugin is a required utility library for Telescope

    -- We put keymaps here so lazy.nvim loads Telescope only when you press them
    keys = {
      { "<leader>ff", function() require("telescope.builtin").find_files()  end, desc = "Telescope: find files" },  -- this mapping opens file picker (respects .gitignore)
      { "<leader>fg", function() require("telescope.builtin").live_grep()   end, desc = "Telescope: live grep"  },  -- this mapping searches text using ripgrep
      { "<leader>fb", function() require("telescope.builtin").buffers()     end, desc = "Telescope: buffers"    },  -- this mapping lists open buffers
      { "<leader>fh", function() require("telescope.builtin").help_tags()   end, desc = "Telescope: help tags"  },  -- this mapping searches Neovim help
    },

    -- Keep options tiny; let the theme handle visuals
    opts = {
      defaults = {
        sorting_strategy = "ascending",     -- this option shows prompt at top and results grow downward
        layout_strategy  = "horizontal",    -- this option arranges prompt/results/preview horizontally
        layout_config    = {                -- this table shapes the horizontal layout
          prompt_position = "top",          -- this option places the prompt at the top of the window
          width = 0.80, height = 0.70,      -- this option sizes the picker window as a fraction of screen
          preview_width = 0.50,             -- this option gives half the width to the preview pane
        },
        winblend = 0,                       -- this option keeps text crisp; background comes from highlights
        -- borderchars = nil                -- (we keep default borders so the theme can style them)
      },
    },

    config = function(_, opts)
      local telescope = require("telescope")         -- this variable holds the Telescope module
      telescope.setup(opts)                          -- this call applies our minimal defaults

      -- Make Telescope honor transparent UI (works across themes)
      local grp = vim.api.nvim_create_augroup("Allen_Telescope_Transparent", { clear = true }) -- this group scopes our highlight fixes
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = grp,
        callback = function()                        -- this function ensures Telescope windows have no solid bg
          local set = vim.api.nvim_set_hl            -- this variable shortens highlight setting calls
          set(0, "TelescopeNormal",        { bg = "NONE" }) -- this group is the main Telescope window
          set(0, "TelescopeBorder",        { bg = "NONE" }) -- this group is the main window border
          set(0, "TelescopePromptNormal",  { bg = "NONE" }) -- this group is the prompt line window
          set(0, "TelescopePromptBorder",  { bg = "NONE" }) -- this group is the prompt border
          set(0, "TelescopeResultsNormal", { bg = "NONE" }) -- this group is the results list window
          set(0, "TelescopeResultsBorder", { bg = "NONE" }) -- this group is the results border
          set(0, "TelescopePreviewNormal", { bg = "NONE" }) -- this group is the preview window
          set(0, "TelescopePreviewBorder", { bg = "NONE" }) -- this group is the preview border
        end,
      })
      vim.api.nvim_exec_autocmds("ColorScheme", {})  -- this call applies the transparency immediately for current theme
    end,
  },
}
