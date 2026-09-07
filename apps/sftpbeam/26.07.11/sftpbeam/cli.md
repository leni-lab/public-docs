[back to overview](overview.md)
---

# cli

command and option reference for sftpbeam.

## command

```bash
sftpbeam [options] <name>
```

- `<name>` is the pipeline name
- `<name>` must match `[input <name>]` and `[transfer <name>]`

## options

| option | value | purpose |
| --- | --- | --- |
| `-c`, `--config` | `TEXT` | config filename, default `sftpbeam.ini` |
| `-v`, `--verbose` | none | increase verbosity (`-v` debug, `-vv` trace) |
| `-q`, `--quiet` | none | decrease verbosity (`-q` warning to `-qqqq` silent) |
| `-s`, `--set` | `SECTION:KEY=VALUE` | override config value, may be repeated |
| `--max-runtime` | `DURATION` | stop after duration, overrides config |
| `--check` | `[NAME]` | verify sftp host key and exit |
| `--accept-new-key` | none | add unknown host key, requires `--check <name>` |
| `--remove-key` | none | remove stored host key, requires `--check <name>` |
| `-h`, `--help` | none | show help and exit |

## option combination rules

- `--check` without `<name>` checks all configured `[sftp <name>]` sections
- `--check <name>` checks only one `[sftp <name>]` section
- `--accept-new-key` and `--remove-key` require `--check <name>`
- `--accept-new-key` and `--remove-key` cannot be combined

## examples

- run pipeline `orders`:

```bash
sftpbeam orders
```

- run with runtime cap:

```bash
sftpbeam orders --max-runtime 30min
```

- run with one config override:

```bash
sftpbeam orders --set transfer:remote_dir=/incoming/orders
```

- check all host keys from config and exit:

```bash
sftpbeam --check
```

- check one host and accept key without prompt:

```bash
sftpbeam --check order-server --accept-new-key
```

## notes

- use either `--verbose` or `--quiet` for log level bias
- for full key semantics and defaults, see [settings.md](settings.md)

## see also

- [overview.md](overview.md)
- [quickstart.md](quickstart.md)
- [settings.md](settings.md)
- [sftpbeam.example.ini](sftpbeam.example.ini)
