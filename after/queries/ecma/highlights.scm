;; extends

; Extra captures for the Atom One Dark tuning of onedark (lua/plugins/colorscheme.lua).
; ecma is shared by javascript, typescript and tsx. Each capture falls back to its
; parent group (@variable, @variable.builtin, @keyword), so other themes look unchanged.

; const names where they're declared (VS Code scope variable.other.constant)
(lexical_declaration
  kind: "const"
  (variable_declarator
    name: (identifier) @variable.declaration))

; ...except when the value is a function. A later pattern wins, so this puts
; @function back on top (nvim-treesitter's kind-eq? predicate breaks on Neovim 0.12)
(variable_declarator
  name: (identifier) @function
  value: [
    (arrow_function)
    (function_expression)
  ])

(lexical_declaration
  kind: "const"
  (variable_declarator
    name: [
      (object_pattern
        (shorthand_property_identifier_pattern) @variable.declaration)
      (object_pattern
        (pair_pattern
          value: (identifier) @variable.declaration))
      (array_pattern
        (identifier) @variable.declaration)
    ]))

; console is a plain object in the VS Code theme, not a builtin
((identifier) @variable.builtin.console
  (#eq? @variable.builtin.console "console"))

(export_statement
  "default" @keyword.default)
