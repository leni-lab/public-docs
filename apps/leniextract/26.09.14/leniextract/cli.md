[back to overview](overview.md)
---

# Command line

```text
leniextract --field <name> [--field <name>] [--input <path>]
```

| option            | meaning                                             |
| ----------------- | --------------------------------------------------- |
| `--field`         | required field name, repeatable and comma-separated |
| `--input`         | UTF-8 JSON input file, defaults to standard input   |
| `-V`, `--version` | print version and build information                 |
| `-h`, `--help`    | print usage                                         |

Available fields:

| field      | JSON input      | value                                      |
| ---------- | --------------- | ------------------------------------------ |
| `title`    | `data.headline` | text or null, missing headline becomes null |
| `src_id`   | top-level `id`  | signed 64-bit integer or decimal string     |
| `src_rev`  | top-level `rev` | signed 64-bit integer or decimal string     |
| `keywords` | `data.keywords` | string array, missing or null becomes `[]`  |

Only requested fields are validated and returned. Decimal strings such as
`"1117006"` and `"1"` are converted to JSON integers. Strings may contain
ASCII digits, an optional leading `+` or `-`, and leading zeros. Whitespace,
decimal points, and exponents are not accepted. Missing IDs or revisions,
null, booleans, floats, invalid strings, and values outside the signed 64-bit
range are rejected with exit code 3 when the respective field is requested.

Keywords require a `data` object. Exact duplicate strings are removed, keeping
the first occurrence and its order. Case, whitespace, and spelling are preserved.
For example, `["Religion", "Kirche", "Religion"]` becomes
`["Religion", "Kirche"]`. A single keyword still returns an array. Other values
or non-string elements are rejected with exit code 3.

For Storeindex use `leniextract --field title,src_id,src_rev,keywords`. These
title-only calls are equivalent:

```text
leniextract --field title
leniextract --field title,title
leniextract --field title --field title
```

Whitespace around names is removed and duplicate fields are combined. Empty
field names and unsupported names produce an error.

## Results

Success prints exactly one JSON object on standard output. A missing or null
title produces `{"title": null}`. An empty title remains an empty string.
Diagnostic messages go to standard error.

Unicode characters may appear as JSON escape sequences. A JSON reader restores
the original characters. The returned title is not shortened or reformatted.

| exit code | meaning                                                  |
| --------- | -------------------------------------------------------- |
| `0`       | successful extraction, including a missing title         |
| `1`       | operational or unexpected failure                        |
| `2`       | command-line usage failure, including unsupported fields |
| `3`       | input rejected, invalid UTF-8 JSON or document structure |

On failure, there is no result on standard output. Applications should accept
a result only when the exit code is zero.

Exit code `3` identifies a permanent rejection of this input. Other failures
do not establish that the document is invalid. Consumers must not quarantine
input based on exit code `1` or `2`. This replaces the former combined error
code `1` for invalid input and operational failures.
