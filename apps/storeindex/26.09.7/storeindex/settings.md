[back to overview](overview.md)
---

# Settings

Configuration uses INI syntax. See the
[complete example](storeindex.example.ini).

```ini
[store]
path = D:/data/store

[index]
database = storeindex.sqlite3
poll = 10
timeout = 30
busy_timeout = 1

[source leni]
command = ["leniextract"]
revision = 1
```

Paths resolve beside the INI. Keep the database on local storage outside the
store. The store may contain both loose messages and daily ZIPs.

Storeindex uses the local system timezone, including daylight saving time,
like storepack. Both systems must use the same timezone. Remove `timezone`
from existing `[store]` sections, as this setting is no longer supported.

| setting | default | meaning |
| --- | --- | --- |
| `store.path` | required | existing published store |
| `index.database` | `storeindex.sqlite3` | local database path outside store |
| `index.poll` | `10` | seconds between completed incremental passes |
| `index.timeout` | `30` | extractor timeout per message, in seconds |
| `index.busy_timeout` | `1` | database contention wait, in seconds |
| `source <name>.command` | required | JSON array containing executable and arguments |
| `source <name>.revision` | `1` | extraction revision managed by the operator |

All durations must be positive, finite numbers. Unknown settings are rejected.

## Extractors

Configure at least one source. Each source may use a different extractor.
An executable name is resolved through PATH. Activate the appropriate Python
environment or specify an executable path, for example:

```ini
[source leni]
command = [".venv/Scripts/leniextract.exe"]
revision = 1
```

This relative path assumes `.venv` is beside the INI. Commands use that same
directory as their working directory. Additional arguments are passed
unchanged. Shell commands and shell expansion are not supported.

Increment `revision` after changing extraction behavior. Subsequent passes
refresh loose messages. Refresh archived messages with a manual rebuild.

## Message names

Messages use `<timestamp>_<suffix>.<source>.json`, for example:

```text
1789203039_001.leni.json
```

The timestamp is whole Unix seconds without leading zeros. The numeric suffix
has at least three digits, padded with leading zeros. Source names begin with
a lowercase ASCII letter and otherwise contain lowercase letters, digits,
underscores, or hyphens. Imports may arrive in any order.

Messages must be complete when published and unchanged afterward. ZIPs use
the storepack layout: `YYYY-MM/YYYY-MM-DD.zip` with flat message entries
belonging to that local calendar day.
