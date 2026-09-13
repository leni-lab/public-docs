[back to overview](overview.md)
---

# Command line

```text
leniextract --field <name> [--field <name>] [--input <path>]
```

| option | meaning |
| --- | --- |
| `--field` | required field name, repeatable and comma-separated |
| `--input` | optional UTF-8 JSON input file, defaults to standard input |
| `--version` | print the installed version |
| `--help` | print usage |

Only `title` is currently supported. It uses the export's `data.headline`
value. These calls are equivalent:

```text
leniextract --field title
leniextract --field title,title
leniextract --field title --field title
```

Whitespace around names is removed and duplicate fields are combined.
Empty field names and unsupported names produce an error.

## Results

Success prints exactly one JSON object on standard output. A missing or null
title produces `{"title": null}`. An empty title remains an empty string.
Diagnostic messages go to standard error.

Unicode characters may appear as JSON escape sequences. A JSON reader restores
the original characters. The returned title is not shortened or reformatted.

| exit code | meaning |
| --- | --- |
| `0` | successful extraction, including a missing title |
| `1` | input or extraction failure |
| `2` | command-line usage failure |

On failure, there is no result on standard output. Applications should accept
a result only when the exit code is zero.
