[back to overview](overview.md)
---

# CLI

```text
wiki2config --config PATH [--watch] [--check]
```

| option                          | purpose                                                                 |
| ------------------------------- | ----------------------------------------------------------------------- |
| `-c`, `--config PATH`           | application INI file                                                    |
| `--watch`                       | import immediately, then observe input and retry transient failures     |
| `--check`                       | run the processor and validate against active output without activation |
| `-s`, `--set SECTION:KEY=VALUE` | override one setting, repeatable                                        |
| `-v`, `--verbose`               | increase diagnostic detail, repeatable                                  |
| `-q`, `--quiet`                 | decrease diagnostic detail, repeatable                                  |
| `-V`, `--version`               | show version and build information                                      |
| `-h`, `--help`                  | show help                                                               |

Without `--watch`, the command attempts every named conversion in INI order
and exits. Expected failures do not skip later jobs, and any failed job makes
the exit code nonzero. All settings are validated before processing starts.
`--watch` observes jobs concurrently with independent retry state. `--check` also
reads the active baseline, so invalid existing metadata can fail a check. It
creates and removes its workspace and invokes the configured processor, but
publishes no report and performs no activation or Git commands. Combining
`--watch --check` repeats these checks when input changes.

An EXE defaults to an INI beside that executable, with the same base name. Use
an explicit `--config` path for development or other layouts. All application
paths in that file are relative to its directory.

Overrides can target shared defaults or one job. Quote section names with
spaces, for example `--set "convert usermgr:args=--verbose"` or
`--set "convert usermgr:use_git=no"`.

Exit code 0 means the invocation completed normally. Nonzero codes indicate
failure. Watch mode can log failed attempts and continue, so its eventual exit
code is not the outcome of every import. Inspect reports and diagnostics. Unlike
the domain processor's stdout, wiki2config's console output is runtime
information. Reports are separate Markdown files.

See [settings](settings.md) and [operation](operation.md).
