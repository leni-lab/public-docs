[back to overview](../overview.md)
---

# field value syntax

Reference for accepted values per field type.

## field types

| type | accepted values |
|---|---|
| string | any text |
| args | whitespace-separated arguments, grouped with double quotes |
| int | integer literal, e.g. `42`, `-3` |
| bool | `true`/`false`, `yes`/`no`, `1`/`0`, `on`/`off` |
| choice | one of the configured options (case-insensitive) |
| path | `./relative`, `/absolute/path` |
| filename | `./relative`, `/absolute/path` (no filesystem validation) |
| patterns | comma-separated path patterns, e.g. `apps/**/appinfo.ini, other/*/appinfo.ini` |
| duration | `500ms`, `30s`, `5min`, `2h` |
| matcher | comma-separated glob patterns, e.g. `*.csv`, `*.csv, *.xml, !~$*` |

## Path pattern lists

`field_patterns()` returns a tuple of strings in input order. It strips
surrounding whitespace from each pattern and rejects empty entries and control
characters. A missing value requires a default. Commas inside patterns are
unsupported.

Patterns are preserved without path resolution, matching, or filesystem access.
The consumer defines wildcard semantics and resolves relative patterns against
its base directory. This field does not interpret `!` as an exclusion.

## Argument syntax

`parse_args(text)` returns a tuple of strings. `field_args(default=None)` uses
the same parser with normal field defaults and validation. A missing required
field is an error. An explicit empty value always produces `()`, including
when it replaces a nonempty default. Use `field_args("")` for optional args.

The following INI values are equivalent:

```ini
args = --verbose --label "Test configuration"
```

```ini
args =
    --verbose
    --label "Test configuration"
```

- whitespace outside double quotes separates arguments, including newlines
- double quotes group text and are removed, including in `--label="two words"`
- `""` supplies one empty argument
- within quoted text, doubled double quotes supply a literal double quote:
  `"say ""hello"""` becomes `say "hello"`
- backslashes are always literal, including before a closing quote:
  `"C:\Program Files\Tool\"` preserves the trailing backslash
- single quotes are literal characters, not grouping syntax
- unclosed double quotes and NUL characters raise `ValueError` from
  `parse_args`, or `FieldError` through `process_fields`
- behavior is identical on all platforms, with no shell or wildcard expansion
- INI interpolation occurs before field processing, as for other field types

## Matcher syntax

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
- any field value can be set to `<default>` to explicitly request the field's default value; raises an error if the field has no default
