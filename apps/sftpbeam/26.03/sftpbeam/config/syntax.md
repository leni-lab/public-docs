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

- keys are case-insensitive
- `#` at the start of a line starts a comment
- inline comments require a leading space: `key = value  # comment`
  (a `#` without a leading space is part of the value)
- after an empty value, at least two spaces are needed: `key =  # comment`
  (`key = # comment` with one space does not work — the space is the key/value delimiter)
- interpolation: `${section:key}` or `${key}` (same section)

For accepted field values (`500ms`, `true`, `42`, etc.)
see [syntax.md](../fields/syntax.md).
