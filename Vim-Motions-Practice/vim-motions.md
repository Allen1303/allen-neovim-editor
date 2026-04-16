# Neovim Mastery — Intermediate → Advanced Practice

> Work through each section top to bottom. Each drill is self-contained.
> After completing a drill, press `u` to undo and reset before the next one.
> Later sections build on earlier ones — don't skip ahead.

---

## Mode Legend

| Label          | Meaning                                                |
| -------------- | ------------------------------------------------------ |
| `NORMAL`       | Press `<Esc>` first to ensure you are in Normal mode   |
| `VISUAL`       | Press `v` from Normal mode (characterwise selection)   |
| `VISUAL LINE`  | Press `V` from Normal mode (whole-line selection)      |
| `VISUAL BLOCK` | Press `<leader-v>` from Normal mode (column selection) |
| `INSERT`       | Press `i`, `a`, `o`, or `O` from Normal mode           |

---

## Active Plugins & Keys

### mini.surround

| Key                | Action                                  |
| ------------------ | --------------------------------------- |
| `sa{motion}{char}` | Add surround                            |
| `sd{char}`         | Delete surround                         |
| `sr{old}{new}`     | Replace surround                        |
| `sf` / `sF`        | Find next / prev surrounding            |
| `sh{char}`         | Highlight / flash (preview before edit) |
| `sn`               | Update search radius                    |

### mini.ai — text objects (combine with `d` `c` `v` `y`)

| Object      | What it targets                              |
| ----------- | -------------------------------------------- |
| `f`         | Function call parens + args                  |
| `F`         | Function definition body                     |
| `a`         | Single function argument                     |
| `e`         | Entire buffer                                |
| `t`         | HTML / JSX tag                               |
| `q`         | Any quote `" ' `` ` — nearest wins           |
| `b`         | Any bracket `( [ {` — nearest wins           |
| `an` / `in` | Same but targets the **next** object forward |
| `al` / `il` | Same but targets the **previous** object     |
| `g[` / `g]` | Jump to left / right edge of object          |

### mini.operators

| Key          | Action                                                |
| ------------ | ----------------------------------------------------- |
| `gx{motion}` | **Exchange** — two consecutive calls swap the regions |
| `gr{motion}` | **Replace** with register content                     |
| `gs{motion}` | **Sort** lines or delimited words                     |
| `gm{motion}` | **Multiply** (duplicate) text in place                |
| `g={motion}` | **Evaluate** expression, replace with result          |

### mini.comment

| Key          | Action                                       |
| ------------ | -------------------------------------------- |
| `gcc`        | Toggle comment on current line               |
| `gc{motion}` | Toggle comment on motion range — e.g. `gcip` |
| `gbc`        | Block comment current line `/* */`           |
| `gc`         | `VISUAL` — comment the selection             |

### keymaps (keymaps.lua)

| Key               | Action                                   |
| ----------------- | ---------------------------------------- |
| `J`               | Join lines, cursor stays put             |
| `n` / `N`         | Next / prev match, centered              |
| `*` / `#`         | Search word forward / backward, centered |
| `<C-d>` / `<C-u>` | Half-page scroll, centered               |
| `<A-j>` / `<A-k>` | Move line or selection up / down         |
| `<` / `>`         | Indent / dedent, keeps visual selection  |
| `<leader>s`       | Search & replace word under cursor       |
| `<leader>p`       | Paste without clobbering yank register   |
| `<leader>d`       | Delete to black hole register (no yank)  |
| `gg` / `G`        | Top / bottom, centered                   |

---

## §1 — Intermediate Motions: `f` `F` `t` `T` `;` `,`

| Key       | Behaviour                                             |
| --------- | ----------------------------------------------------- |
| `f{char}` | Jump forward — cursor lands **on** the char           |
| `t{char}` | Jump forward — cursor lands **before** the char       |
| `F{char}` | Jump backward — cursor lands **on** the char          |
| `T{char}` | Jump backward — cursor lands **after** the char       |
| `;`       | Repeat last `f / F / t / T` in the same direction     |
| `,`       | Repeat last `f / F / t / T` in the opposite direction |

---

### Drill 1a — jump forward with `f`, repeat with `;`

**Mode:** `NORMAL`

**Keystrokes:**

1. Place cursor at the very start of the line
2. Type `fa` — cursor jumps forward and lands **on** the `a` in `name`
3. Type `;` — cursor jumps to the next `a` in `lastName`
4. Type `;` again — cursor jumps to the `a` in `age`
5. Type `,` — cursor jumps **back** one `a`

```lua
local name, lastName, age = "Allen", "Iverson", 33
```

---

### Drill 1b — precise positioning with `t,` then change

**Mode:** `NORMAL`

**Keystrokes:**

1. Cursor anywhere on the line
2. Type `t,` — cursor lands **just before** the first comma
3. Type `ct,` — deletes everything from cursor up to (not including) the comma and drops into `INSERT` mode
4. Type your replacement value, then press `<Esc>`
5. Type `;` to jump to the next comma and repeat

```lua
local config = { host = "localhost", port = 3000, debug = false }
```

---

### Drill 1c — jump backward with `F(` then match pair with `%`

**Mode:** `NORMAL`

**Keystrokes:**

1. Place cursor anywhere **inside** the inner `math.min(...)` call
2. Type `F(` — cursor jumps backward and lands **on** the nearest `(`
3. Type `%` — cursor jumps to the **matching** closing `)`
4. Type `F(` again — jumps to the outer `math.max(`
5. Type `%` — jumps to its matching `)`

```lua
local result = math.max(math.min(value, 100), 0)
```

---

### Drill 1d — combine `f(` + `vi(` + `c`

**Mode:** `NORMAL`

**Keystrokes:**

1. Cursor anywhere on the word `parseFloat`
2. Type `f(` — cursor jumps forward onto the `(`
3. Type `vi(` — switches to `VISUAL`, selects everything **inside** the parens
4. Type `c` — deletes the selection and drops into `INSERT` mode
5. Type your new argument, then press `<Esc>`

```lua
local parsed = parseFloat(rawInput.trim())
```

---

## §2 — Intermediate Motions: Marks and Jump List

