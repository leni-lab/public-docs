[back to overview](overview.md)
---

# Settings

Canonical configuration reference for wikiread.

## files

- the executable uses `wikiread.ini` beside `wikiread.exe` by default
- renaming the executable also changes the default INI filename to its stem
- use `--config` to select another INI file
- create it from [wikiread.example.ini](wikiread.example.ini)
- keep it local and untracked because it normally contains credentials
- relative output and Git executable paths resolve from the INI directory
- relative log paths resolve from the executable directory

See also: [quickstart.md](quickstart.md).

## value syntax

- the file uses standard INI sections and keys
- durations accept values such as `30s`, `1min`, and `5min`
- `--set SECTION:KEY=VALUE` overrides a value for one invocation

See [submodules/toolkit/config/syntax.md](config/syntax.md)
for general INI syntax.

## minimal required keys

- `[mediawiki]`: `api`, `username`, and `password`
- `[pages]`: at least one named output group with at least one selector

`[output]` and `[watch]` have defaults.

## [mediawiki]

MediaWiki connection and authentication.

| key        | default  | notes                                    |
| ---------- | -------- | ---------------------------------------- |
| `api`      | required | absolute HTTP or HTTPS MediaWiki API URL |
| `username` | required | account or bot username                  |
| `password` | required | password or bot password                 |

Example:

```ini
[mediawiki]
api             = https://example.org/w/api.php
username        = wikiread
password        = bot-password
```

The account needs read access to every selected namespace and page. Prefer
HTTPS because credentials are sent to the MediaWiki login API.

## [output]

Local root directory owned by wikiread.

| key    | default  | notes                                           |
| ------ | -------- | ----------------------------------------------- |
| `path` | `output` | root containing one directory per `[pages]` key |

Group directories are created when files are written. Empty directories are
removed after synchronization.

Do not place consumer caches, history, generated output, or manually managed
`.wiki` files below this path. With Git versioning enabled, wikiread manages
its own history in `.git` below this directory.

## [git]

Optional local versioning of successful synchronization results. Disabled by
default. Works with both one-shot synchronization and `--watch`.

| key               | default                | meaning                                                |
| ----------------- | ---------------------- | ------------------------------------------------------ |
| `enabled`         | `no`                   | enable local Git history                               |
| `path`            | `../mingit/cmd/git.exe` | executable path relative to the INI directory           |
| `name`            | required when enabled  | commit author name                                     |
| `email`           | required when enabled  | commit author email                                    |
| `timeout`         | `30s`                  | timeout per Git command, minimum `1s`                   |
| `trust_directory` | `no`                   | trust the output repository even with a different owner |

Example layout with MinGit beside the application:

```text
apps/
    mingit/
        cmd/git.exe
        ...
    wikiread/
        wikiread.exe
        wikiread.ini
        output/
```

