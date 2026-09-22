[back to overview](overview.md)
---

# Settings

`configtrack.ini` controls discovery and operation. Each application's
`appinfo.ini` controls whether its configuration files are archived.

## Application manifests

```ini
[app example]
title = Example application
config_files = config.ini, settings/access.ini
configtrack = true
```

| key | default | behavior |
| --- | --- | --- |
| `configtrack` | `false` | enable this app's selection |
| `config_files` | required when enabled | comma-separated concrete filenames, using the same selection as configview |

The archive always includes `appinfo.ini` when at least one app is enabled.
Metadata such as `title`, `description`, `group`, and `config_profile` remains
available to configview and does not affect tracking.

Paths are relative to the manifest directory. Absolute paths are accepted only
inside that directory. Use `/` in relative paths. Wildcards, directories,
parent traversal, `.git` paths, symbolic links, junctions, and hard links are
rejected. Selected files that do not exist are omitted from the new snapshot,
recording a deletion if they appeared in an earlier commit.

All enabled app sections in one manifest contribute to one deduplicated
selection and one commit. Removing a filename or disabling an app removes its
exclusive files from the next snapshot while another app remains enabled.
Files on disk and previous commits are retained. With all apps disabled, the
repository is left unchanged, including the last archived manifest.

## Discovery

```ini
[appinfo local]
patterns = C:/apps/**/appinfo.ini, D:/services/*/appinfo.ini
```

The unnamed `[appinfo]` section and multiple `[appinfo <name>]` sections are
supported, matching configview. An optional `title` is accepted for shared
discovery settings. Patterns are comma-separated and relative to
`configtrack.ini`. `*` matches within a directory and `**` includes descendants.
Duplicate matches are processed once. Missing search roots have no matches.

## Git

| key in `[git]` | default | behavior |
| --- | --- | --- |
| `path` | `../mingit/cmd/git.exe` | executable path relative to configtrack.ini |
| `name` | `configtrack` | commit author and committer name |
| `email` | `configtrack@localhost` | commit author and committer email |
| `timeout` | `30s` | timeout per Git command |
| `enabled` | `yes` | optional global pause, individual apps must still opt in |
| `trust_directory` | `no` | explicitly trust the archive directory for each Git invocation |

Repositories are created directly in the manifest directory, with `.git`
beside `appinfo.ini`. Parent repositories are never used. Existing repositories
must be toolkit archives with the toolkit ownership marker and branch `main`.
Ordinary source repositories are rejected. Use a deployment directory when the
application source itself is under Git.

## Watch

| key in `[watch]` | default | behavior |
| --- | --- | --- |
| `poll` | `1min` | interval between successful passes |
| `backoff` | `10s` | initial retry delay after a transient failure |
| `backoff_max` | `5min` | maximum exponential retry delay |

Durations must be at least one second. `backoff` must not exceed `backoff_max`.
These settings apply with `--watch`; the default command performs one pass.

Toolkit logging sections and standard CLI overrides are supported. For example:

```powershell
configtrack --watch -s watch:poll=10s
```