| Key      | Behaviour                                                     |
| -------- | ------------------------------------------------------------- |
| `ma`     | `NORMAL` — set mark `a` at the exact cursor position          |
| `'a`     | `NORMAL` — jump to the **line** of mark `a` (first non-blank) |
| `` `a `` | `NORMAL` — jump to the **exact column** of mark `a`           |
| `<C-o>`  | `NORMAL` — jump backward through the jump list                |
| `<C-i>`  | `NORMAL` — jump forward through the jump list                 |
| `g;`     | `NORMAL` — jump to the **previous** change position           |
| `g,`     | `NORMAL` — jump to the **next** change position               |

---

### Drill 2a — set a mark, scroll away, return precisely

**Mode:** `NORMAL` throughout

**Keystrokes:**

1. Place cursor on the word `startHere`
2. Type `ma` — mark `a` is now set at this exact column
3. Type `<C-d>` twice — scrolls down past the padding lines
4. Type `` `a `` (backtick then `a`) — cursor jumps back to the **exact column** on `startHere`
5. Now try `'a` (apostrophe then `a`) — jumps to the line but lands on the beginning of the line 'non-blank 'character instead

```lua
local startHere = "mark this line with  ma"

local padding_1 = nil
local padding_2 = nil
local padding_3 = nil
local padding_4 = nil
local padding_5 = nil

local endHere = "then jump back up to startHere with `a"
```

---

### Drill 2b — bounce between two distant functions

**Mode:** `NORMAL` throughout

**Keystrokes:**

1. Place cursor inside the first function body on the `validated` line
2. Type `mb` — mark `b` is set here
3. Scroll down to the second function (use `<C-d>` or `]m`)
4. Place cursor inside the second function body on the `total` line
5. Type `mc` — mark `c` is set here
6. Type `` `b `` — jumps instantly back to the exact position in the first function
7. Type `` `c `` — jumps instantly back to the second function
8. Repeat `` `b `` and `` `c `` several times to build the muscle memory

```lua
local function processUser(user)
  -- SET MARK b HERE — type  mb  on this line
  local validated = validateEmail(user.email)
  return { id = user.id, valid = validated }
end

-- ... imagine many lines of code here ...

local function processOrder(order)
  -- SET MARK c HERE — type  mc  on this line
  local total = calculateTotal(order.items)
  return { orderId = order.id, total = total }