Extract the complete standard [MinGit distribution](https://gitforwindows.org/mingit.html)
into `mingit/`, keeping its supporting files. Use a maintained version of Git
(minimum 2.29). No installation, administrator access, or `PATH` changes are
needed. Multiple applications can share this directory.

```ini
[git]
enabled = yes
path = ../mingit/cmd/git.exe
name = wikiread
email = wikiread@localhost
timeout = 30s
```

wikiread creates a dedicated repository at `[output] path/.git` on first use.
Existing repositories not created by the archive feature are rejected. Commit
identity comes from this INI, without changing global Git configuration.

Set `trust_directory = yes` only when the output repository is trusted but
belongs to another filesystem user, such as a service account. This handles
Git's `detected dubious ownership` error for this output directory only.
Filesystem permissions and archive ownership checks still apply. Global Git
configuration, including user-wide `safe.directory` exceptions, is ignored.

Each successful sync with content changes produces one commit on `main`.
New files and deletions are included. Identical content and changes only to
file timestamps produce no commit. Existing files are first archived after a
successful sync, so enabling this feature does not back up pre-sync contents.

Commit failures preserve the completed output and block the next sync until
archiving succeeds. Watch mode retries Git execution failures using `[watch]`
backoff. After a one-shot failure, rerun the command to recover first.
Incomplete or ambiguous interrupted runs are handled as described in
[troubleshooting](troubleshooting.md#git-archive-is-interrupted).

Only wikiread should write to this output directory. Do not edit files, switch
branches, or run modifying Git commands there while wikiread is active or a
snapshot is pending. Different applications need separate output repositories.
The archive lock file beside the output directory may remain after shutdown.

The history is local. Push to another system is not included in this version.
The current output is still updated one file at a time for consumers.

## [pages]

Every key defines one direct output directory. Its value contains one or more
selectors separated by commas or whitespace:

```ini
[pages]
legacy          = keywords, stichworte
config          = config/*
```

The key must already be a safe normalized name containing only lowercase
ASCII letters, digits, periods, underscores, and hyphens.

Selector syntax:

```text
[<namespace>/]<title>[*]
```

- no slash means the main namespace
- one slash separates an exact namespace from the title
- `*` is optional and allowed only once as the final character
- a final `*` selects every title with the preceding prefix
- selectors under one key form a union
- the same page may be selected under multiple keys
- namespace and selector components use lowercase ASCII names
- redirects are excluded, including when selected by exact title

Examples:

| selector          | selection                                  |
| ----------------- | ------------------------------------------ |
| `keywords`        | page `Keywords` in the main namespace      |
| `leni-*`          | main-namespace pages starting with `Leni-` |
| `config/keywords` | page `Config:Keywords`                     |
| `config/user-*`   | pages starting with `User-` in `Config`    |
| `config/*`        | all eligible pages in `Config`             |
| `*`               | all eligible pages in the main namespace   |

Unsupported examples:

```text
*archive
user-*-settings
config/**
config/foo/bar
*/keywords
```

## title-to-file mapping

The namespace selects a Wiki area but does not create a local directory. The
`[pages]` key determines the directory and the page title determines the file:

```text
legacy = keywords   -> legacy/keywords.wiki
config = config/*   -> config/mail_settings.wiki
mirror = config/*   -> mirror/mail_settings.wiki
```

Title normalization:

- convert ASCII `A-Z` to `a-z`
- convert spaces to `_`
- retain ASCII digits, `.`, `_`, and `-`
- append `.wiki`
- reject slashes, Unicode, unsafe Windows names, and ambiguous paths

Different titles that map to the same path cause an error. Titles outside the
safe mapping are ignored with a warning. Unexpected uppercase letters produce
an editorial warning.

## local ownership

At startup, every existing `.wiki` file must:

- be exactly one directory below the output root
- reside below a configured `[pages]` key
- match a current selector for that key

An unmatched file stops synchronization before the remote read. If a selected
Wiki page disappears after a complete remote read, its local file is deleted.
An empty remote selection is treated as an error and leaves local files intact.

## [watch]

Timing for `--watch` operation.

| key           | default | notes                                            |
| ------------- | ------- | ------------------------------------------------ |
| `poll`        | `1min`  | delay after a successful poll or synchronization |
| `backoff`     | `10s`   | delay after the first transient failure          |
| `backoff_max` | `5min`  | maximum delay while backoff doubles              |

`backoff` must not exceed `backoff_max`. A MediaWiki `Retry-After` value
overrides the calculated delay for that retry. All three timing values must
be at least `1s`. Transient failures are retried until recovery or shutdown,
without a retry-count limit.

## [logging]

Per-logger level overrides.

- keys without `/` are relative to the `wikiread` logger hierarchy
- keys beginning with `/` name an absolute third-party logger
- the example uses `/asyncio = WARNING` to suppress event-loop internals

## [logging console]

Interactive console output.

| key          | sample        | notes                        |
| ------------ | ------------- | ---------------------------- |
| `log_level`  | `INFO`        | minimum console level        |
| `color_mode` | `auto`        | `auto`, `always`, or `never` |
| `format`     | `%(message)s` | Python logging format        |

## [logging pipe]

Output used instead of the console handler when stdout is not connected to a
terminal.

| key         | sample | notes              |
| ----------- | ------ | ------------------ |
| `log_level` | `INFO` | minimum pipe level |

Pipe messages use a fixed numeric level prefix.

## [logging file]

Optional log file output.

| key           | sample              | notes                       |
| ------------- | ------------------- | --------------------------- |
| `log_file`    | `wikiread.log`      | empty disables file logging |
| `log_level`   | `DEBUG`             | minimum file level          |
| `format`      | toolkit preset      | Python logging format       |
| `date_format` | `%Y-%m-%d %H:%M:%S` | timestamp format            |
| `encoding`    | `utf-8`             | file encoding               |

CLI verbosity is a global gate. Use `-v` to permit `DEBUG` records. Handler
levels can make individual destinations quieter, so the example keeps the
console at `INFO` while the file receives `DEBUG` records.

See [submodules/toolkit/logs/settings.md](logs/settings.md)
for the complete logging behavior.

## see also

- [overview.md](overview.md)
- [quickstart.md](quickstart.md)
- [cli.md](cli.md)
- [troubleshooting.md](troubleshooting.md)
- [wikiread.example.ini](wikiread.example.ini)
