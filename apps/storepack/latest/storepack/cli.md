[back to overview](overview.md)
---

# Command line

```text
storepack [options]
```

The default invocation processes one snapshot of eligible files and exits.
It does not wait for recent files to age, locks to clear, or new files to
arrive. Each selected day gets one attempt. Failed days remain for a later
invocation. Other selected days are still processed.

| option | value | purpose |
| --- | --- | --- |
| `-c`, `--config` | path | INI file, defaults to `storepack.ini` |
| `-s`, `--set` | `SECTION:KEY=VALUE` | override a setting for this run, repeatable |
| `--watch` | - | repeat scans until stopped |
| `--dry-run` | - | check eligible files and existing ZIPs without changing the store |
| `--max-runtime` | duration | request shutdown after this duration |
| `-v`, `--verbose` | - | increase logging, repeatable |
| `-q`, `--quiet` | - | decrease logging, repeatable |
| `-V`, `--version` | - | show version and build information |
| `-h`, `--help` | - | show help |

`--watch` and `--dry-run` cannot be combined. Verbose and quiet cannot be
combined. Dry runs check existing ZIP integrity and name conflicts but do not
create a ZIP, month directory, or lock file. They cannot prove sufficient free
space or permission to publish the replacement.

```text
storepack --dry-run
storepack --watch --max-runtime 2h
storepack --set store:min_age=72h
```

## Shutdown and exit codes

Ctrl+C, a runtime limit, or a configuration change requests a graceful stop.
An active day finishes or fails before shutdown. Slow storage can therefore
extend shutdown beyond a runtime limit. Configuration changes stop the
process, they are not applied during a run.

| code | meaning |
| --- | --- |
| `0` | selected work succeeded, or a watcher stopped without processing errors |
| `1` | processing or I/O failure, store already locked, or one-time run stopped early |
| `2` | invalid arguments or configuration |
| `130` | stopped by Ctrl+C |

Unsupported filenames are warnings and do not make the run fail. In watch
mode, day failures are retried on later scans and remembered for the final
exit code. An empty batch succeeds. A second writer fails immediately.
