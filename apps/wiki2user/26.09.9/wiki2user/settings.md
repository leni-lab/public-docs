[back to overview](overview.md)
---

# Settings

Use `wiki2user.ini` beside the executable by default or select another file
with `--config PATH`. Start from
[wiki2user.example.ini](wiki2user.example.ini).

Application paths are relative to the selected configuration file. Toolkit
logging paths follow toolkit rules. Values may reference settings such as
`${output:path}/archive`.

The file uses the shared [INI syntax](config/syntax.md),
including interpolation and optional include directives.

## Required settings

Only the local Wiki entry file is required:

```ini
[input]
file = ../wikiread/output/config/users.wiki
```

Without further settings, output is written below `output` relative to the
configuration file.

## Input

| section and key | default | meaning |
| --- | --- | --- |
| `input:file` | required | entry file ending in `.wiki` |

Includes resolve beside the entry file. Watch mode observes all direct
`.wiki` files in that directory.

## Output and history

| section and key | default | meaning |
| --- | --- | --- |
| `output:path` | `output` | current three-file usermgr set |
| `output:previous` | empty | initial complete baseline |
| `archive:path` | `${output:path}/archive` | immutable versions |
| `reports:path` | `${output:path}/reports` | import reports |

Before the first archived version, an empty `previous` uses the current
output directory. A configured baseline must be an existing directory and
contain all three declared files or none. Once a version exists, the newest
published version is the comparison baseline.

Archive and report roots may be elsewhere, but a single producer instance
must have exclusive write ownership.

## Watch and runtime timing

| section and key | default | meaning |
| --- | --- | --- |
| `watch:poll` | `1min` | interval between input observations |
| `watch:backoff` | `10s` | first transient retry delay |
| `watch:backoff_max` | `5min` | maximum doubled delay |
| `app:max_runtime` | empty | stop watch mode after this duration |

The three `watch` durations must be at least one second, and backoff cannot
exceed its maximum. An empty `max_runtime` allows watch mode to run until
stopped. Invalid Wiki data waits for an input change. See the shared
[duration syntax](fields/syntax.md).

## Logging

Toolkit owns `[logging]`, `[logging console]`, `[logging pipe]`, and
`[logging file]`. Use `--verbose` or `--quiet` to adjust the application
threshold. See the shared
[logging settings](logs/settings.md) for handler options.
