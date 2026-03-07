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
- `#` starts a comment
- interpolation: `${section:key}` or `${key}` (same section)

For accepted field values (`500ms`, `true`, `42`, etc.)
see [syntax.md](../fields/syntax.md).
