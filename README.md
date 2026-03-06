### Allen's Neovim Personal Developer Environment ( PDE )

A personal Neovim distribution built for full-stack web development. Inspired by LazyVim's architecture but fully hand-crafted — no base distribution dependency.

---

## ✨ Features

- **Modern LSP** — Mason + mason-lspconfig with Neovim 0.11+ `vim.lsp.config()` API
- **Fast completion** — nvim-cmp + LuaSnip + lspkind with priority-weighted sources
- **Treesitter** — full highlight, indent, incremental selection, and folding
- **Git integration** — Gitsigns with full `<leader>g` namespace + Telescope pickers
- **Diagnostics panel** — Trouble.nvim v3 with workspace/buffer/qflist/symbols views
- **Fuzzy finding** — Telescope + fzf-native for fast file/grep/buffer search
- **Formatting** — conform.nvim with per-filetype formatters + Mason auto-install
- **Debug** — nvim-dap with vscode-js-debug (Node + Chrome) for JS/TS
- **Mini suite** — surround, ai text objects, operators, pairs, comment, indentscope, files
- **Floating terminal** — plugin-free VS Code-style run panel with filetype detection
- **Dashboard** — custom day-specific ASCII art dashboard with live plugin stats
- **Live server** — integrated live-server launcher for web development
- **Transparent UI** — consistent transparency across all floating windows and panels
- **Multi-theme** — Catppuccin (default) + TokyoNight + OneDark + Monokai Pro

---

## 📁 Structure

```
~/.config/nvim/
├── init.lua                    ← entry point (leaders → config → lazy → UI)
├── lazy-lock.json              ← pinned plugin versions (commit to repo)
└── lua/
    ├── config/
    │   ├── options.lua         ← vim options
    │   ├── keymaps.lua         ← global keymaps
    │   ├── autocmds.lua        ← autocommands
    │   ├── dashboard.lua       ← custom weekly ASCII dashboard
    │   ├── floating_terminal.lua ← VS Code-style run panel
    │   └── live-server.lua     ← live-server integration
    └── plugins/
        ├── cmp.lua             ← completion (nvim-cmp + LuaSnip)
        ├── colorscheme.lua     ← themes (Catppuccin, TokyoNight, OneDark, Monokai)
        ├── dap.lua             ← debugging (JS/TS Node + Chrome)
        ├── formatting.lua      ← conform.nvim + mason-tool-installer
        ├── gitsigns.lua        ← git signs + hunk actions
        ├── lsp-config.lua      ← Mason + LSP servers
        ├── mini-modules.lua    ← mini.nvim suite
        ├── noice.lua           ← UI overhaul (cmdline, messages, notify)
        ├── project.lua         ← project root detection
        ├── telescope.lua       ← fuzzy finder
        ├── treesitter.lua      ← syntax + text objects
        └── trouble.lua         ← diagnostics panel
```

---

## ⚡ Requirements

| Tool        | Version | Purpose                      |
| ----------- | ------- | ---------------------------- |
| Neovim      | ≥ 0.10  | Required                     |
| Git         | any     | Plugin management            |
| Node.js     | ≥ 18    | LSP servers, formatters, DAP |
| ripgrep     | any     | Telescope live grep          |
| fd          | any     | Telescope file finding       |
| make        | any     | fzf-native build             |
| A Nerd Font | any     | Icons                        |

### macOS install

```bash
brew install neovim git ripgrep fd node
brew install --cask font-jetbrains-mono-nerd-font
```

---

## 🚀 Install

```bash
# Backup existing config if present
mv ~/.config/nvim ~/.config/nvim.bak 2>/dev/null

# Clone
git clone https://github.com/YOUR_USERNAME/nvim-config.git ~/.config/nvim

# Launch — lazy.nvim bootstraps itself and installs all plugins
nvim
```

On first launch:

1. lazy.nvim clones itself
2. All plugins install automatically
3. Mason installs LSP servers and formatters
4. Dashboard opens when done

---

## ⌨️ Keymaps

> Leader key: `<Space>`

### 📁 Files & Navigation

| Key          | Action                              |
| ------------ | ----------------------------------- |
| `<leader>ff` | Find files (Telescope)              |
| `<leader>fg` | Live grep (ripgrep)                 |
| `<leader>fb` | Open buffers                        |
| `<leader>fh` | Help tags                           |
| `<leader>fr` | Recent files                        |
| `<leader>fc` | Commands                            |
| `<leader>fd` | Open dashboard                      |
| `<leader>fp` | Projects picker                     |
| `<leader>e`  | File explorer (mini.files CWD)      |
| `<leader>E`  | File explorer (reveal current file) |

### 🔤 LSP

| Key           | Action                       |
| ------------- | ---------------------------- |
| `gd`          | Go to definition             |
| `gD`          | Go to declaration            |
| `gr`          | LSP references (Trouble)     |
| `gi`          | Go to implementation         |
| `K`           | Hover docs                   |
| `<leader>lh`  | Signature help               |
| `<C-s>`       | Signature help (insert mode) |
| `<leader>lf`  | Format buffer                |
| `<leader>lr`  | Rename symbol                |
| `<leader>ca`  | Code action                  |
| `<leader>ih`  | Toggle inlay hints           |
| `<leader>lwa` | Workspace add folder         |
| `<leader>lwr` | Workspace remove folder      |
| `<leader>lwl` | Workspace list folders       |

### 🐛 Diagnostics

