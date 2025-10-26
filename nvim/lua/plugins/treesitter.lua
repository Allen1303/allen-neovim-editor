
-- ==============================
-- lua/plugins/treesitter.lua
-- ==============================

return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",                            -- this command updates parsers when plugin updates
    event = { "BufReadPost", "BufNewFile" },        -- this loads when you open/edit files (not at startup)
    opts = {
      -- parsers to install (add/remove to taste)
      ensure_installed = {
        "lua", "vim", "vimdoc", "query",            -- neovim internals
        "bash", "markdown", "markdown_inline",      -- docs / shell
        "json", "yaml", "toml",                     -- config files
        "html", "css", "javascript", "typescript", "tsx", -- web stack
        -- add others when needed        
        -- "python", "go", "rust", "java"
      },
      auto_install = true,                           -- this option auto-installs missing parsers on open buffer
      highlight = {
        enable = true,                               -- this option enables Treesitter-based syntax highlight
        additional_vim_regex_highlighting = false,   -- this option avoids duplicate highlights (faster/cleaner)
      },
      indent = {
        enable = true,                               -- this option enables indentation informed by syntax tree
        -- NOTE: Treesitter indent isn’t perfect for all languages; disable per-language if needed
      },
      incremental_selection = {
        enable = true,                               -- this option turns on semantic selection growth/shrink
        keymaps = {                                  -- this table defines intuitive keys:
          init_selection    = "<CR>",                -- this mapping starts selection at cursor
          node_incremental  = "<CR>",                -- this mapping expands to next node
          scope_incremental = "<S-CR>",              -- this mapping expands to next scope (like function/block)
          node_decremental  = "<BS>",                -- this mapping shrinks to previous node
        },
      },
    },
    config = function(_, opts)
      -- this call applies the options above
      require("nvim-treesitter.configs").setup(opts)

      -- Treesitter-based folds (off by default, consistent with options.lua)
      -- we use this autocommand to set foldexpr/foldmethod whenever a buffer with TS attaches
      local grp = vim.api.nvim_create_augroup("Allen_TreesitterFolds", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = grp,
        callback = function()
          -- these options tell Neovim to use Treesitter's fold expression
          vim.opt_local.foldmethod = "expr"
          vim.opt_local.foldexpr = "nvim_treesitter#foldexpr()"
          -- NOTE: folds remain disabled by default (from options.lua: foldenable=false).
          -- Toggle on demand with: :setlocal foldenable!
        end,
      })
    end,
  },

  -- Optional: better HTML/JSX auto-closing & renaming of tags
  {
    "windwp/nvim-ts-autotag",
    event = { "BufReadPost", "BufNewFile" },
    opts = { enable = true },                        -- this option turns on automatic tag closing/renaming
    config = function(_, opts)
      require("nvim-ts-autotag").setup(opts)
    end,
  },

  -- Optional (power user): Treesitter Playground for live AST debugging
  -- :TSPlaygroundToggle to inspect syntax tree & highlight groups
  {
    "nvim-treesitter/playground",
    cmd = { "TSPlaygroundToggle", "TSHighlightCapturesUnderCursor" },
  },
}
