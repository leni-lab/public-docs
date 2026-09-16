[back to overview](overview.md)
---

# Settings

Define any number of named sections such as `[archive toolkit]` and
`[archive services]`. Each section is processed independently, in configuration
order. Relative input and output paths are based on the configuration file.

## Archive jobs

All four fields are required.

| key           | meaning                                                 |
| ------------- | ------------------------------------------------------- |
| `input_path`  | directory to scan, without recursion                    |
| `input_name`  | regular expression matching the complete input filename |
| `output_path` | root directory for ZIP archives                         |
| `output_name` | relative ZIP path with numbered regex group references  |

```ini
[archive toolkit]
input_path = d:/logs/toolkit
input_name = (.+)\.log\.(\d{4})-(\d{2})-\d{2}(?:\.\d+)?
output_path = d:/archive/logs
output_name = $2/$1.$2-$3.zip
```

| reference | captured value | example      |
| --------- | -------------- | ------------ |
| `$1`      | log name       | `storeindex` |
| `$2`      | year           | `2026`       |
| `$3`      | month          | `09`         |

The optional final number accepts Toolkit collision segments such as
`storeindex.log.2026-09-16.1`. The day and collision number are not captured.
Regular expressions are case-sensitive unless an inline flag such as `(?i)`
is provided. Matching uses the filename only, not its directory path. Active
logs like `storeindex.log` do not match the example expression.

The expression alone selects eligible names. Keep it specific enough to
exclude active logs, temporary files, and legacy inputs. No timestamp or
calendar validation is performed and file contents are not parsed.

## Archive paths

| output_name       | grouping                                | example target below output_path |
| ----------------- | --------------------------------------- | -------------------------------- |
| `$2/$1.$2-$3.zip` | each log name per month                 | `2026/storeindex.2026-09.zip`    |
| `$2/$2-$3.zip`    | all log names per month                 | `2026/2026-09.zip`               |
| `$2-$3.zip`       | all log names per month, flat directory | `2026-09.zip`                    |

`$1`, `$2`, and so on refer to numbered capture groups. `$10` means group 10,
not group 1 followed by zero. An unmatched optional capture expands to an empty
string. Captured text is inserted once and is never interpreted as another
group reference. Literal dollar signs in templates are not supported.

Invalid regular expressions and references to missing groups fail before any
input scan. Output names must end in `.zip`. Forward or backward slashes may
separate subdirectories. Absolute paths, drive prefixes, empty components,
`.` and `..` components are rejected. Expanded targets must stay inside
`output_path`, including when existing subdirectories are symbolic links.

The complete source filename remains the ZIP member name, including
collision numbers. For example, `storeindex.log.2026-09-16.1` is preserved.

Multiple jobs may deliberately produce the same archive path. Archive updates
are serialized. Existing members with identical bytes allow source removal to
be retried without adding a duplicate. Different bytes under the same name are
an error, and the source is retained. The preview only lists mappings and does
not open ZIPs or detect member conflicts.

## Logging

Toolkit owns logging configuration, including `[logging file]`,
`[logging console]`, and `[logging pipe]`. `rotate = yes` enables daily rotation
for logarchive's own optional log file. Keep it outside input directories.
