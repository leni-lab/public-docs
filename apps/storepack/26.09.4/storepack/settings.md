[back to overview](overview.md)
---

# Settings

Configuration uses INI syntax. Relative store paths resolve beside the INI
file. See [configuration syntax](config/syntax.md) for
includes and overrides.

## Required settings

```ini
[store]
path = D:/data/store
```

The store must already exist. See the
[example configuration](storepack.example.ini) for a complete configuration.

## Store

| key | default | meaning |
| --- | --- | --- |
| `path` | required | existing store directory |
| `match` | `*` | one case-sensitive filename glob, such as `*.json` |
| `min_age` | `48h` | elapsed time after the end of a local calendar day |

The glob supports `*`, `?`, and character classes such as `[0-9]`. It cannot
contain directory separators. There is no recursive scan. Files with invalid
timestamp prefixes, symbolic links, and hard links remain unchanged.

Durations accept integer values with `ms`, `s`, `min`, or `h`, such as `50ms`,
`30s`, or `72h`. `min_age=0s` still waits until the file's local day has ended.
There is no per-file readiness timeout or stability wait.

## Runtime and logging

```ini
[app]
max_runtime = 2h

[logging file]
log_file = storepack.log
```

`[app] max_runtime` is optional. `--max-runtime` overrides it. The limit
requests a graceful stop after the active day, rather than interrupting a ZIP
write. See [logging settings](logs/settings.md) for
console and file output. Relative log paths resolve beside the executable,
or in the working directory for the installed Python command.