| Key          | Action                       |
| ------------ | ---------------------------- |
| `[d`         | Previous diagnostic          |
| `]d`         | Next diagnostic              |
| `gl`         | Show diagnostic float        |
| `<leader>xd` | Diagnostic float             |
| `<leader>dq` | Send diagnostics to quickfix |

### 🔍 Trouble (Diagnostics Panel)

| Key          | Action                |
| ------------ | --------------------- |
| `<leader>xx` | Workspace diagnostics |
| `<leader>xb` | Buffer diagnostics    |
| `<leader>xq` | Quickfix list         |
| `<leader>xl` | Location list         |
| `<leader>xs` | Document symbols      |
| `<leader>xR` | LSP references panel  |

### 🌿 Git (Gitsigns)

| Key          | Action                          |
| ------------ | ------------------------------- |
| `]h`         | Next hunk                       |
| `[h`         | Previous hunk                   |
| `<leader>gs` | Stage hunk                      |
| `<leader>gr` | Reset hunk                      |
| `<leader>gS` | Stage buffer                    |
| `<leader>gR` | Reset buffer                    |
| `<leader>gu` | Undo stage hunk                 |
| `<leader>gp` | Preview hunk inline             |
| `<leader>gb` | Blame line (full)               |
| `<leader>gt` | Toggle line blame               |
| `<leader>gd` | Diff against index              |
| `<leader>gD` | Diff against last commit        |
| `<leader>gf` | Git status (Telescope)          |
| `<leader>gc` | Git commits (Telescope)         |
| `ih`         | Hunk text object (`vih`, `dih`) |

### 🐞 DAP (Debugger)

| Key          | Action                 |
| ------------ | ---------------------- |
| `<F5>`       | Start / Continue       |
| `<F6>`       | Terminate              |
| `<F9>`       | Toggle breakpoint      |
| `<F10>`      | Step over              |
| `<F11>`      | Step into              |
| `<F12>`      | Step out               |
| `<leader>dB` | Conditional breakpoint |
| `<leader>dl` | Log point              |
| `<leader>du` | Toggle DAP UI          |
| `<leader>dr` | Toggle REPL            |

### 🖥️ Terminal & Runner

| Key          | Action                    |
| ------------ | ------------------------- |
| `<leader>t`  | Close terminal            |
| `<leader>tt` | Open terminal (big float) |
| `<leader>rc` | Run current file          |
| `<leader>rl` | Run current line          |
| `<leader>rv` | Run visual selection      |
| `<leader>rp` | Re-run last command       |

### 🌐 Live Server

| Key          | Action            |
| ------------ | ----------------- |
| `<leader>ol` | Start live server |
| `<leader>ok` | Stop live server  |

### ✂️ Surround (mini.surround)

| Key          | Action                  |
| ------------ | ----------------------- |
| `sa{motion}` | Add surround            |
| `sd{motion}` | Delete surround         |
| `sr{motion}` | Replace surround        |
| `sf`         | Find surround right     |
| `sF`         | Find surround left      |
| `sat`        | Add HTML/JSX tag        |
| `sa$`        | Wrap in `${}` template  |
| `sal`        | Wrap in `console.log()` |
| `sac`        | Wrap in `/* */` comment |

### 🎯 Text Objects (mini.ai)

| Key         | Action                            |
| ----------- | --------------------------------- |
| `ae` / `ie` | Around/inside entire buffer       |
| `aa` / `ia` | Around/inside function argument   |
| `af` / `if` | Around/inside function call       |
| `aF` / `iF` | Around/inside function definition |
| `ac` / `ic` | Around/inside class               |
| `at` / `it` | Around/inside HTML/JSX tag        |
| `g[` / `g]` | Jump to left/right edge of object |

### ⚙️ Operators (mini.operators)

| Key          | Action                |
| ------------ | --------------------- |
| `gx{motion}` | Exchange two regions  |
| `gr{motion}` | Replace with register |
| `gs{motion}` | Sort lines/words      |
| `gm{motion}` | Multiply (duplicate)  |
| `g={motion}` | Evaluate as Lua       |

### 🗂️ Splits & Buffers

| Key           | Action           |
| ------------- | ---------------- |
| `<leader>sv`  | Split vertical   |
| `<leader>sh`  | Split horizontal |
| `<leader>se`  | Equalize splits  |
| `<leader>sc`  | Close split      |
| `<C-h/j/k/l>` | Navigate splits  |
| `<leader>bd`  | Delete buffer    |
| `<leader>bn`  | Next buffer      |
| `<leader>bp`  | Previous buffer  |

### 🔧 Misc

| Key          | Action                      |
| ------------ | --------------------------- |
| `<leader>w`  | Save file                   |
| `<leader>qq` | Quit all                    |
| `<leader>nh` | Clear search highlight      |
| `<C-space>`  | Start incremental selection |
| `<C-s>`      | Expand/grow selection       |
| `<M-space>`  | Shrink selection            |
| `<C-k>`      | Snippet expand/jump forward |
| `<C-j>`      | Snippet jump backward       |
| `gcc`        | Toggle line comment         |
| `gc{motion}` | Toggle comment (motion)     |

---

## 🎨 Themes

Switch themes with `:colorscheme <name>`:

| Name                           | Command                            |
| ------------------------------ | ---------------------------------- |
| Catppuccin Macchiato (default) | `:colorscheme catppuccin`          |
| TokyoNight Storm               | `:colorscheme tokyonight`          |
| OneDark Darker                 | `:colorscheme onedark`             |
| Monokai Pro Octagon            | `:colorscheme monokai-pro-octagon` |
