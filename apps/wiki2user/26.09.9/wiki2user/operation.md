[back to overview](overview.md)
---

# Operation

## Generated files

wiki2user writes a complete administrative usermgr set:

- `users.wiki.ini`
- `groups.wiki.ini`
- `permissions.wiki.ini`

Files use Windows-1252 and CRLF. Passwords, mail addresses, reset markers,
personal settings, and unrelated local usermgr files are excluded.

Changed current files are replaced atomically one at a time. Unchanged files
retain their bytes.

## Metadata comments

Section metadata uses the common form:

```ini
[user alice]
# @meta: created: 2026-09-05T10:00:00Z
# @meta: changed: 2026-09-06T11:00:00Z
groups = editors
```

`created` records the first appearance known to the producer. `changed`
records the latest semantic change after a baseline was established. Existing
unmarked entries retain an unknown creation time. A deletion and later
reappearance begins a new lifetime.

These UTC timestamps describe observed configuration output. They are not
exact Wiki edit, import, version publication, or activation times.

## Versions and reports

The default roots are below the current output path:

```text
archive/
  2026-09-05T14-30-00Z/
    users.wiki.ini
    groups.wiki.ini
    permissions.wiki.ini
reports/
  2026-09-05T14-30-00Z.md
  2026-09-05T14-31-00Z.md
```

A numeric suffix such as `-1` resolves IDs allocated in the same second.
Dot-prefixed entries are private staging or maintenance data and are ignored
by readers.

A version is an immutable, complete configuration set. A new version is
published only when emitted semantic values differ from the newest version.
An unchanged import references the existing version.

A new version, current-output repair, or failed attempt publishes one UTF-8
Markdown report when possible. A successful unchanged import that writes no
current file publishes no report. The small header contains lowercase `status`
and, for successful attempts, `version`. Status values are:

| status | meaning |
| --- | --- |
| `ok` | conversion and activation completed |
| `warning` | conversion and activation completed with a warning |
| `error` | an intended step failed |

An error may reference a version published before activation failed. That
reference identifies the desired configuration and does not by itself claim
activation. The Markdown body contains human-readable details; consumers do
not parse it for status or navigation.

`--check` writes no current files, versions, or reports. Startup failures and
a failure to publish the report itself may leave no report, so retain ordinary
logs.

## Recovery and maintenance

A new version is published before current-file activation. If one replacement
fails, watch mode retries the same complete set before processing newer input.
The archived version remains intact for recovery after a restart.

Run one writer for each current, archive, and report root. There is no locking,
automatic cleanup, or retention command. Published versions and reports are
immutable. Keep only retention policies that preserve any version referenced
by a retained report.

Readers ignore all names beginning with `.`. They report other malformed
entries rather than treating the archive as empty.
