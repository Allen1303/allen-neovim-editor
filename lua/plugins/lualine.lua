-- ==============================
-- lua/plugins/lualine.lua
-- ==============================
-- lualine: statusline with git branch, LSP diagnostics,
-- macro recording, and LSP client names — all out of the box

return {
  {
    "nvim-lualine/lualine.nvim",
    version      = false,
    lazy         = false,
    dependencies = { "nvim-mini/mini.icons" },
    opts         = {
      options = {
        theme                = "auto", -- matches your active colorscheme
        globalstatus         = true, -- single statusline across all windows
        disabled_filetypes   = { statusline = { "dashboard", "alpha" } },
        component_separators = { left = "", right = "" },
        section_separators   = { left = "", right = "" },
      },

      sections = {
        -- ── Left ──────────────────────────────────────────────────
        lualine_a = { "mode" },

        lualine_b = {
          { "branch", icon = "" }, -- git branch
          { "diff",   symbols = { added = " ", modified = " ", removed = " " } },
        },

        lualine_c = {
          { "filename", path = 1, symbols = { modified = "●", readonly = "", unnamed = "" } },
        },

        -- ── Right ─────────────────────────────────────────────────
        lualine_x = {
          -- Macro recording indicator
          {
            function()
              local reg = vim.fn.reg_recording()
              if reg ~= "" then return "  @" .. reg end
              return ""
            end,
            color = { fg = "#f38ba8" }, -- red — stands out when recording
          },

          -- LSP diagnostics
          {
            "diagnostics",
            sources = { "nvim_lsp" },
            symbols = { error = " ", warn = " ", hint = " ", info = " " },
          },

          -- LSP client names
          {
            function()
              local clients = vim.lsp.get_clients({ bufnr = 0 })
              if #clients == 0 then return "" end
              local names = {}
              for _, c in ipairs(clients) do
                if c.name ~= "null-ls" and c.name ~= "copilot" then
                  table.insert(names, c.name)
                end
              end
              if #names == 0 then return "" end
              return "󰒋 " .. table.concat(names, ", ")
            end,
          },
        },

        lualine_y = { "filetype" },
        lualine_z = { "location", "progress" },
      },

      -- Inactive windows show minimal info
      inactive_sections = {
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "location" },
      },
    },

    config       = function(_, opts)
      -- Redraw statusline when macro recording starts/stops
      local grp = vim.api.nvim_create_augroup("Allen_LualineMacro", { clear = true })
      vim.api.nvim_create_autocmd("RecordingEnter", { group = grp, callback = function() vim.cmd("redrawstatus") end })
      vim.api.nvim_create_autocmd("RecordingLeave", { group = grp, callback = function() vim.cmd("redrawstatus") end })
      require("lualine").setup(opts)
    end,
  },
}
