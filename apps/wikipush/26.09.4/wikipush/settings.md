[back to overview](overview.md)
---

# Settings

Canonical configuration reference for wikipush.

## Files and syntax

- default configuration: `wikipush.ini` in the working directory for Python,
  beside the executable for a Windows EXE
- template: [wikipush.example.ini](wikipush.example.ini)
- relative input paths: based on the configuration file directory
- relative log paths: based on the working directory for Python, beside the
  executable for a Windows EXE, including when `--config` selects another file
- command-line override: `--set SECTION:KEY=VALUE`, repeatable
- local credentials: keep the configuration untracked

General INI syntax is documented in
[toolkit config syntax](config/syntax.md).

## Required settings

Set `api`, `username`, and `password` in `[mediawiki]`, and at least one
directory-to-namespace mapping in `[pages]`. Create the input root and every
mapped directory. All other settings have defaults.

## [mediawiki]

| key        | default  | notes                                    |
| ---------- | -------- | ---------------------------------------- |
| `api`      | required | absolute HTTP or HTTPS MediaWiki API URL |
| `username` | required | account or bot username                  |
| `password` | required | password or bot password                 |

Authentication follows wikiread. The account additionally needs create and
edit rights in the target namespaces. Prefer HTTPS. Embedded credentials in
the API URL are rejected.

## [input]

| key    | default | notes                                      |
| ------ | ------- | ------------------------------------------ |
| `path` | `input` | root containing the configured directories |

The root and every configured directory must exist. Only regular `.wiki` files
directly inside those directories are selected. Entries with other extensions
are ignored, and subdirectories are never searched. A directory whose name
ends in `.wiki` (case-insensitive) is rejected as not a regular file. Symbolic
links and junctions at the selected root, group, or file are rejected. The tool
does not modify input files.

An empty selection succeeds without contacting the Wiki.

## [pages]

Each key is one direct input directory. Its value is exactly one target
namespace, without a colon. At least one key is required.

```ini
[pages]
config = config
dist = dist
```

An empty value selects the main namespace. Namespace names and directory keys
use lowercase ASCII letters, digits, periods, underscores, and hyphens.
Canonical namespace names and aliases are resolved against the Wiki. Unknown
namespaces stop the run.

## Filename mapping

- lowercase `.wiki` extension and filename stem required
- stems may contain ASCII letters, digits, `.`, `_`, and `-`
- Windows device names, trailing periods, and unsafe components rejected
- total filename length limited to 240 characters
- underscores become spaces in the Wiki title
- first-letter capitalization follows the target namespace's rules
- canonical destination names returned by the Wiki are used for writing
- two files resolving to the same destination always stop the run

For example, `input/config/mail_settings.wiki` maps to `Config:Mail settings`
when the Wiki uses `Config` and first-letter capitalization.

## Content

Files contain complete UTF-8 Wikitext without a BOM or NUL characters. CRLF
and CR line endings are normalized to LF. Empty files explicitly clear the
destination's content.

The comparison accounts for trailing whitespace removed by MediaWiki. Other
Wiki pre-save transformations, such as template substitution and signatures,
remain server behavior. They can make a preview report an update that the
Wiki subsequently accepts without creating a revision. Prefer already
expanded content for reproducible migration runs.

## [push]

| key          | default                               | notes                        |
| ------------ | ------------------------------------- | ---------------------------- |
| `check_case` | `false`                               | scan for title case variants |
| `summary`    | `wikipush: update from local Wikitext` | edit summary                 |

The example enables `check_case`. When enabled, wikipush lists titles in each
selected namespace, including redirects. A different title equal under
case-insensitive comparison is a conflict. Normal first-letter capitalization
is already accounted for and does not cause a conflict.

All discovered case conflicts are logged and the run stops before writing any
page. This is a preflight check, not a lock against concurrent Wiki edits.

There is no content conflict guard. Existing content is deliberately replaced.
Missing local files never cause Wiki deletions. Renames select a new destination
and leave the old page intact.

## Logging

Logging follows toolkit and wikiread conventions.

| section           | key         | example        |
| ----------------- | ----------- | -------------- |
| `logging`         | `/asyncio`  | `WARNING`      |
| `logging console` | `log_level` | `INFO`         |
| `logging pipe`    | `log_level` | `INFO`         |
| `logging file`    | `log_file`  | `wikipush.log` |
| `logging file`    | `log_level` | `DEBUG`        |

Relative logger names belong to `wikipush`. A leading `/` selects an absolute
logger name. Pipe output uses a numeric level prefix. Empty `log_file` disables
file logging. `-v` permits DEBUG records, while individual handlers can remain
quieter. See [toolkit logging settings](logs/settings.md)
for formatting and handler options.

With the example configuration, `-v` writes unchanged-page diagnostics to the
log file while console and pipe output stay at INFO. To show these diagnostics
on standard output as well:

```powershell
wikipush -v --set "logging console:log_level=DEBUG" --set "logging pipe:log_level=DEBUG"
```
