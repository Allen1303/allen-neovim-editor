
-- ==============================
-- lua/plugins/formatting.lua
-- ==============================
-- - Run fast, reliable formatters per filetype
-- - Format on save with LSP fallback (so you always get something)

return {
  {
    "stevearc/conform.nvim",                        -- this plugin runs external formatters
    event = { "BufWritePre" },                      -- this option loads before saving a file
    cmd = { "ConformInfo" },                        -- this command shows resolved formatters
    opts = {
      -- map filetypes → preferred formatters (first available wins)
      formatters_by_ft = {
        lua        = { "stylua" },
        python     = { "ruff_format", "black" },    -- ruff_format is very fast; black as fallback
        javascript = { "prettierd", "prettier", "biome" },
        typescript = { "prettierd", "prettier", "biome" },
        javascriptreact = { "prettierd", "prettier", "biome" },
        typescriptreact = { "prettierd", "prettier", "biome" },
        json       = { "prettierd", "prettier", "biome" },
        yaml       = { "prettierd", "prettier" },
        html       = { "prettierd", "prettier" },
        css        = { "prettierd", "prettier" },
        markdown   = { "prettierd", "prettier" },
        sh         = { "shfmt" },
      },

      -- format-on-save with graceful fallbacks
      format_on_save = function(bufnr)
        -- this function lets us skip big/minified files, etc., later if we want
        return { lsp_fallback = true, timeout_ms = 1000 } -- this option asks LSP to format if no external tool
      end,

      -- optional per-formatter arguments (tweak to taste)
      formatters = {
        shfmt = { prepend_args = { "-i", "2", "-ci" } },  -- 2-space indent, case indent
        black = { prepend_args = { "--quiet", "--line-length", "100" } },
      },
    },
    config = function(_, opts)
      require("conform").setup(opts)

      -- Tiny helper: :Format to run formatting manually
      vim.api.nvim_create_user_command("Format", function()
        require("conform").format({ async = false, lsp_fallback = true })
      end, { desc = "Format current buffer" })
    end,
  },
}
