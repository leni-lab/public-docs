[back to overview](overview.md)
---

# settings

canonical configuration reference for sftpbeam.

audience: end users and operators.

## files

- use `sftpbeam.ini` in the working directory for local runs
- copy from [sftpbeam.example.ini](sftpbeam.example.ini) as a starting point
- keep `sftpbeam.ini` local and untracked

see also: [quickstart.md](quickstart.md)

## value syntax

- durations, booleans, and path values follow config syntax rules
- see [config/syntax.md](config/syntax.md)

## minimal required keys

- one `[input <name>]` section with `inbox`
- one `[sftp <name>]` section with `host` and `username`
- one `[transfer <name>]` section with `sftp` and `remote_dir`
- section names must align across `[input <name>]` and `[transfer <name>]`

## [app]

runtime-level app controls.

| key | default | notes |
| --- | --- | --- |
| `max_runtime` | `30s` in sample | empty disables limit; `--max-runtime` overrides |

see also: [cli.md](cli.md)

## [logging]

per-logger level overrides.

- key format: `<logger_name> = <level>`
- relative names are prefixed with app name: `filemill.mill` → `sftpbeam.filemill.mill`
- leading `/` = absolute name (for third-party loggers): `/asyncssh` → `asyncssh`
- examples:
  - `filemill.mill = debug`
  - `/asyncssh = warning`

note on asyncssh log levels: asyncssh logs very little at `info` and very
verbosely at `debug` (ssh handshake, packet details, crypto). there is no
useful middle ground — `info` is the recommended level for normal operation.

see also: [logs/settings.md](logs/settings.md)

## [logging console]

console handler defaults.

| key | sample | notes |
| --- | --- | --- |
| `log_level` | `TRACE` | minimum level for console output |
| `use_color` | `true` | colored console output |
| `format` | `%(message)s` | console log format |

## [logging file]

file handler defaults.

| key | sample | notes |
| --- | --- | --- |
| `enabled` | `true` | enable file logging |
| `log_level` | `DEBUG` | minimum level for file output |
| `log_file` | `<default>` | uses computed default `<app_name>.log` |
| `format` | long formatter | file log format string |
| `date_format` | `%Y-%m-%d %H:%M:%S` | timestamp format |
| `encoding` | `utf-8` | file encoding |

## [logging pipe]

pipe handler defaults; replaces the console handler when stdout is not a TTY.
activates automatically — no explicit config required.

output format is fixed: `[{n}] {message}` where `n` is a numeric level
(0=TRACE, 1=DEBUG, 2=INFO, 3=WARNING, 4=ERROR, 5=CRITICAL).

| key | default | notes |
| --- | --- | --- |
| `log_level` | `TRACE` | minimum level for pipe output |

## [input]

hotfolder paths and processing tuning.

`[input]` defines shared defaults.
`[input <name>]` defines one concrete input pipeline.

### directories

| key | sample | notes |
| --- | --- | --- |
| `inbox` | `s:/inbox` | source directory, set in `[input <name>]` |
| `work` | `${inbox}/work` | claimed files |
| `retry` | `${inbox}/retry` | transient failures |
| `done` | `${inbox}/done` | successful files |
| `fail` | `${inbox}/fail` | permanent failures |
| `review` | `${inbox}/review` | manual review destination |

producer contract:

- producer must publish via atomic rename or producer-held lock
- producer should prefer atomic rename
- consumer guardrails are a safety net, not a replacement

see also: [filemill/settings.md](filemill/settings.md), [troubleshooting.md](troubleshooting.md)

### timing

| key | sample | notes |
| --- | --- | --- |
| `clean_up` | `60min` | cleanup cycle interval |
| `poll` | `1s` | inbox scan interval |
| `work_timeout` | `60min` | max processor runtime before retry |
| `pre_claim_stable` | `2s` | short mtime stability window before claim |

### claim guardrails

| key | sample | notes |
| --- | --- | --- |
| `pre_claim_lock` | `true` | pre-check lock state and skip locked files |
| `pre_claim_timeout` | `1min` | warning threshold for long pre-claim blocking |

### filtering

| key | default | notes |
| --- | --- | --- |
| `match` | empty | glob patterns, comma-separated; empty matches all; `!` prefix denies |

examples:

- `match = *.csv` - accept only csv files
- `match = *.csv, *.xml` - accept csv and xml
- `match = !~$*` - deny temp files, accept all others
- `match = *.csv, !~$*` - accept csv, deny temp files

see [fields/syntax.md](fields/syntax.md)
for matcher-specific syntax.

### capacity

| key | sample | notes |
| --- | --- | --- |
| `queue_size` | `200` | max queued files |
| `workers` | `1` | parallel worker count |

### retry

| key | sample | notes |
| --- | --- | --- |
| `retries` | `3` | max retry attempts |
| `backoff` | `1s` | initial retry delay |
| `backoff_max` | `15s` | maximum retry delay |

## [sftp]

sftp server connection settings.

`[sftp]` defines shared defaults.
`[sftp <name>]` defines one concrete server connection.

| key | default | notes |
| --- | --- | --- |
| `host` | required | set in `[sftp <name>]`, sftp server hostname |
| `port` | `22` | ssh port |
| `username` | required | ssh username |
| `password` | empty | optional, prefer key auth |
| `key_file` | empty | path to private key, empty uses agent |
| `known_hosts` | `~/.ssh/known_hosts` | empty disables host verification |
| `connect_timeout` | `30s` | max time to establish connection |
| `keep_alive` | `30s` | ssh keepalive interval, empty disables |
| `overwrite` | `true` | overwrite existing files on remote; uses posix-rename for atomic replace |

see also: [sftp/settings.md](sftp/settings.md), [troubleshooting.md](troubleshooting.md)

## [transfer]

sftp upload behavior.

`[transfer]` defines shared defaults.
each `[transfer <name>]` section defines one pipeline.
all named transfer sections are auto-discovered at startup.
the transfer name must match the corresponding `[input <name>]` section name.

| key | default | notes |
| --- | --- | --- |
| `sftp` | required | name of the `[sftp <name>]` section to connect to |
| `remote_dir` | required | destination directory on server |
| `temp_suffix` | `.tmp` | upload under temp name, rename on completion, empty disables |
| `transfer_timeout` | `5min` | max upload time per file |

see also: [quickstart.md](quickstart.md), [sftp/settings.md](sftp/settings.md)

## see also

- [filemill/settings.md](filemill/settings.md)
- [logs/settings.md](logs/settings.md)
- [sftp/settings.md](sftp/settings.md)
