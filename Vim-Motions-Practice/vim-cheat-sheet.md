# Neovim Motions Cheat Sheet

> Quick reference for all motions and plugin commands covered in the practice file.
> Each section links to the corresponding drill. Start from the top and work down.

---

## Table of Contents

- [Mode Legend](#mode-legend)
- [Basic Motions](#basic-motions)
- [Marks & Jump List](#marks--jump-list)
- [Bracket Navigation](#bracket-navigation)
- [Search Motions](#search-motions)
- [Screen Positioning](#screen-positioning)
- [Visual Block Mode](#visual-block-mode)
- [Macros](#macros)
- [mini.ai — Text Objects](#miniai--text-objects)
- [mini.surround](#minisurround)
- [mini.operators](#minioperators)
- [mini.comment](#minicomment)
- [flash.nvim](#flashnvim)
- [bufferline](#bufferline)
- [Harpoon](#harpoon)
- [Neogit & Diffview](#neogit--diffview)
- [todo-comments](#todo-comments)
- [Aerial](#aerial)
- [Custom Keymaps](#custom-keymaps)

---

## Mode Legend

| Label          | How to enter                            |
| -------------- | --------------------------------------- |
| `NORMAL`       | Press `<Esc>`                           |
| `INSERT`       | Press `i`, `a`, `o`, or `O` from Normal |
| `VISUAL`       | Press `v` from Normal                   |
| `VISUAL LINE`  | Press `V`(capital "V") from Normal      |
| `VISUAL BLOCK` | Press `<Ctrl+v>` from Normal            |

---

## Basic Motions

### Character jumps — `f` `F` `t` `T`

| Key       | What it does                                   |
| --------- | ---------------------------------------------- |
| `f{char}` | Jump forward, land **on** the char             |
| `t{char}` | Jump forward, land **before** the char         |
| `F{char}` | Jump backward, land **on** the char            |
| `T{char}` | Jump backward, land **after** the char         |
| `;`       | Repeat last jump in the **same** direction     |
| `,`       | Repeat last jump in the **opposite** direction |

**Example:** On the line `local name, lastName, age = "Allen"`

- `fa` → lands on `a` in `name`
- `;` → jumps to next `a` in `lastName`
- `,` → jumps back

### Word motions

| Key         | What it does                                             |
| ----------- | -------------------------------------------------------- |
| `w`         | Jump to start of next word                               |
| `b`         | Jump to start of previous word                           |
| `e`         | Jump to end of current/next word                         |
| `W` `B` `E` | Same but treats WORD as whole (stops only at whitespace) |
| `iw`        | Select inner word (no surrounding spaces)                |
| `iW`        | Select inner WORD (includes dots, dashes)                |

### Line motions

| Key         | What it does              |
| ----------- | ------------------------- |
| `0`         | Start of line             |
| `^`         | First non-blank character |
| `$`         | End of line               |
| `gg`        | Top of file (centered)    |
| `G`         | Bottom of file (centered) |
| `{number}G` | Jump to line number       |

### Scroll motions

| Key     | What it does              |
| ------- | ------------------------- |
| `<C-d>` | Half page down (centered) |
| `<C-u>` | Half page up (centered)   |
| `<C-f>` | Full page down            |
| `<C-b>` | Full page up              |

---

## Marks & Jump List

| Key          | What it does                               |
| ------------ | ------------------------------------------ |
| `m{a-z}`     | Set mark at cursor position                |
| `` `{a-z} `` | Jump to **exact column** of mark           |
| `'{a-z}`     | Jump to **line** of mark (first non-blank) |
| `<C-o>`      | Jump **backward** through jump list        |
| `<C-i>`      | Jump **forward** through jump list         |
| `g;`         | Jump to previous change position           |
| `g,`         | Jump to next change position               |

**Tip:** Use marks to bounce between two distant locations — set `ma` at point A and `mb` at point B, then `` `a `` and `` `b `` to jump between them instantly.

---

## Bracket Navigation

| Key         | What it does                               |
| ----------- | ------------------------------------------ |
| `[{`        | Jump to opening `{` of enclosing block     |
| `]}`        | Jump to closing `}` of enclosing block     |
| `[(`        | Jump to opening `(` of enclosing group     |
| `])`        | Jump to closing `)` of enclosing group     |
| `[m`        | Jump to start of function/method **above** |
| `]m`        | Jump to start of **next** function/method  |
| `%`         | Jump to matching bracket pair              |
| `[q` / `]q` | Prev / next quickfix item                  |
| `[d` / `]d` | Prev / next diagnostic                     |
| `[b` / `]b` | Prev / next buffer (bufferline)            |

---

## Search Motions

| Key        | What it does                                 |
| ---------- | -------------------------------------------- |
| `/pattern` | Search forward                               |
| `?pattern` | Search backward                              |
| `n`        | Next match (centered)                        |
| `N`        | Previous match (centered)                    |
| `*`        | Search word under cursor forward (centered)  |
| `#`        | Search word under cursor backward (centered) |
| `<Esc>`    | Clear search highlight                       |

### `gn` / `gN` — select next match as motion

| Key   | What it does                                                |
| ----- | ----------------------------------------------------------- |
| `gn`  | Select next search match (visual)                           |
| `gN`  | Select previous search match                                |
| `cgn` | Change next match — then `.` repeats on every following one |
| `dgn` | Delete next match — then `.` repeats                        |

**Tip:** Search for a word, then `cgn` + type replacement + `<Esc>`, then `.` to replace each occurrence one by one.

---

## Screen Positioning

| Key  | What it does                                |
| ---- | ------------------------------------------- |
| `H`  | Move cursor to **top** of visible screen    |
| `M`  | Move cursor to **middle** of visible screen |
| `L`  | Move cursor to **bottom** of visible screen |
| `zt` | Scroll current line to **top** of window    |
| `zz` | Scroll current line to **center** of window |
| `zb` | Scroll current line to **bottom** of window |

**Common combos:**

- `L` then `zt` — pull the bottom line to the top
- `H` then `zb` — push the top line to the bottom

---

## Visual Block Mode

> Enter with `<C-v>` from Normal mode

| Key            | What it does                                    |
| -------------- | ----------------------------------------------- |
| `I{text}<Esc>` | Insert at **start** of every selected line      |
| `A{text}<Esc>` | Append at **end** of every selected line        |
| `c{text}<Esc>` | Replace selected columns on every line          |
| `d`            | Delete selected columns on every line           |
| `r{char}`      | Replace every character in block with `{char}`  |
| `~`            | Toggle case on the entire block                 |
| `>` / `<`      | Indent / dedent every line in the block         |
| `$`            | Extend selection to end of each line            |
| `<C-a>`        | Increment all numbers in block by 1             |
| `g<C-a>`       | **Sequentially** increment numbers (1, 2, 3...) |

**Tip:** `$` + `A` is the combo for appending to lines of uneven length — `$` handles the different line lengths automatically.

---

## Macros

| Key               | What it does                              |
| ----------------- | ----------------------------------------- |
| `q{a-z}`          | Start recording into register `{a-z}`     |
| `q`               | Stop recording                            |
| `@{a-z}`          | Replay register once                      |
| `@@`              | Replay the last-used register             |
| `{count}@{a-z}`   | Replay register `{count}` times           |
| `:%normal @{a-z}` | Apply macro to every line in the file     |
| `q{A-Z}`          | **Append** to register (capital = append) |

**Golden rule:** Always end your macro by moving to the **next target** (press `j` or `]m`) so replaying with a count works automatically.

---

## mini.ai — Text Objects

> Combine with `d` (delete), `c` (change), `v` (visual), `y` (yank)

| Object         | What it targets                                  |
| -------------- | ------------------------------------------------ |
| `iw` / `aw`    | Inner / around word                              |
| `iq` / `aq`    | Inner / around nearest quote `" ' `` `           |
| `ib` / `ab`    | Inner / around nearest bracket `( [ {`           |
| `if` / `af`    | Inner / around function call parens + args       |
| `iF` / `aF`    | Inner / around function **definition** body      |
| `ia` / `aa`    | Single function argument (comma-aware)           |
| `it` / `at`    | Inner / around HTML/JSX tag                      |
| `ie` / `ae`    | Entire buffer                                    |
| `ic` / `ac`    | Inner / around class definition                  |
| `in` / `an`    | Same object but targets the **next** one forward |
| `il` / `al`    | Same object but targets the **previous** one     |
| `g[` + `{obj}` | Jump to **left** edge of object                  |
| `g]` + `{obj}` | Jump to **right** edge of object                 |

**Examples:**

- `dif` — delete everything inside function call parens
- `caa` — change argument including its comma
- `vit` — visually select text inside HTML tag
- `g]b` — jump to closing `}` of nearest bracket

---

## mini.surround

| Key                | What it does                        |
| ------------------ | ----------------------------------- |
| `sa{motion}{char}` | **Add** surround around motion      |
| `sd{char}`         | **Delete** surrounding character    |
| `sr{old}{new}`     | **Replace** surrounding character   |
| `sf{char}`         | **Find** next surrounding           |
| `sF{char}`         | **Find** previous surrounding       |
| `sh{char}`         | **Highlight** surrounding (preview) |

**Common surrounds:**
| Char | What it wraps with |
|---|---|
| `"` | Double quotes |
| `'` | Single quotes |
| `` ` `` | Backticks |
| `(` | Parentheses with spaces `( )` |
| `)` | Parentheses without spaces `()` |
| `{` | Curly braces with spaces `{ }` |
| `[` | Square brackets |
| `t` | HTML/JSX tag (prompts for tag name) |
| `$` | Template literal `${ }` |
| `l` | `console.log( )` |

**Examples:**

- `saiw"` — wrap word in double quotes
- `sd"` — remove surrounding double quotes
- `sr"'` — swap double quotes for single quotes
- `saip(` — wrap paragraph in parentheses

---

## mini.operators

> All operators work from Normal mode and support `.` dot-repeat

| Key          | What it does                                          |
| ------------ | ----------------------------------------------------- |
| `gx{motion}` | **Exchange** — mark first region, then second to swap |
| `gr{motion}` | **Replace** with register content (yank preserved)    |
| `gs{motion}` | **Sort** lines or delimited words                     |
| `gm{motion}` | **Multiply** (duplicate) text in place                |
| `g={motion}` | **Evaluate** Lua expression, replace with result      |

**Examples:**

- `gxia` → `gxia` — swap two function arguments
- `gxiw` → `gxiw` — swap two words
- `yiw` then `griw` — replace word with yanked content
- `gsip` — sort paragraph of lines alphabetically
- `gmm` — duplicate current line
- Visual select expression then `g=` — evaluate and replace

---

## mini.comment

| Key          | What it does                       |
| ------------ | ---------------------------------- |
| `gcc`        | Toggle comment on current line     |
| `gc{motion}` | Toggle comment on motion range     |
| `gcip`       | Comment inner paragraph            |
| `gcif`       | Comment inner function body        |
| `gcaF`       | Comment entire function definition |
| `gbc`        | Block comment current line `/* */` |
| `gc`         | `VISUAL` — comment the selection   |

**Tip:** `gc` shares text objects with `mini.ai` — any object you can `d` or `v`, you can also `gc`.

---

## flash.nvim

> Jump anywhere on screen in 2-3 keystrokes

| Key | Mode                         | What it does                               |
| --- | ---------------------------- | ------------------------------------------ |
| `s` | Normal / Visual / Op-pending | Flash jump — type 2 chars, pick label      |
| `S` | Normal / Visual / Op-pending | Flash treesitter — jump to any AST node    |
| `r` | Op-pending                   | Remote flash — operate on distant location |
| `R` | Op-pending / Visual          | Treesitter search across window            |

**How to use:**

1. Press `s`
2. Type 2 characters of your target
3. Labels appear on every match — press the label letter to jump

**Combined with operators:**

- `ds{label}` — delete from cursor to flash target
- `ys{label}` — yank from cursor to flash target

---

## bufferline

> VSCode-style buffer tabs at the top of the screen

| Key          | What it does                        |
| ------------ | ----------------------------------- |
| `[b` / `]b`  | Cycle to prev / next buffer         |
| `[B` / `]B`  | Move buffer left / right in tab bar |
| `<leader>bp` | Toggle pin (pinned tabs stay left)  |
| `<leader>bo` | Close all other unpinned buffers    |
| `<leader>br` | Close buffers to the right          |
| `<leader>bl` | Close buffers to the left           |
| `<leader>ba` | Delete all buffers                  |

---

## Harpoon

> Pin up to 5 files and jump to them instantly

| Key                | What it does                          |
| ------------------ | ------------------------------------- |
| `<leader>ha`       | Add current file to harpoon list      |
| `<leader>hh`       | Open harpoon menu (edit/reorder list) |
| `<C-1>` to `<C-5>` | Jump directly to pinned file 1–5      |
| `<leader>hn`       | Next harpoon file                     |
| `<leader>hp`       | Previous harpoon file                 |

**Workflow:** Pin your 3-4 active files with `<leader>ha`, then jump between them instantly with `<C-1>` etc. No searching needed.

---

## Neogit & Diffview

> Full git workflow without leaving Neovim

### Opening

| Key          | What it does                                 |
| ------------ | -------------------------------------------- |
| `<leader>gg` | Open Neogit dashboard                        |
| `<leader>gD` | Open Diffview (all changes vs HEAD)          |
| `<leader>gh` | File history (every commit for current file) |
| `<leader>gH` | Repo history (all commits)                   |
| `<leader>gx` | Close Diffview                               |

### Inside Neogit

| Key          | What it does                 |
| ------------ | ---------------------------- |
| `s`          | Stage file/hunk under cursor |
| `u`          | Unstage file/hunk            |
| `<Tab>`      | Expand / collapse section    |
| `c` then `c` | Open commit editor           |
| `:wq`        | Submit commit message        |
| `P` then `p` | Push to origin               |
| `q`          | Close Neogit                 |

### Commit workflow

1. `<leader>gg` — open Neogit
2. `s` on file — stage it
3. `c` then `c` — open commit editor
4. Type message then `:wq` — submit
5. `P` then `p` — push to GitHub
6. `q` — close

---

## todo-comments

> Highlights and navigates special keywords in your code

| Keyword              | Color  | Meaning           |
| -------------------- | ------ | ----------------- |
| `TODO:`              | Blue   | Work to be done   |
| `FIXME:` / `BUG:`    | Red    | Broken code       |
| `HACK:`              | Orange | Workaround        |
| `NOTE:` / `INFO:`    | Green  | Important context |
| `PERF:` / `OPTIM:`   | Purple | Performance issue |
| `WARN:` / `WARNING:` | Yellow | Caution           |

| Key          | What it does                    |
| ------------ | ------------------------------- |
| `]t`         | Jump to next TODO               |
| `[t`         | Jump to previous TODO           |
| `<leader>xt` | Show all TODOs in Trouble panel |
| `<leader>ft` | Search TODOs with Telescope     |

---

## Aerial

> Code outline — see and navigate all symbols in a file

| Key          | What it does                  |
| ------------ | ----------------------------- |
| `<leader>cs` | Toggle aerial sidebar         |
| `<leader>cS` | Search symbols with Telescope |
| `{`          | Jump to previous symbol       |
| `}`          | Jump to next symbol           |

### Inside aerial sidebar

| Key       | What it does           |
| --------- | ---------------------- |
| `j` / `k` | Navigate symbols       |
| `<CR>`    | Jump to symbol         |
| `o`       | Toggle fold            |
| `l` / `h` | Open / close tree node |
| `q`       | Close aerial           |

---

## Custom Keymaps

### File operations

| Key         | What it does                             |
| ----------- | ---------------------------------------- |
| `<leader>w` | Save file (only if modified)             |
| `<leader>e` | Open file explorer (CWD)                 |
| `<leader>E` | Open file explorer (reveal current file) |

### Window splits

| Key                    | What it does                             |
| ---------------------- | ---------------------------------------- |
| `<leader>sv`           | Split vertical                           |
| `<leader>sh`           | Split horizontal                         |
| `<leader>se`           | Equalize splits                          |
| `<leader>sx`           | Close split                              |
| `<C-h/j/k/l>`          | Focus left/down/up/right window          |
| `<C-w>H/J/K/L`         | Move window to far left/bottom/top/right |
| `<C-w>x`               | Swap current window with next            |
| `<leader><Up/Down>`    | Increase/decrease window height          |
| `<leader><Left/Right>` | Decrease/increase window width           |

### Line editing

| Key               | What it does                           |
| ----------------- | -------------------------------------- |
| `J`               | Join lines (cursor stays put)          |
| `<A-j>` / `<A-k>` | Move line or selection up/down         |
| `<` / `>`         | Indent/dedent (keeps visual selection) |
| `Y`               | Yank to end of line (like `D`/`C`)     |
| `<leader>D`       | Delete without yanking                 |
| `<leader>p`       | Paste without clobbering yank register |

### Search & replace

| Key                   | What it does                                      |
| --------------------- | ------------------------------------------------- |
| `<Esc>`               | Clear search highlight                            |
| `<leader>sr`          | Search & replace word under cursor (project-wide) |
| `<leader>sr` (visual) | Search & replace in selection only                |

### Session

| Key          | What it does                          |
| ------------ | ------------------------------------- |
| `<leader>qs` | Restore session for current directory |
| `<leader>ql` | Restore last session                  |
| `<leader>qd` | Stop saving session                   |
| `<leader>qq` | Quit window                           |
| `<leader>qQ` | Force quit all                        |

### Yank path utilities

| Key          | What it does                     |
| ------------ | -------------------------------- |
| `<leader>yp` | Copy full file path to clipboard |
| `<leader>yr` | Copy relative file path          |
| `<leader>yn` | Copy filename only               |
| `<leader>yd` | Copy file directory              |

### Git (gitsigns)

| Key          | What it does         |
| ------------ | -------------------- |
| `<leader>gg` | Open Neogit          |
| `<leader>gD` | Open Diffview        |
| `<leader>gh` | File git history     |
| `]g` / `[g`  | Next / prev git hunk |

### LSP

| Key          | What it does          |
| ------------ | --------------------- |
| `gd`         | Go to definition      |
| `gD`         | Go to declaration     |
| `gr`         | List references       |
| `gi`         | Go to implementation  |
| `K`          | Hover docs            |
| `<leader>ca` | Code action           |
| `<leader>lr` | Rename symbol         |
| `<leader>lf` | Format buffer         |
| `gl`         | Show line diagnostics |
| `<leader>ih` | Toggle inlay hints    |

### Noice UI

| Key          | What it does         |
| ------------ | -------------------- |
| `<leader>nd` | Dismiss all messages |
| `<leader>nh` | Show message history |

---

## Quick Tips for Beginners

**Start with these 5 — learn everything else gradually:**

1. `hjkl` — basic movement (left/down/up/right)
2. `w` / `b` — jump between words
3. `i` / `<Esc>` — enter and exit insert mode
4. `u` / `<C-r>` — undo / redo
5. `:w` — save file

**Then add these 5:**

1. `f{char}` + `;` — jump to character on line
2. `ciw` / `diw` — change/delete inner word
3. `dd` / `yy` / `p` — cut line / copy line / paste
4. `/search` + `n` — search and navigate
5. `gg` / `G` — top / bottom of file

**The power combos to internalize:**

- `ci"` — change inside quotes
- `da(` — delete around parentheses
- `cgn` + `.` — iterative search and replace
- `V` + `>` — indent a block
- `qq` + `@q` — record and replay a macro
