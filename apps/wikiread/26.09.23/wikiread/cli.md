[back to overview](overview.md)
---

# CLI

Command and option reference for wikiread.

## command

```text
wikiread [options]
```

Without `--watch`, wikiread performs one synchronization and exits.

## options

| option            | value               | purpose                                        |
| ----------------- | ------------------- | ---------------------------------------------- |
| `-c`, `--config`  | `TEXT`              | config filename, default `wikiread.ini`        |
| `-v`, `--verbose` | none                | increase verbosity, `-v` debug and `-vv` trace |
| `-q`, `--quiet`   | none                | decrease verbosity, from warnings to silence   |
| `-s`, `--set`     | `SECTION:KEY=VALUE` | override one config value, may be repeated     |
| `--watch`         | none                | continue monitoring MediaWiki changes          |
| `-V`, `--version` | none                | show version and build information, then exit  |
| `-h`, `--help`    | none                | show help and exit                             |

## option rules

- `--verbose` and `--quiet` cannot be combined
- `--set` changes configuration in memory and does not edit the INI file
- `--watch` uses the timing values from `[watch]`
- the default config is beside the executable and shares its filename stem

See [settings.md#files](settings.md#files) for path resolution.

## examples

Run one synchronization:

```text
wikiread
```

Run continuously:

```text
wikiread --watch
```

Use another config file:

```text
wikiread --config d:/apps/wikiread/service.ini --watch
```

Override the polling interval for one invocation:

```text
wikiread --set watch:poll=30s --watch
```

Enable `DEBUG` output where handler configuration permits it:

```text
wikiread -v --watch
```

## logging levels

- no verbosity option: `INFO`
- `-v`: `DEBUG`
- `-vv`: `TRACE`
- `-q`: `WARNING`
- `-qq`: `ERROR`
- `-qqq`: `CRITICAL`
- `-qqqq`: no output

Handler-specific levels can only make a destination quieter. See
[settings.md](settings.md) for logging configuration.

## see also

- [overview.md](overview.md)
- [quickstart.md](quickstart.md)
- [settings.md](settings.md)
- [troubleshooting.md](troubleshooting.md)
