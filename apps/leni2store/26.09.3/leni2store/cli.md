[back to overview](overview.md)
---

# Command line

```text
leni2store.exe [options]
```

The application runs continuously. Its default configuration is
`leni2store.ini` beside the executable.

| option | value | purpose |
| --- | --- | --- |
| `-c`, `--config` | path | select another INI file |
| `-s`, `--set` | `SECTION:KEY=VALUE` | override a setting for this run, repeatable |
| `--max-runtime` | duration | request a stop after this interval, overrides `[app] max_runtime` |
| `-v`, `--verbose` | - | increase logging, `-v` for debug and `-vv` for trace |
| `-q`, `--quiet` | - | decrease logging, repeatable |
| `-V`, `--version` | - | show version and build information |
| `-h`, `--help` | - | show help |

Verbose and quiet options cannot be combined. A runtime limit requests a
graceful stop. An active copy must finish or fail before its source is moved,
so shutdown can take longer when storage is slow or unavailable.

```text
leni2store.exe --config D:/jobs/leni2store.ini
leni2store.exe --max-runtime 30s --verbose
leni2store.exe --set input:poll=2s
```

## Exit codes

| code | meaning |
| --- | --- |
| `0` | stopped normally, including runtime limit or configuration change |
| `1` | application startup or runtime failure |
| `2` | invalid invocation or configuration |
| `130` | stopped by Ctrl+C |

Individual file failures are recorded in the log and processing directories.
They do not by themselves stop the watcher or change a normal exit code to
failure. Inspect `fail` and `review` as part of normal operation.
