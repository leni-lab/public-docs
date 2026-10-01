[back to overview](../overview.md)
---

# logs settings

`toolkit.logs` reads three sections from the INI config file.
The base section name is `logging` by default
(configurable via `setup(section=...)`).

## `[logging console]`

Controls the console stderr handler when stdout is connected to a TTY.

| key          | default       | values                                                             |
| ------------ | ------------- | ------------------------------------------------------------------ |
| `log_level`  | `TRACE`       | `TRACE`, `DEBUG`, `INFO`, `WARNING`, `ERROR`, `CRITICAL`, `SILENT` |
| `color_mode` | `auto`        | `auto`, `always`, `never`                                          |
| `format`     | `%(message)s` | python logging format string                                       |

`color_mode` behavior:

- `auto`: use colors on tty output, respect `NO_COLOR`
- `always`: force colors
- `never`: disable colors

## `[logging file]`

Controls the log file handler.

| key           | default                                                  | values                                                                              |
| ------------- | -------------------------------------------------------- | ----------------------------------------------------------------------------------- |
| `log_file`    | *(empty - no log file)*                                  | filename; empty disables the handler; relative paths resolved against app directory |
| `rotate`      | `no`                                                     | bool or suffix format, as described below                                           |
| `log_level`   | `TRACE`                                                  | `TRACE`, `DEBUG`, `INFO`, `WARNING`, `ERROR`, `CRITICAL`, `SILENT`                  |
| `format`      | `[%(asctime)s] %(levelname)-7s - %(name)s - %(message)s` | python logging format string                                                        |
| `date_format` | `%Y-%m-%d %H:%M:%S`                                      | `strftime` format                                                                   |
| `encoding`    | `utf-8`                                                  | any encoding accepted by `open()`                                                   |

Rotation is disabled by default. Enable it with:

```ini
[logging file]
log_file = app.log
rotate = %Y-%m-%d
```

`rotate` accepts a `strftime` suffix format or a boolean value. The boolean
pairs `yes`/`no`, `true`/`false`, `on`/`off`, and `1`/`0` ignore case. True means
`%Y-%m-%d`. False disables rotation and the timer, opening the file during setup
and appending messages as usual. Format strings preserve case, including the
distinction between `%m` (month) and `%M` (minute).

| format        | use                | example suffix  |
| ------------- | ------------------ | --------------- |
| `%Y-%m-%d`    | daily, recommended | `2026-09-16`    |
| `%Y-%m`       | monthly            | `2026-09`       |
| `%Y`          | yearly             | `2026`          |
| `%Y-%m-%d_%H` | hourly             | `2026-09-16_14` |

Local time determines the suffix. Rotation occurs when the formatted result
changes. The active filename stays unchanged. Completed files receive the
previous suffix, for example `app.log.2026-09-15`. Existing targets are preserved
by adding `.1`, `.2`, etc. Each active file must have a single writing process.

Formats are passed directly to `strftime` without validation. An unchanged
result does not trigger rotation. Choose a format that produces a valid file
suffix and matches the archive tool's expectations. Include the year and all
relevant date parts to distinguish periods after long application downtime.

Setup derives the existing file's suffix from its modification time without
opening it.
The first accepted file message rotates an old file if needed, opens the
active file, and starts a background timer. The timer checks every minute even
without further messages, so rotation may lag a period boundary by up to a
minute during normal operation. Every write also checks the suffix, covering a
delayed timer after standby. An unused handler starts no timer and leaves old
files untouched. After rotation, the active file is created on the next write.
Empty files are not archived.

Closing the handler or repeating setup stops its timer. Formatting and rotation
failures in the timer are reported to stderr and retried after a minute. A
failure during a write propagates to the caller before writing, preserving the
old file's period. Completed files are never automatically deleted or compressed.

## `[logging pipe]`

Controls the stderr handler when stdout is not connected to a TTY
(i.e. stdout is piped). The console handler is skipped in this case.

Output format is fixed: `[{n}] {message}` where `n` is a numeric level.
Exception traceback lines use the same numeric prefix as their log record.

| n   | level      |
| --- | ---------- |
| `0` | `TRACE`    |
| `1` | `DEBUG`    |
| `2` | `INFO`     |
| `3` | `WARNING`  |
| `4` | `ERROR`    |
| `5` | `CRITICAL` |

| key         | default | values                                                             |
| ----------- | ------- | ------------------------------------------------------------------ |
| `log_level` | `TRACE` | `TRACE`, `DEBUG`, `INFO`, `WARNING`, `ERROR`, `CRITICAL`, `SILENT` |

This section is optional - zero-config. `[logging pipe]` activates
automatically when stdout is not a TTY, no explicit configuration needed.

## `[logging]`

Per-logger level overrides. Value is a level name (case-insensitive).

- keys without leading `/` are relative to the app name
- keys with leading `/` are absolute (for third-party loggers)

```ini
[logging]
filemill.mill = debug    # -> <app_name>.filemill.mill
/asyncssh     = warning  # -> asyncssh
```

## `[logging]` levels and cli flags

The `-v`/`-q` flags set a handler-level gate that applies globally:

| flags    | effective handler level |
| -------- | ----------------------- |
| *(none)* | `INFO`                  |
| `-v`     | `DEBUG`                 |
| `-vv`    | `TRACE`                 |
| `-q`     | `WARNING`               |
| `-qq`    | `ERROR`                 |
| `-qqq`   | `CRITICAL`              |
| `-qqqq`  | `SILENT`                |

`log_level` in the console/file sections sets a floor for that handler,
the effective level is `max(cli_gate, log_level)`.
