[back to overview](overview.md)
---

# CLI

Command and option reference for wiki2user.

## Command

```text
wiki2user [options]
```

Without `--watch`, wiki2user performs one conversion and exits.

## Options

| option            | value               | purpose                                               |
| ----------------- | ------------------- | ----------------------------------------------------- |
| `-c`, `--config`  | `TEXT`              | config file, default `wiki2user.ini` beside the executable |
| `-v`, `--verbose` | none                | increase verbosity, `-v` debug and `-vv` trace        |
| `-q`, `--quiet`   | none                | decrease verbosity, from warnings to silence          |
| `-s`, `--set`     | `SECTION:KEY=VALUE` | override one config value, may be repeated            |
| `--check`         | none                | validate without publishing files, versions, or reports |
| `--watch`         | none                | convert when local Wiki files change                  |
| `-V`, `--version` | none                | show version and exit                                 |
| `-h`, `--help`    | none                | show help and exit                                    |

## Option rules

- `--verbose` and `--quiet` cannot be combined
- `--set` changes configuration in memory and does not edit the INI file
- `--check` still reads the baseline and writes configured ordinary logs
- `--check --watch` validates continuously without publishing output
- one-shot failures return a nonzero exit status, warnings alone do not
- `--watch` uses the timing values from `[watch]`
- `[app] max_runtime` can stop a watch invocation after a configured duration

## Examples

Run one conversion:

```text
wiki2user
```

Validate before writing:

```text
wiki2user --check
```

Run continuously:

```text
wiki2user --watch
```

Use another config file:

```text
wiki2user --config d:/apps/wiki2user/service.ini --watch
```

Override the polling interval for one invocation:

```text
wiki2user --set watch:poll=30s --watch
```

Enable `DEBUG` output where handler configuration permits it:

```text
wiki2user -v --watch
```

The installed Python workspace also supports `python -m wiki2user` with these
options.

## Logging levels

- no verbosity option: `INFO`
- `-v`: `DEBUG`
- `-vv`: `TRACE`
- `-q`: `WARNING`
- `-qq`: `ERROR`
- `-qqq`: `CRITICAL`
- `-qqqq`: no output

Handler-specific levels can only make a destination quieter. See
[settings.md](settings.md) for logging configuration.

## See also

- [overview.md](overview.md)
- [quickstart.md](quickstart.md)
- [settings.md](settings.md)
- [troubleshooting.md](troubleshooting.md)
