[back to overview](../overview.md)
---

# field value syntax

Reference for accepted values per field type.

## field types

| type | accepted values |
|---|---|
| string | any text |
| int | integer literal, e.g. `42`, `-3` |
| bool | `true`/`false`, `yes`/`no`, `1`/`0`, `on`/`off` |
| choice | one of the configured options (case-insensitive) |
| path | `./relative`, `/absolute/path` |
| filename | `./relative`, `/absolute/path` (no filesystem validation) |
| duration | `500ms`, `30s`, `5min`, `2h` |
| matcher | comma-separated glob patterns, e.g. `*.csv`, `*.csv, *.xml, !~$*` |

## matcher syntax

- patterns are glob expressions (`*`, `?`, `[abc]` as in `fnmatch`)
- multiple patterns are comma-separated
- prefix `!` marks a deny (veto) pattern: `!~$*`
- deny patterns take priority over allow patterns
- if no allow patterns are given, all names are accepted (minus denies)
- empty value or absent field matches all names
- case-sensitivity depends on OS by default (case-insensitive on Windows)

## notes

- bool values are case-insensitive (`True`, `TRUE`, `true` all work)
- choice values are case-insensitive by default
- duration values must be a positive integer followed directly by a unit
- path values are not validated unless a field spec is configured to do so
