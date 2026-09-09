[back to overview](overview.md)
---

# CLI

```text
wiki2config-usermgr --output PATH
```

| option            | purpose                                             |
| ----------------- | --------------------------------------------------- |
| `--output PATH`   | required existing empty directory for generated INI |
| `-V`, `--version` | show version and exit                               |
| `-h`, `--help`    | show help and exit                                  |

Input is expanded Wikitext on stdin. stdout contains a Markdown processing
report, stderr contains technical diagnostics. All three streams use UTF-8,
independent of the Windows console encoding. stdin must not contain a BOM.

The processor writes all three INI files in Windows-1252 with CRLF and without
metadata. It neither reads a previous configuration nor activates output. The
supplied directory must be empty. A nonexistent directory is an error.

| exit code | meaning                                                         |
| --------- | --------------------------------------------------------------- |
| 0         | complete, validated INI set written and all output files closed |
| 1         | processing failure, candidate must not be activated             |
| 2         | command-line usage error                                        |

Other abnormal exits also mean failure. A nonzero exit may leave partial files
in the working directory. The caller discards that directory.

The former `--config`, `--set`, `--watch`, `--check`, verbosity, and previous
application configuration are not supported. `python -m wiki2config_usermgr` exposes the
same interface. See [quickstart](quickstart.md) and [operation](operation.md).