end
```

---

## §3 — Intermediate Motions: `[` `]` Bracket Family

| Key         | Behaviour                                            |
| ----------- | ---------------------------------------------------- |
| `[{`        | Jump to the opening `{` of the enclosing block       |
| `]}`        | Jump to the closing `}` of the enclosing block       |
| `[(`        | Jump to the opening `(` of the enclosing group       |
| `])`        | Jump to the closing `)` of the enclosing group       |
| `[m`        | Jump to the start of the method / function **above** |
| `]m`        | Jump to the start of the **next** method / function  |
| `[q` / `]q` | Prev / next quickfix item (your keymaps)             |

---

### Drill 3a — escape deep nesting with `[{`

**Mode:** `NORMAL`

**Keystrokes:**

1. Place cursor on the `return true` line deep inside the nested `if` blocks
2. Type `[{` — cursor jumps to the `{` of the nearest enclosing block (inner `if`)
3. Type `[{` again — jumps up one more level to the outer `if`
4. Type `[{` once more — jumps all the way to the opening `{` of `validateForm`

```lua
local function validateForm(data)
  if data.email then
    if data.email:find("@") then
      -- PLACE CURSOR HERE on this line
      return true
    end
  end
  return false
end
```

---

### Drill 3b — navigate a nested function call with `[(`

**Mode:** `NORMAL`

**Keystrokes:**

1. Place cursor anywhere inside the inner table `{ a = 1, b = 2 }`
2. Type `[(` — cursor jumps to the opening `(` of `vim.tbl_extend`
3. Type `])` — cursor jumps to the closing `)` at the end of the whole call
4. Type `[(` again from inside — observe it lands on `(` of the outer call

```lua
local merged = vim.tbl_extend("force", { a = 1, b = 2 }, { c = 3 })
```

---

## §4 — Advanced Motions: `gn` / `gN`

`gn` selects the next search match as a **motion** — making `cgn` the fastest iterative replace in Neovim. After the first change, pressing `.` repeats the entire operation on the next match automatically.

| Key   | Behaviour                                                                 |
| ----- | ------------------------------------------------------------------------- |
| `gn`  | `NORMAL` or `VISUAL` — select the next search match                       |
| `gN`  | Same, backward                                                            |
| `cgn` | `NORMAL` — change the next match, then `.` repeats on every following one |
| `dgn` | `NORMAL` — delete the next match, then `.` repeats                        |

---

### Drill 4a — `cgn` iterative replacement

**Mode:** `NORMAL`

**Keystrokes:**

1. Type `/TODO<CR>` — searches for `TODO` and highlights all matches
2. Type `cgn` — selects the first match and drops into `INSERT` mode
3. Type `DONE` (or any replacement), then press `<Esc>`
4. Press `j` to move down one line
5. Press `.` — replaces the next `TODO` with `DONE` in a single keystroke
6. Press `.` on each remaining line — no re-searching needed

```lua
local tasks = {
  { id = 1, label = "TODO: wire up auth" },
  { id = 2, label = "TODO: add error boundary" },
  { id = 3, label = "TODO: optimise query" },
  { id = 4, label = "TODO: write tests" },
}
```

---

### Drill 4b — `dgn` iterative deletion

**Mode:** `NORMAL`

**Keystrokes:**

1. Type `/console\.log<CR>` — searches for `console.log`
2. Type `dgn` — deletes the entire first matching line content
3. Press `.` on each subsequent line — deletes each `console.log` call in one keystroke

```lua
console.log("debug response", response);
console.log("debug payload", payload);
console.log("debug headers", headers);
```

---

## §5 — Advanced Motions: `H` `M` `L` and `zt` `zz` `zb`

| Key  | Behaviour                                                    |
| ---- | ------------------------------------------------------------ |
| `H`  | `NORMAL` — move cursor to **top** of visible screen          |
| `M`  | `NORMAL` — move cursor to **middle** of visible screen       |
| `L`  | `NORMAL` — move cursor to **bottom** of visible screen       |
| `zt` | `NORMAL` — scroll so the cursor line moves to the **top**    |
| `zz` | `NORMAL` — scroll so the cursor line moves to the **center** |
| `zb` | `NORMAL` — scroll so the cursor line moves to the **bottom** |

---

### Drill 5 — screen repositioning combinations

**Mode:** `NORMAL` throughout

**Keystrokes — Round 1:**

1. Type `L` — cursor moves to the **bottom** of the visible screen
2. Type `zt` — that line is now pulled to the **top** of the window

**Keystrokes — Round 2:**

1. Type `H` — cursor moves to the **top** of the visible screen
2. Type `zb` — that line is now pushed to the **bottom** of the window

**Keystrokes — Round 3:**

1. Type `M` — cursor moves to the **middle**
2. Type `zt` then `zb` then `zz` in sequence — watch the view reposition each time

Repeat all three rounds until the combinations feel like a single gesture.

```lua
local screen_nav_a = "line 1"
local screen_nav_b = "line 2"
local screen_nav_c = "line 3"
```

---

## §6 — Visual Block Mode: `<leader>-v`

> `virtualedit=block` is set in your `options.lua` — the cursor can move past end-of-line into empty space. This is essential for the append drills below.

| Key            | Behaviour                                                       |
| -------------- | --------------------------------------------------------------- |
| `<leader>v`    | `NORMAL` → enter `VISUAL BLOCK` mode                            |
| `I{text}<Esc>` | `VISUAL BLOCK` — insert at the **start** of every selected line |
| `A{text}<Esc>` | `VISUAL BLOCK` — append at the **end** of every selected line   |
| `c{text}<Esc>` | `VISUAL BLOCK` — replace selected columns on every line         |
| `d`            | `VISUAL BLOCK` — delete selected columns on every line          |
| `r{char}`      | `VISUAL BLOCK` — replace every char in block with `{char}`      |
| `~`            | `VISUAL BLOCK` — toggle case on the entire block                |
| `>` / `<`      | `VISUAL BLOCK` — indent / dedent every line in the block        |
| `$`            | `VISUAL BLOCK` — extend selection to end of each line           |
| `g<C-a>`       | `VISUAL BLOCK` — sequentially increment a column of numbers     |

---

### Drill 6a — `I` prepend a comment marker to every line

**Mode:** `NORMAL` → `VISUAL BLOCK` → back to `NORMAL`

**Keystrokes:**

1. `NORMAL`: place cursor on the **first column** of the `local alpha` line
2. Press `<leader>v` — enters `VISUAL BLOCK` mode
3. Press `jjj` — extends the block down to cover all four lines (one column wide)
4. Press `I` — drops into `INSERT` mode at the start of the block
5. Type `-- ` (dash dash space)
6. Press `<Esc>` — the prefix appears on **all four lines** simultaneously

```lua
local alpha   = 1
local beta    = 2
local gamma   = 3
local delta   = 4
```

---

### Drill 6b — `A` append a trailing comma to every line

**Mode:** `NORMAL` → `VISUAL BLOCK` → back to `NORMAL`

**Keystrokes:**

1. `NORMAL`: place cursor anywhere on the `"apple"` line
2. Press `<leader>v` — enters `VISUAL BLOCK` mode
3. Press `$` — extends the selection to the **end of the line** (virtualedit handles uneven lengths)
4. Press `jjj` — extends the block down to cover all four string lines
5. Press `A` — drops into `INSERT` mode at the end of each line
6. Type `,`
7. Press `<Esc>` — the comma appears at the end of **all four lines**

```lua
local fruits = {
  "apple"
  "banana"
  "cherry"
  "date"
}
```

---

### Drill 6c — `c` change a column of values

**Mode:** `NORMAL` → `VISUAL BLOCK` → `INSERT` → `NORMAL`

**Keystrokes:**

1. _NORMAL_: place cursor on the _n_ of the first _nil_
2. Press _<leader>v_ — enters _VISUAL BLOCK_ mode
3. Press _jjj_ — extends selection down to cover _nil_ on all four lines
4. Press _e_ — extends the selection to the end of the _nil_ word
5. Press _c_ — deletes the block and drops into _INSERT_ mode
6. Type _false_
7. Press _<Esc>_ — _false_ replaces _nil_ on **all four lines**

```lua
local flags = {
  debug    = nil,
  verbose  = nil,
  strict   = nil,
  legacy   = nil,
}
```

---

### Drill 6d — `A` append a new field (virtualedit past end-of-line)

**Mode:** `NORMAL` → `VISUAL BLOCK` → `INSERT` → `NORMAL`

**Keystrokes:**

1. `NORMAL`: place cursor anywhere on the first `{ id = 1 ...` line
2. Press `<leader>v` — enters `VISUAL BLOCK` mode
3. Press `$` — extends to the end of the current line
4. Press `jjj` — extends down all four rows (each line may end at a different column — virtual edit handles this)
5. Press `A` — drops into `INSERT` mode after the last char on each line
6. Type `, "dev"`
7. Press `<Esc>` — the new field appears on all four lines

```lua
local users = {
  { id = 1, name = "Alice", role = "admin" , "dev"},
  { id = 2, name = "Bob",   role = "editor", "dev" },
  { id = 3, name = "Carol", role = "viewer", "dev" },
  { id = 4, name = "Dave",  role = "viewer", "dev" },
}
```

---

### Drill 6e — `g<C-a>` sequential increment

**Mode:** `NORMAL` → `VISUAL BLOCK` → `NORMAL`

**Keystrokes:**

1. `NORMAL`: place cursor on the `0` in the first `{ step = 0` line
2. Press `<leader>v` — enters `VISUAL BLOCK` mode
3. Press `jjjj` — extends the column selection down all five rows
4. Press `g<C-a>` — increments the numbers **sequentially**: `1`, `2`, `3`, `4`, `5`

> Note: plain `<C-a>` adds the same number to all — `g<C-a>` makes them a sequence.

```lua
local steps = {
  { step = 1, label = "init" },
  { step = 2, label = "load" },
  { step = 3, label = "validate" },
  { step = 4, label = "process" },
  { step = 5, label = "respond" },
}
```

---

### Drill 6f — `d` delete a column

**Mode:** `NORMAL` → `VISUAL BLOCK` → `NORMAL`

**Keystrokes:**

1. `NORMAL`: place cursor on the `R` of the first `REMOVE_ME`
2. Press `<leader>v` — enters `VISUAL BLOCK` mode
3. Press `jj` — extends selection down all three rows
4. Press `e` then `l` to also select the `, ` that follows (or use `f,` to extend to the comma)
5. Press `d` — the entire `REMOVE_ME = true, ` column is deleted from all three lines

```lua
local records = {
  { id = 1, REMOVE_ME = true, value = "a" },
  { id = 2, REMOVE_ME = true, value = "b" },
  { id = 3, REMOVE_ME = true, value = "c" },

}

```

---

## §7 — Macros: `q` `@` `@@`

| Key           | Behaviour                                                               |
| ------------- | ----------------------------------------------------------------------- |
| `qq`          | `NORMAL` — start recording into register `q`                            |
| `q`           | `NORMAL` — stop recording                                               |
| `@q`          | `NORMAL` — replay register `q` once                                     |
| `@@`          | `NORMAL` — replay the last-used register                                |
| `5@q`         | `NORMAL` — replay register `q` five times                               |
| `:%normal @q` | `NORMAL` — apply macro to every line in the file                        |
| `qQ`          | `NORMAL` — **append** to register `Q` (capital = append, not overwrite) |

> **Golden rule:** always end your macro by moving to the **next target** — one `j` or `]m` — so `[count]@q` and `:%normal @q` work without manual positioning between replays.

---

### Drill 7a — macro to normalise key quoting

**Goal:** remove `"` quotes from the keys on every row in `messy`.

**Mode:** `NORMAL` throughout recording and playback

**Keystrokes — record:**

1. Place cursor on the `"id"` key of the **first** row
2. Type `qq` — starts recording into register `q`
3. Type `f"` — jumps forward onto the `"`
4. Type `sd"` — `mini.surround` deletes the surrounding `"` pair around `id`
5. Type `j` — moves cursor down to the next row (this is the critical end-of-macro step)
6. Type `q` — stops recording

**Keystrokes — replay:** 7. Type `4@q` — replays the macro four more times, processing each remaining row

```lua
local messy = {
  { "id" = 1, "name" = "Alice" },
  { "id" = 2, "name" = "Bob" },
  { "id" = 3, "name" = "Carol" },
  { "id" = 4, "name" = "Dave" },
  { "id" = 5, "name" = "Eve" },
}
```

---

### Drill 7b — macro to add a trailing comma to functions

**Goal:** add `,` to the end of each function definition line.

**Mode:** `NORMAL` throughout

**Keystrokes — record:**

1. Place cursor anywhere on the `getUser` line
2. Type `qq` — start recording
3. Type `$` — jump to end of line
4. Type `a` — enter `INSERT` mode after the last character
5. Type `,` then press `<Esc>` — back to `NORMAL`
6. Type `]m` — jump to the start of the next function
7. Type `q` — stop recording

**Keystrokes — replay:** 8. Type `2@q` — applies to the two remaining functions

```lua
local function getUser() return {} end
local function getOrder() return {} end
local function getProduct() return {} end
```

---

### Drill 7c — macro to uppercase every function name

**Goal:** uppercase the function name on each line.

**Mode:** `NORMAL` throughout

**Keystrokes — record:**

1. Place cursor anywhere on the `formatDate` line
2. Type `qq` — start recording
3. Type `^` — jump to first non-blank character of the line
4. Type `w` — jump forward one word (past `function`)
5. Type `gUiw` — uppercase the entire inner word (the function name)
6. Type `j` — move down one line
7. Type `q` — stop recording

**Keystrokes — replay:** 8. Type `3@q` — applies to the three remaining lines

> Alternatively: `:%normal @q` applies the macro to every line in the file at once.

```lua
local function formatDate() end
local function parseToken() end
local function validateInput() end
local function buildQuery() end
```

---

## §8 — mini.ai: Text Objects in Depth

> All drills here start in `NORMAL` mode unless stated otherwise.
> `v` = switch to `VISUAL` (characterwise) to **see** what the object selects before committing to `d` or `c`.

---

### Drill 8a — `dif` delete inside function call

**Mode:** `NORMAL`

**Keystrokes:**

1. Place cursor anywhere inside the parens — on `userInput` for example
2. Type `vif` first — switches to `VISUAL` and shows you what will be selected
3. Press `<Esc>` to cancel the visual
4. Type `dif` — deletes everything inside the parens, leaving `validateSchema()`

**Expected result:** `validateSchema()`

```lua
validateSchema(userInput, { strict = true, coerce = false })
```

---

### Drill 8b — `caf` change around function call

**Mode:** `NORMAL`

**Keystrokes:**

1. Place cursor on any character of `fetchUser` (the function name)
2. Type `vaf` — `VISUAL` shows you the full selection: name + parens + args
3. Press `<Esc>`
4. Type `caf` — deletes the entire call and drops into `INSERT` mode
5. Type your replacement call, then press `<Esc>`

```lua
local data = fetchUser(userId, { cache = true })
```

---

### Drill 8c — `dia` delete one argument at a time

**Mode:** `NORMAL`

**Keystrokes:**

1. Place cursor on `"Bearer"` (the second argument)
2. Type `via` — `VISUAL` highlights just that argument
3. Press `<Esc>`
4. Type `dia` — deletes `"Bearer"` and handles the adjacent comma cleanly
5. Place cursor on `token`
6. Type `dia` — deletes `token`, leaving `setHeader("Authorization")`

```lua
setHeader("Authorization", "Bearer", token)
```

---

### Drill 8d — `caa` change argument including its comma

**Mode:** `NORMAL`

**Keystrokes:**

1. Place cursor anywhere on `verbose = true`
2. Type `vaa` — `VISUAL` shows the argument **plus** its trailing comma
3. Press `<Esc>`
4. Type `caa` — removes the argument and the comma, drops into `INSERT` mode
5. Press `<Esc>` (or type a replacement)

> `dia` removes only the value. `caa` removes the value **and** its surrounding comma — use `caa` when you want clean removal with no leftover punctuation.

```lua
local logger = createLogger("app", { level = "info", verbose = true, timestamp = true })
```

---

### Drill 8e — `viq` vs `vaq` — inside vs around quotes

**Mode:** `NORMAL`

**Keystrokes:**

1. Place cursor anywhere between the `"` quotes around `production`
2. Type `viq` — `VISUAL` selects just `production` (inside, no quotes)
3. Press `<Esc>`
4. Type `vaq` — `VISUAL` selects `"production"` including the quote characters
5. Press `<Esc>`
6. Try `diq` — deletes only the content, leaving empty `""`
7. Press `u` to undo, then try `daq` — deletes the quotes and the content entirely

```lua
local env = process.env.NODE_ENV or "production"
```

---

### Drill 8f — `vib` expanding bracket selection

**Mode:** `NORMAL`

**Keystrokes:**

1. Place cursor inside `items.filter(Boolean)` — anywhere in the innermost parens
2. Type `vib` — `VISUAL` selects the content of the **nearest** `(`
3. Keep visual active and type `ib` again — expands to the next outer bracket pair
4. Type `ib` once more — expands again to the outermost `(`
5. Press `<Esc>` to cancel

```lua
local sorted = Array.from(new Set(items.filter(Boolean)))
```

---

### Drill 8g — `dit` / `vat` HTML tag objects

**Mode:** `NORMAL`

**Keystrokes:**

1. Place cursor anywhere on the text `Click me` inside the `<span>`
2. Type `vit` — `VISUAL` selects just the text content inside the tag
3. Press `<Esc>`
4. Type `vat` — `VISUAL` selects the **entire** tag including the opening and closing tags
5. Press `<Esc>`
6. Type `dit` — deletes the content, leaving `<span className="label"></span>`
7. Press `u` to undo

```lua
local jsx = [[
  <div className="card">
    <span className="label">Click me</span>
    <p>Some description text here</p>
  </div>
]]
```

---

### Drill 8h — `vina` target the next argument

**Mode:** `NORMAL`

**Keystrokes:**

1. Place cursor **before** the opening `(` of the call — outside any argument
2. Type `via` — notice it selects nothing useful (cursor is not inside an arg)
3. Press `<Esc>`
4. Type `vina` — selects the **next** argument forward: `firstArg`
5. Press `<Esc>`
6. Type `vina` again — selects `secondArg`
7. Type `vina` again — selects `thirdArg`

```lua
local call = doSomething(firstArg, secondArg, thirdArg)
```

---

### Drill 8i — `g[` / `g]` jump to object edges

**Mode:** `NORMAL`

**Keystrokes:**

1. Place cursor on `version = 2` deep inside the nested table
2. Type `g]b` — cursor jumps to the **closing** `}` of the nearest enclosing object
3. Type `g[b` — cursor jumps to the **opening** `{` of the nearest enclosing object
4. Type `g]b` from the outer scope — jumps to the `}` of the outer `inner` table
5. Combine: type `dg]b` — deletes from cursor to the next closing `}`

```lua
local nested = {
  outer = {
    inner = {
      value = 42,
      meta  = { source = "api", version = 2 }
    }
  }
}
```

---

## §9 — mini.surround: Add / Delete / Replace

---

### Drill 9a — `saiw"` wrap a bare word in double quotes

**Mode:** `NORMAL`

**Keystrokes:**

1. Place cursor anywhere on the word `localhost`
2. Type `saiw"` — `sa` (surround add) + `iw` (inner word) + `"` (the character)
3. The word is now wrapped: `"localhost"`

**Expected:** `local host = "localhost"`

```lua
local host = localhost
```

---

### Drill 9b — `saW`` ` `` wrap a dotted WORD in backticks

**Mode:** `NORMAL`

**Keystrokes:**

1. Place cursor anywhere on `process.env.API_KEY`
2. Type `saW`` ` ``— `sa` (surround add) + `W` (WORD — stops at whitespace, includes dots) +`` ` `` (backtick character)

> `iw` stops at dots. `W` (capital) treats the whole dotted path as one word — use `W` when the target includes `.` or `-`.

**Expected:** `` local key = `process.env.API_KEY` ``

```lua
local key = process.env.API_KEY
```

---

### Drill 9c — `saip(` surround an inner paragraph

**Mode:** `NORMAL`

**Keystrokes:**

1. Place cursor on any of the three expression lines (`firstValue`, `secondValue`, or `thirdValue`)
2. Type `saip(` — `sa` (surround add) + `ip` (inner paragraph) + `(` (paren pair)
3. All three lines are now wrapped in `(` and `)`

```lua
local multi =
  firstValue +
  secondValue +
  thirdValue
```

---

### Drill 9d — `sd"` delete surrounding double quotes

**Mode:** `NORMAL`

**Keystrokes:**

1. Place cursor anywhere **inside** the string — on `active` for example
2. Type `sh"` first — flashes the `"` pair so you can confirm what will be removed
3. Type `sd"` — removes both `"` characters, leaving the bare word

**Expected:** `local status = active`

```lua
local status = "active"
```

---

### Drill 9e — `sh(` preview then `sd(` delete inner parens

**Mode:** `NORMAL`

**Keystrokes:**

1. Place cursor anywhere inside `innerFn(arg)` — the inner call
2. Type `sh(` — flashes the `(` pair of `innerFn` so you can see the scope
3. Type `sd(` — removes the parens of `innerFn`, leaving `outerFn(innerFn arg)`
4. Press `u` to undo
5. Now place cursor inside the **outer** `outerFn(...)` call
6. Type `sd(` — removes the outer parens instead

```lua
local wrapped = outerFn(innerFn(arg))
```

---

### Drill 9f — `sr"'` swap double quotes for single quotes

**Mode:** `NORMAL`

**Keystrokes:**

1. Place cursor anywhere inside the string — between the `"` marks
2. Type `sr"'` — `sr` (surround replace) + `"` (the old char) + `'` (the new char)

**Expected:** `local conn = 'mongodb://localhost:27017'`

```lua
local conn = "smongodb://localhost:27017s"
```

---

### Drill 9g — `sr({` replace parens with spaced curly braces

**Mode:** `NORMAL`

**Keystrokes:**

1. Place cursor anywhere inside the `(a, b, c)` parens
2. Type `sr({` — replaces `(` with `{` and `)` with `}`

**Expected:** `local obj = { a, b, c }`

```lua
local obj = (a, b, c)
```

---

### Drill 9h — `V sa"` vs `v$ sa"` — linewise vs characterwise

**Mode:** `NORMAL` to start, then `VISUAL LINE` or `VISUAL`

**Keystrokes — linewise (delimiters go on separate lines):**

1. Place cursor anywhere on the line
2. Press `V` — enters `VISUAL LINE` mode (whole line selected)
3. Type `sa"` — wraps with `"` on the line above and `"` on the line below
4. Press `u` to undo

**Keystrokes — characterwise (delimiters stay inline):**

1. Place cursor at the `=` sign, then move to the start of `this`
2. Press `v` — enters `VISUAL` mode
3. Press `$` — extends selection to end of line
4. Type `sa"` — wraps inline: `local longLine = "this entire line should be wrapped as a string"`

```lua
local longLine = this entire line should be wrapped as a string
```

---

### Drill 9i — chaining `sa` → `sr` → `sd`

**Mode:** `NORMAL` throughout

**Keystrokes:**

1. Place cursor on the bare word `result`
2. Type `saiw(` — wraps the word: `(result)`
3. Type `sr('` — replaces `(` / `)` with `'` / `'`: `'result'`
4. Type `sd'` — removes the single quotes: `result`
5. Now type `u` three times — watch each state come back in reverse

```lua
local chained = 'result'
```

---

## §10 — mini.operators: `gx` `gr` `gs` `gm` `g=`

> All five operators are used from `NORMAL` mode.
> All support `.` dot-repeat and accept any motion or text object.

---

### Drill 10a — `gxia` exchange two function arguments

**Mode:** `NORMAL`

**Keystrokes:**

1. Place cursor anywhere on `"firstName"` (the first argument)
2. Type `gxia` — **marks** the first argument for exchange (nothing visible happens yet)
3. Move cursor to `"lastName"` (the second argument)
4. Type `gxia` — **completes** the exchange, swapping both arguments

**Expected:** `buildName("lastName", "firstName", separator)`

```lua
local name_str = buildName("firstName", "lastName", separator)
```

---

### Drill 10b — `gxiw` exchange two variable names

**Mode:** `NORMAL`

**Keystrokes:**

1. Place cursor on `primaryColor` (the value on line 1, after the `=`)
2. Type `gxiw` — marks `primaryColor` for exchange
3. Move cursor to `accentColor` (the value on line 2, after the `=`)
4. Type `gxiw` — swaps the two words

```lua
local primaryColor = "#cba6f7"
local accentColor  = "#89b4fa"
```

---

### Drill 10c — `griw` replace word with register content

**Mode:** `NORMAL`

**Keystrokes:**

1. Place cursor on `"fresh"` (the value of `newValue`)
2. Type `yiw` — yanks the word `fresh` into the unnamed register
3. Move cursor to `oldValue` on the **last line** (the one assigned to `target`)
4. Type `griw` — replaces `oldValue` with `fresh` from the register
5. The yank register is **preserved** — type `griw` on the next `oldValue` to replace it too

```lua
local oldValue = "stale"
local newValue = "fresh"
local target   = oldValue   -- place cursor on  oldValue  here and type  griw
```

---

### Drill 10d — `gs` sort a word list

**Mode:** `VISUAL` → `NORMAL`

**Keystrokes:**

1. Place cursor on `"delta"` (the first item)
2. Press `vi{` — `VISUAL` selects everything inside the curly braces
3. Type `gs` — sorts the selected lines alphabetically

**Expected:** `"alpha"`, `"beta"`, `"delta"`, `"gamma"`

```lua
local tags = { "delta", "alpha", "gamma", "beta" }
```

---

### Drill 10e — `gsip` sort a paragraph of require statements

**Mode:** `NORMAL`

**Keystrokes:**

1. Place cursor on any of the four `require` lines
2. Type `gsip` — `gs` (sort operator) + `ip` (inner paragraph) — sorts all four lines alphabetically

```lua
local _ = require("telescope")
local _ = require("mini.ai")
local _ = require("gitsigns")
local _ = require("nvim-treesitter")
```

---

### Drill 10f — `gmiw` multiply (duplicate) an argument

**Mode:** `NORMAL`

**Keystrokes:**

1. Place cursor on `userId` inside the function call
2. Type `gmiw` — duplicates the word in place, inserting a copy immediately after it

**Expected:** `processItem(userId, userId, callback)`

```lua
local duplicate = processItem(userId, callback)
```

---

### Drill 10g — `gmm` duplicate an entire line

**Mode:** `NORMAL`

**Keystrokes:**

1. Place cursor anywhere on the `local retries = 3` line
2. Type `gmm` — duplicates the whole line below the current one (linewise multiply)

**Expected:** two identical `local retries = 3` lines

```lua
local retries = 3
```

---

### Drill 10h — `g=iw` evaluate a Lua expression in-place

**Mode:** `NORMAL`

**Keystrokes:**

1. Place cursor anywhere on `2 ^ 7`
2. Type `g=iw` — evaluates the expression under the inner word motion and replaces with the result

> If `iw` only grabs `2`, try `viW` first to confirm the full expression is selected, then use `g=iW` (capital W).

**Expected:** `local maxSize = 128`

```lua
local maxSize = 2 ^ 7
```

---

## §11 — Combining Everything: Real-World Scenarios

---

### Scenario A — Extract an argument to a new variable

**Goal:** lift `"Bearer " .. token` out of the call and assign it to `local auth`.

**Mode sequence:** `NORMAL` → `VISUAL` → `NORMAL` → `INSERT` → `NORMAL`

**Keystrokes:**

1. `NORMAL`: place cursor on `"Bearer "` (the second argument)
2. Type `vina` — `VISUAL` selects the second argument: `"Bearer " .. token`
3. Type `d` — cuts the selection into the unnamed register, back to `NORMAL`
4. Type `O` — opens a new line **above** and enters `INSERT` mode
5. Type `local auth = ` then press `<leader>p` — pastes without clobbering the register
6. Press `<Esc>` — back to `NORMAL`
7. Move cursor to where the argument was (now a gap with just a `,`)
8. Type `saiw"` to wrap a placeholder, or clean up the comma manually with `f,x`

```lua
local _ = setHeader("Authorization", "Bearer " .. token, { "Content-Type" })
```

---

### Scenario B — Swap and re-quote config keys

**Goal:** remove quotes from keys, swap double to single on values, swap `host` and `port` entries.

**Mode:** `NORMAL` throughout

**Keystrokes:**

1. Place cursor inside `["host"]` on the first key
2. Type `sd"` — removes the `"` from `"host"`, leaving bare `host`
3. Type `/\[<CR>` to search for the next `[`, then `cgn` + `sd"` pattern — or manually repeat `sd"` on each key
4. Place cursor inside the `"localhost"` value
5. Type `sr"'` — swaps `"` to `'`: `'localhost'`
6. Repeat `sr"'` on the remaining values (use `.` if `cgn` was used)
7. Place cursor on the `host` entry line
8. Type `gxip` — marks the paragraph item for exchange... or use `dd` + `p` to manually reorder

```lua
local dbConfig = {
  ["host"] = "localhost",
  ["port"] = "5432",
  ["name"] = "mydb",
}
```

---

### Scenario C — Macro + visual block: uppercase and wrap in backticks

**Goal:** every string should be uppercased AND wrapped in backticks.

**Mode:** `NORMAL` for macro recording and playback

**Keystrokes — record macro:**

1. Place cursor on `"read"` (the first string)
2. Type `qq` — start recording into `q`
3. Type `f"` — jump onto the opening `"`
4. Type `gUiw` — uppercase the inner word: `READ`
5. Type `sr"`` ` ``— replace `"` with`` ` ``: `` `READ` ``
6. Type `j` — move to the next line (critical: macro must move to next target)
7. Type `q` — stop recording

**Keystrokes — replay:** 8. Type `4@q` — applies to the four remaining lines

```lua
local permissions = {
  "read",
  "write",
  "delete",
  "admin",
  "superuser",
}
```

---

### Scenario D — Sort, comment duplicate, wrap JSX attribute block

**Goal:** sort attributes alphabetically, comment out a duplicate, wrap the block.

**Mode:** `NORMAL`, then `VISUAL LINE`

**Keystrokes:**

1. Place cursor anywhere inside the attribute block
2. Type `gsip` — `NORMAL`: sorts all attribute lines alphabetically
3. Identify any duplicate attribute (e.g. if `value` appears twice)
4. Place cursor on the duplicate line
5. Type `gcc` — `NORMAL`: comments out that line
6. Press `V` — `VISUAL LINE`: select the entire attribute block
7. Extend with `jjjjjj` to cover all lines
8. Type `sa{` — wraps the whole selection in `{` and `}`

```lua
local props =
  onChange={handleChange}
  value={inputValue}
  autoComplete="off"
  disabled={isLoading}
  className="input-field"
  autoFocus={false}
  name="username"
```

---

## §12 — Bonus: mini.ai + mini.comment Combo

`mini.comment`'s `gc` operator accepts the same text objects as `mini.ai` — they share the object namespace. This means any object you can `d` or `v` you can also `gc`.

**Mode:** `NORMAL`

**Keystrokes — comment only the body:**

1. Place cursor anywhere inside the function body
2. Type `gcif` — `gc` (comment toggle) + `if` (inner function via mini.ai)
3. Only the body lines are commented — the `local function` signature is untouched
4. Type `gcif` again — uncomments the body

**Keystrokes — comment the entire definition:**

1. Type `gcaF` — `gc` + `aF` (around function definition) — comments signature + body together
2. Type `gcaF` again — uncomments everything

```lua
local function legacyHandler(req, res)
  local body = req.body
  local user  = findUser(body.id)
  local token = generateToken(user)
  res.json({ token = token })
end
```

o---

## §13 — flash.nvim: Jump Anywhere in 2-3 Keystrokes

> flash.nvim replaces the need to spam `f`/`;` or count lines. You jump directly to any visible location by typing 2 chars and pressing a label.

| Key | Mode                           | Action                                       |
| --- | ------------------------------ | -------------------------------------------- |
| `s` | `NORMAL / VISUAL / OP-PENDING` | Flash jump — type 2 chars, pick label        |
| `S` | `NORMAL / VISUAL / OP-PENDING` | Flash treesitter — jump to any AST node      |
| `r` | `OP-PENDING`                   | Remote flash — operate on a distant location |
| `R` | `OP-PENDING / VISUAL`          | Treesitter search across window              |

---

### Drill 13a — basic `s` jump

**Mode:** `NORMAL`

**Keystrokes:**

1. Open any file with multiple lines
2. Type `s` — flash activates, screen dims
3. Type the first 2 chars of your target word — e.g. `co` for `console`
4. Labels appear next to every match — press the label letter to jump there instantly

```js
const user = getUser(id);
console.log(user);
const token = generateToken(user);
fetch("/api/data", { method: "POST" });
```

---

### Drill 13b — `s` in operator-pending mode

**Mode:** `NORMAL`

**Keystrokes:**

1. Type `d` then `s` — flash activates in operator-pending mode
2. Type 2 chars of the target — e.g. `fe` for `fetch`
3. Press the label — deletes from cursor to that location
4. Press `u` to undo and try `y` + `s` to yank to a remote location

---

### Drill 13c — `S` treesitter node jump

**Mode:** `NORMAL`

**Keystrokes:**

1. Type `S` — flash highlights every treesitter node on screen (functions, args, blocks)
2. Press a label to jump directly to that node's start
3. Useful for jumping between function definitions without knowing the exact characters

---

## §14 — bufferline: Buffer Tab Navigation

> bufferline shows all open buffers as tabs at the top. These keymaps let you navigate and manage them without touching the mouse.

| Key          | Action                                               |
| ------------ | ---------------------------------------------------- |
| `[b` / `]b`  | Cycle to prev / next buffer                          |
| `[B` / `]B`  | Move current buffer left / right in the tab bar      |
| `<leader>bp` | Toggle pin on current buffer (pinned tabs stay left) |
| `<leader>bo` | Close all other unpinned buffers                     |
| `<leader>br` | Close all buffers to the right                       |
| `<leader>bl` | Close all buffers to the left                        |
| `<leader>ba` | Delete all buffers                                   |

---

### Drill 14a — buffer cycling

**Keystrokes:**

1. Open 3-4 files with `:e filename`
2. Type `]b` — moves to next buffer tab
3. Type `[b` — moves back
4. Type `<leader>bp` on a file you want to keep — it gets pinned (stays left)
5. Type `<leader>bo` — closes everything except the pinned buffer

---

## §15 — Harpoon: Pin & Jump to Key Files

> Harpoon lets you bookmark up to 5 files in your current work session and jump to them instantly — no searching needed.

| Key                | Action                            |
| ------------------ | --------------------------------- |
| `<leader>ha`       | Add current file to harpoon list  |
| `<leader>hh`       | Open harpoon menu (edit the list) |
| `<C-1>` to `<C-5>` | Jump directly to pinned file 1-5  |
| `<leader>hn`       | Next harpoon file                 |
| `<leader>hp`       | Prev harpoon file                 |

---

### Drill 15a — pin and jump

**Keystrokes:**

1. Open `lsp-config.lua` — type `<leader>ha` to pin it (slot 1)
2. Open `keymaps.lua` — type `<leader>ha` to pin it (slot 2)
3. Open `mini-modules.lua` — type `<leader>ha` to pin it (slot 3)
4. Now press `<C-1>` — instantly back to `lsp-config.lua`
5. Press `<C-2>` — instantly to `keymaps.lua`
6. Press `<leader>hh` — opens the harpoon menu, reorder by editing the list

---

## §16 — Neogit & Diffview: Git Workflow

> Full git suite without leaving Neovim. Neogit is your commit/push/branch dashboard. Diffview is your side-by-side diff viewer.

### Neogit keymaps

| Key          | Action                |
| ------------ | --------------------- |
| `<leader>gg` | Open Neogit dashboard |
| `<leader>gC` | Open commit popup     |
| `<leader>gP` | Open push popup       |
| `<leader>gL` | Open log view         |

### Inside Neogit dashboard

| Key     | Action                         |
| ------- | ------------------------------ |
| `s`     | Stage hunk / file under cursor |
| `u`     | Unstage hunk / file            |
| `c`     | Open commit editor             |
| `p`     | Push                           |
| `<Tab>` | Expand / collapse section      |
| `q`     | Close Neogit                   |

### Diffview keymaps

| Key          | Action                                       |
| ------------ | -------------------------------------------- |
| `<leader>gD` | Open diffview — all current changes vs HEAD  |
| `<leader>gh` | File history — every commit for current file |
| `<leader>gH` | Repo history — all commits                   |
| `<leader>gx` | Close diffview                               |

---

### Drill 16a — stage and commit with Neogit

**Keystrokes:**

1. Make a small change to any file and save it
2. Type `<leader>gg` — Neogit opens showing your unstaged change
3. Move cursor to the file under "Unstaged"
4. Type `s` — file moves to "Staged"
5. Type `c` — commit editor opens
6. Type your commit message, then `:wq`
7. Type `<leader>gP` to push

---

### Drill 16b — review changes with Diffview

**Keystrokes:**

1. Make changes to 2-3 files without committing
2. Type `<leader>gD` — diffview opens showing all changes side by side
3. Navigate between files in the left panel with `j`/`k`
4. Press `<CR>` to focus a file's diff
5. Type `<leader>gx` to close when done

---

## §17 — todo-comments: Navigate TODOs

> todo-comments highlights special keywords in your code and lets you search/navigate them.

| Keyword              | Color  | Meaning           |
| -------------------- | ------ | ----------------- |
| `TODO:`              | Blue   | Work to be done   |
| `FIXME:` / `BUG:`    | Red    | Broken code       |
| `HACK:`              | Orange | Workaround        |
| `NOTE:` / `INFO:`    | Green  | Important context |
| `PERF:` / `OPTIM:`   | Purple | Performance issue |
| `WARN:` / `WARNING:` | Yellow | Caution           |

| Key          | Action                          |
| ------------ | ------------------------------- |
| `]t`         | Jump to next TODO               |
| `[t`         | Jump to prev TODO               |
| `<leader>xt` | Show all TODOs in Trouble panel |
| `<leader>ft` | Search TODOs with Telescope     |

---

### Drill 17a — navigate TODOs

**Keystrokes:**

1. Add a few comments to any file:

```js
// TODO: refactor this function
// FIXME: this breaks on empty input
// NOTE: see docs for edge cases
```

2. Type `]t` — jumps to next TODO keyword
3. Type `[t` — jumps back
4. Type `<leader>ft` — opens Telescope showing all TODOs in the project

---

## §18 — Aerial: Code Outline Navigation

> Aerial shows you the symbol structure of your file (functions, classes, methods) in a sidebar. Navigate large files without scrolling.

| Key          | Action                        |
| ------------ | ----------------------------- |
| `<leader>cs` | Toggle aerial sidebar         |
| `<leader>cS` | Search symbols with Telescope |
| `{`          | Jump to previous symbol       |
| `}`          | Jump to next symbol           |

### Inside the aerial sidebar

| Key       | Action                 |
| --------- | ---------------------- |
| `<CR>`    | Jump to symbol         |
| `o`       | Toggle fold            |
| `q`       | Close aerial           |
| `l` / `h` | Open / close tree node |

---

### Drill 18a — navigate a large file with aerial

**Keystrokes:**

1. Open any file with multiple functions
2. Type `<leader>cs` — aerial sidebar opens on the right
3. Press `j`/`k` to browse symbols — the main buffer scrolls to follow
4. Press `<CR>` on a function name — cursor jumps there
5. Back in the main buffer, press `}` to jump to the next function
6. Press `{` to jump back
7. Type `<leader>cs` again to close

---

## §19 — Updated Keymaps Reference

> Changes made during the LazyVim parity upgrade. These replace or fix previous bindings.

### Window management

| Key               | Action                 | Note                                 |
| ----------------- | ---------------------- | ------------------------------------ |
| `<leader>sv`      | Split vertical         | Unchanged                            |
| `<leader>sh`      | Split horizontal       | Unchanged                            |
| `<leader>se`      | Equalize splits        | Unchanged                            |
| `<leader>sx`      | Close split            | Unchanged                            |
| `<leader><Up>`    | Increase window height | FIX: was `<C-Up>` (macOS intercepts) |
| `<leader><Down>`  | Decrease window height | FIX: was `<C-Down>`                  |
| `<leader><Left>`  | Decrease window width  | FIX: was `<C-Left>`                  |
| `<leader><Right>` | Increase window width  | FIX: was `<C-Right>`                 |

### Misc changes

| Key          | Action                 | Note                                                     |
| ------------ | ---------------------- | -------------------------------------------------------- |
| `<leader>D`  | Delete without yanking | FIX: was `<leader>d` (conflicted with DAP)               |
| `<leader>qq` | Quit window            | Unchanged                                                |
| `<leader>qQ` | Force quit all         | FIX: was `<leader>Q` (now consistent with `q` namespace) |
| `<leader>qs` | Restore session        | NEW: persistence.nvim                                    |
| `<leader>ql` | Restore last session   | NEW: persistence.nvim                                    |
| `<leader>qd` | Stop saving session    | NEW: persistence.nvim                                    |

### Yank path utilities

| Key          | Action                           |
| ------------ | -------------------------------- |
| `<leader>yp` | Copy full file path to clipboard |
| `<leader>yr` | Copy relative file path          |
| `<leader>yn` | Copy filename only               |
| `<leader>yd` | Copy file directory              |

### Noice UI

| Key          | Action                     |
| ------------ | -------------------------- |
| `<leader>nd` | Dismiss all Noice messages |
| `<leader>nh` | Show Noice message history |
