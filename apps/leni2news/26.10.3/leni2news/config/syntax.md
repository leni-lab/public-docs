[back to overview](../overview.md)
---

# ini file syntax

Standard Python `configparser` format with extended interpolation:

```ini
# comment
[section]
key = value

[child]
.parent = section       # inherits all keys from section
key     = override
other   = ${section:key}  # cross-section interpolation
```

- unquoted keys are case-insensitive
- double-quoted keys preserve case and literal delimiters or brackets, with
  JSON string escaping, for example `"[data-role=\"body\"]" = Article body`
- the regular `=` or `:` delimiter follows the closing quote; values retain
  normal interpolation and comment rules
- quoted keys work in included files, inheritance, and `--set` overrides
- section dictionaries retain rule order; inherited entries precede child
  entries, with overridden entries taking the child's position
- files use UTF-8, with or without a byte-order mark
- indented continuation lines form a multiline string value, preserving line
  breaks; interpretation of that string belongs to the consuming field
- `#` at the start of a line starts a comment
- inline comments require at least two whitespace characters before `#`:
  `key = value  # comment`
- with only one whitespace character, `#` and the following text remain part
  of the value: `key = value # not a comment`
- after an empty value, at least two spaces are needed: `key =  # comment`
  (`key = # comment` with one space does not work - the space is the
  key/value delimiter)
- prefer a separate comment line when alignment does not make the required
  spacing obvious
- interpolation: `${section:key}` or `${key}` (same section)
- other `$` characters are literal; the legacy `$$` escape remains accepted

For accepted field values (`500ms`, `true`, `42`, etc.)
see [syntax.md](../fields/syntax.md).

## include directives (v1)

- line-based preprocessor directives start with `@`
- directive vs key:
  - `@name = ...` and `@name : ...` are normal key/value lines, not directives
  - a line is a directive only when it starts with `@` and has no key/value
    separator (`=` or `:`) after the first word
- include forms:
  - `@include path/to/file.ini`
  - `@include? path/to/file.ini` (optional include, missing file is ignored)
  - `@include "D:\export\config\subscriptions.ini"`
  - `@include 'shared config.ini'`
- include paths:
  - unquoted paths and matching single or double quotes are supported
  - backslashes are literal, with no escape processing
  - whitespace followed by `#` starts an inline comment outside quotes
  - quoted paths can contain spaces and `#`
  - after the closing quote, only whitespace and an inline comment are allowed
- path resolution:
  - relative path is resolved relative to the including file
  - absolute path is used as-is
- semantics:
  - include is textual, acts as if included lines were pasted at that position
  - later lines override earlier lines under normal ini rules
- errors:
  - include cycles are rejected
  - empty paths, unclosed quotes, and trailing text are rejected
  - optional includes ignore only a missing target, not access errors or
    missing required includes inside an existing target
  - diagnostics include source location and include stack context
