# ⌨️ Keymap Reference

> Leader: `<Space>` | Local Leader: `<Space>`

---

## Navigation

| Key          | Action                             | File              |
| ------------ | ---------------------------------- | ----------------- |
| `<leader>ff` | Find files                         | telescope         |
| `<leader>fg` | Live grep                          | telescope         |
| `<leader>fb` | Buffers                            | telescope         |
| `<leader>fh` | Help tags                          | telescope         |
| `<leader>fr` | Recent files                       | telescope         |
| `<leader>fc` | Commands                           | telescope         |
| `<leader>fd` | Dashboard                          | dashboard         |
| `<leader>fp` | Projects                           | telescope/project |
| `<leader>e`  | Explorer CWD                       | mini.files        |
| `<leader>E`  | Explorer (reveal file)             | mini.files        |
| `<C-j>`      | Move selection down                |
| `<C-k>`      | Move selection up                  |
| `<C-u>`      | Scroll preview up                  |
| `<C-d>`      | Scroll preview down                |
| `<Esc>`      | Exit insert mode (j/k to navigate) |
| `q`          | Clos e picker                      |

---

## LSP `<leader>l`

| Key            | Action                  |
| -------------- | ----------------------- |
| `gd`           | Definition              |
| `gD`           | Declaration             |
| `gr`           | References (Trouble)    |
| `gi`           | Implementation          |
| `K`            | Hover docs              |
| `<leader>lh`   | Signature help          |
| `<C-s>`        | Signature help (insert) |
| `<leader>lf`   | Format buffer           |
| `<leader>lr`   | Rename symbol           |
| `<leader>ca`   | Code action             |
| `<leader>ih`   | Toggle inlay hints      |
| `<leader>lwa ` | Workspace add           |
| `<leader>lwr ` | Workspace remove        |
| `<leader>lwl ` | Workspace list          |

---

## Diagnostics `<leader>x` / `<leader>d`

| Key          | Action                  |
| ------------ | ----------------------- |
| `[d` / `]d`  | Prev/next diagnostic    |
| `gl`         | Diagnostic float        |
| `<leader>xd` | Diagnostic float        |
| `<leader>dq` | Send to quickfix        |
| `<leader>xx` | Workspace diagnostics   |
| `<leader>xb` | Buffer diagnostics      |
| `<leader>xq` | Quickfix list (Trouble) |
| `<leader>xl` | Location list           |
| `<leader>xs` | Document symbols        |
| `<leader>xR` | LSP references panel    |

---

## Git `<leader>g`

| Key          | Action                  |
| ------------ | ----------------------- |
| `]h` / `[h`  | Next/prev hunk          |
| `<leader>gs` | Stage hunk              |
| `<leader>gr` | Reset hunk              |
| `<leader>gS` | Stage buffer            |
| `<leader>gR` | Reset buffer            |
| `<leader>gu` | Undo stage              |
| `<leader>gp` | Preview hunk            |
| `<leader>gb` | Blame line              |
| `<leader>gt` | Toggle blame            |
| `<leader>gd` | Diff index              |
| `<leader>gD` | Diff last commit        |
| `<leader>gf` | Git status (Telescope)  |
| `<leader>gc` | Git commits (Telescope) |
| `ih`         | Hunk text object        |

---

## DAP `<F*>` / `<leader>d`

| Key          | Action                 |
| ------------ | ---------------------- |
| `<F5>`       | Start/Continue         |
| `<F6>`       | Terminate              |
| `<F9>`       | Toggle breakpoint      |
| `<F10>`      | Step over              |
| `<F11>`      | Step into              |
| `<F12>`      | Step out               |
| `<leader>dB` | Conditional breakpoint |
| `<leader>dl` | Log point              |
| `<leader>du` | DAP UI toggle          |
| `<leader>dr` | REPL toggle            |

---

## Terminal & Runner `<leader>t` / `<leader>r`

| Key          | Action         |
| ------------ | -------------- |
| `<leader>t`  | Close terminal |
| `<leader>tt` | Open terminal  |
| `<leader>rc` | Run file       |
| `<leader>rl` | Run line       |
| `<leader>rv` | Run selection  |
| `<leader>rp` | Re-run last    |

---

## Live Server `<leader>o`

| Key          | Action            |
| ------------ | ----------------- |
| `<leader>ol` | Start live server |
| `<leader>ok` | Stop live server  |

---

## Surround `s*`

| Key         | Action           |
| ----------- | ---------------- |
| `sa{m}`     | Add surround     |
| `sd{m}`     | Delete surround  |
| `sr{m}`     | Replace surround |
| `sf` / `sF` | Find right/left  |
| `sat`       | HTML/JSX tag     |
| `sa$`       | Template `${}`   |
| `sal`       | `console.log()`  |
| `sac`       | `/* */` comment  |

---

## Text Objects `a*` / `i*`

| Key         | Action              |
| ----------- | ------------------- |
| `ae/ie`     | Entire buffer       |
| `aa/ia`     | Function argument   |
| `af/if`     | Function call       |
| `aF/iF`     | Function definition |
| `ac/ic`     | Class               |
| `at/it`     | HTML/JSX tag        |
| `g[` / `g]` | Jump to object edge |

---

## Operators `g*`

| Key     | Action                |
| ------- | --------------------- |
| `gx{m}` | Exchange regions      |
| `gr{m}` | Replace with register |
| `gs{m}` | Sort                  |
| `gm{m}` | Duplicate             |
| `g={m}` | Evaluate Lua          |

---

## Splits & Buffers

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

---

## Misc

| Key          | Action                |
| ------------ | --------------------- |
| `<leader>w`  | Save                  |
| `<leader>qq` | Quit all              |
| `<leader>nh` | Clear highlight       |
| `gcc`        | Toggle line comment   |
| `gc{m}`      | Toggle comment        |
| `<C-space>`  | Start selection       |
| `<C-s>`      | Grow selection        |
| `<M-space>`  | Shrink selection      |
| `<C-k>`      | Snippet expand/jump → |
| `<C-j>`      | Snippet jump ←        |
| `<C-n/p>`    | Completion next/prev  |
| `<CR>`       | Confirm completion    |
| `<C-e>`      | Abort completion      |
