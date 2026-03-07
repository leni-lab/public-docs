[back to overview](../overview.md)
---

# logs settings

toolkit.logs reads three sections from the INI config file.
the base section name is `logging` by default (configurable via `setup(section=...)`).

## `[logging console]`

controls the console (stdout) handler.

| key | default | values |
| --- | --- | --- |
| `log_level` | `TRACE` | `TRACE`, `DEBUG`, `INFO`, `WARNING`, `ERROR`, `CRITICAL`, `SILENT` |
| `use_color` | `true` | `true`, `false` |
| `format` | `%(message)s` | python logging format string |

## `[logging file]`

controls the log file handler.

| key | default | values |
| --- | --- | --- |
| `enabled` | `false` | `true`, `false` |
| `log_file` | *(set by app)* | filename; resolved relative to app directory |
| `log_level` | `TRACE` | `TRACE`, `DEBUG`, `INFO`, `WARNING`, `ERROR`, `CRITICAL`, `SILENT` |
| `format` | `[%(asctime)s] %(levelname)-7s - %(name)s - %(message)s` | python logging format string |
| `date_format` | `%Y-%m-%d %H:%M:%S` | `strftime` format |
| `encoding` | `utf-8` | any encoding accepted by `open()` |

## `[logging]`

per-logger level overrides. value is a level name (case-insensitive).

- keys without leading `/` are relative to the app name
- keys with leading `/` are absolute (for third-party loggers)

```ini
[logging]
filemill.mill = debug    # -> <app_name>.filemill.mill
/asyncssh     = warning  # -> asyncssh
```

## `[logging]` levels and cli flags

the `-v`/`-q` flags set a handler-level gate that applies globally:

| flags | effective handler level |
| --- | --- |
| *(none)* | `INFO` |
| `-v` | `DEBUG` |
| `-vv` | `TRACE` |
| `-q` | `WARNING` |
| `-qq` | `ERROR` |
| `-qqq` | `CRITICAL` |
| `-qqqq` | `SILENT` |

`log_level` in the console/file sections sets a floor for that handler;
the effective level is `max(cli_gate, log_level)`.
