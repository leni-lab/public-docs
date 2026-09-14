[back to overview](overview.md)
---

# Settings

Use `configview.ini` beside the standalone EXE, or in the working directory when
running from Python. `--config` selects another file. Start from
[configview.example.ini](configview.example.ini):

```ini
[format usermgr]
renderer    = C:/apps/configview-usermgr/.venv/Scripts/configview-usermgr.exe

[appinfo dev]
title = Local development
patterns = C:/apps/**/appinfo.ini

[appinfo exports]
title = Exported configurations
patterns = D:/config/*/appinfo.ini

[git]
enabled         = yes
path            = ../mingit/cmd/git.exe
timeout         = 30s
trust_directory = no
limit           = 100
```

An `appinfo.ini` can describe files beside it or files at absolute paths:

```ini
[app usermgr]
title = User management
description = Production users, groups, and permissions
group = Administration
config_files = users.ini, groups.ini, permissions.ini
config_profile = usermgr
archive_files = users.ini, groups.ini, permissions.ini
reports = reports/*
logs = D:/logs/usermgr.log

[app usermgr_hello]
title = Hello settings
description = Additional configuration using the general file view
config_files = hello.ini
```

## Application discovery

Use `[appinfo <name>]` sections to divide the start page into areas. Each section
has required `patterns` and an optional `title`, which defaults to its name.
Areas follow section order in the settings file. Each area is initially open
and can be collapsed by selecting its heading, which also shows its app count.
Group headings from app manifests are combined only within the same area.
Changing an area name, title, or assignment does not change app URLs.

The original `[appinfo]` section remains supported. Without a `title`, its apps
appear before named areas without an area heading, alongside direct
configurations. Set `title` to give it a collapsible area of its own.

`patterns` is a comma-separated list of file search patterns. Relative
patterns use the directory containing `configview.ini`. `*` matches within one
path component; `**` as a complete component matches zero or more directory
levels. For example, `apps/**/appinfo.ini` also finds `apps/appinfo.ini`, whereas
`apps/*/appinfo.ini` finds files exactly one directory below `apps`.

Patterns are processed in declaration order, with each pattern's matches sorted
by path. Hidden files and directories are included. Recursive search does not
follow directory symbolic links or Windows junctions. Duplicate file paths are
read once across all areas and assigned to the first matching section. The
unnamed `[appinfo]` section is processed first when present. Missing roots have
no matches; access errors stop loading with a diagnostic. If a section's
combined patterns find no files, startup fails. Exclusions are not supported.

Discovery runs at startup. Restart configview after changing, adding, or removing
an `appinfo.ini`. Changes to the selected configuration files remain visible in
the current-file views without restarting.

Every `[app <name>]` section is independent. Everything after `app ` is the app
name, including spaces or underscores; names do not imply hierarchy or
inheritance. The same name may appear in different manifests, even with the
same profile. Each app is identified by its normalized full manifest path and
section name. Its URL always includes a stable suffix, for example
`/app/usermgr-a82f194c013b`. Changing the title, group, profile, or discovery
order does not change the URL. Moving the manifest or renaming the section does.
The start page shows manifest paths when app names or display titles repeat.

| key              | default     | meaning                                      |
| ---------------- | ----------- | -------------------------------------------- |
| `config_files`   | absent      | ordered relative or absolute file paths      |
| `config_profile` | `generic`   | selects `[format <id>]` renderer settings     |
| `title`          | app name    | display title in lists, navigation, and pages |
| `description`    | empty       | explanatory text in lists and app overview   |
| `group`          | empty       | optional group heading on the start page     |

The start page links directly to every app, showing its title and description
in compact rows. Within each area, apps without a group appear first, without
a group heading. Named groups follow
in alphabetical order, ignoring case, with apps in discovery order within
each group. Surrounding whitespace is removed from group names. Equal names
are combined across manifests in the same area, regardless of profile. Group names are
case-sensitive, flat labels and do not imply hierarchy. There are no separate
group pages.

`group` affects only the start page. It does not change app identity, file paths,
the renderer, or Git history. Profile names do not appear as navigation levels
or group headings. Old profile/name links redirect when they identify one app.
An ambiguous old link asks the user to select an app on the start page. Direct
configuration links retain their existing URLs. Former profile overview URLs
redirect to the start page.

The app detail page shows the full manifest path as a single collapsed
control. Expand it to see the file loaded at startup, with syntax
highlighting, line numbers, and the selected app section emphasized. The source
is retained until restart, so later file edits do not change this display.
File and Git directories are not shown as additional metadata rows.

Relative `config_files` paths use the directory containing `appinfo.ini`.
Absolute filenames are also accepted, including Windows drive paths and UNC
paths. For example, a local manifest can refer to a remote file:

```ini
[app transfer]
title = Remote transfer settings
config_files = //server/share/transfer/transfer.ini
```

Configview resolves relative entries against the manifest directory, then uses
the deepest common directory containing all selected files as their file root.
Relative and absolute spellings produce the same result. Files in different
subdirectories retain those subdirectory names for display.

Git history uses the nearest repository containing each selected file. The
search starts in each file's directory and continues through its parents.
All files must belong to the same repository. Git paths are relative to that
repository, while displayed filenames remain relative to the file root.
For example, `data.wiki/users.ini` can use `data.wiki/.git`, or a repository
above `data.wiki`. The manifest location does not select the repository.

The history area distinguishes a missing repository from a repository with no
versions for the selected files. Separate repositories require separate app
sections. Files on different drives or network shares cannot belong to one
entry. Missing target files do not prevent settings loading and are reported in
current views.

Specify filenames, not directories or wildcard patterns. Absolute Windows paths
accept `/` or `\`. Relative paths use `/`. Duplicate references to the same file
are rejected, including a mixture of relative and absolute spellings.

An absent or blank profile uses general file views, with `generic` retained as
the internal profile identifier. A renderer cannot be configured for `generic`.
Other profiles also work without a renderer. Titles do not change URLs.

Sections without `config_files` are ignored by configview. An explicitly empty
or invalid file list is an error. `archive_files`, `reports`, and `logs` are
metadata for other tools and are ignored here. Configview does not archive files.

## Direct configurations

Existing `[config <format> <name>]` sections remain supported and can coexist
with discovery. The format, name, `path`, and `files` are required. Descriptions
and `[format]` sections are optional. Names may contain spaces. Relative paths
use the settings file's directory.

Settings in `[config <format> <name>]`:

| key           | default  | meaning                                     |
| ------------- | -------- | ------------------------------------------- |
| `path`        | required | current file root                          |
| `files`       | required | ordered comma-separated relative file paths |
| `description` | empty    | instance description                        |

## Renderers

Settings in `[format <id>]`:

| key           | default | meaning                                            |
| ------------- | ------- | -------------------------------------------------- |
| `renderer`    | empty   | executable path or command name, without arguments |
| `timeout`     | `30s`   | renderer time limit, minimum `1s`                  |

Format sections only configure rendering. The former `description` setting is
ignored and can be removed. Put app descriptions in `appinfo.ini` instead.

Install a renderer separately and set its executable path. For usermgr, see
[renderer installation](https://github.com/leni-lab/configview-usermgr/blob/main/user-docs/operation.md).
The example above assumes a Python environment under
`C:/apps/configview-usermgr`. Adjust it to your installation. Its console
launcher requires that environment. The [example INI](configview.example.ini)
uses a source checkout's environment.

The renderer embeds CSS and JavaScript in its output, so no asset export or
configuration is needed. Former `css` and `js` settings can be removed. Bare
command names are resolved through PATH at startup. Paths are relative to the
settings file. Batch scripts are unsupported.

Without a renderer, original file views and comparisons remain available. A
renderer error leaves the file summary and INI links accessible.

## Git, server, and runtime

Settings in `[git]`:

| key               | default                 | meaning                                          |
| ----------------- | ----------------------- | ------------------------------------------------ |
| `enabled`         | `no`                    | enable history for configured roots              |
| `path`            | `../mingit/cmd/git.exe` | Git executable, relative to the settings file    |
| `timeout`         | `30s`                   | timeout per command, minimum `1s`                |
| `trust_directory` | `no`                    | trust repositories with another filesystem owner |
| `limit`           | `100`                   | maximum commits per configuration, 1 to 1000     |

Server and lifecycle settings:

| section  | key           | default     | meaning                                    |
| -------- | ------------- | ----------- | ------------------------------------------ |
| `server` | `host`        | `127.0.0.1` | binding IP address or `localhost`          |
| `server` | `port`        | `8080`      | TCP port                                   |
| `app`    | `max_runtime` | empty       | duration before shutdown, for example `8h` |

The optional `[app] max_runtime` setting requests shutdown after the given
duration. Leave it unset for continuous operation. It does not restart the
server. See [shutdown and restart](operation.md#shutdown-and-restart).

## File selection and upgrades

`config_files` in appinfo and `files` in direct configurations preserve the
configured order for display, comparison, and renderer arguments. Several
configurations can use the same directory, selecting different
files such as `transfer.ini` and `transfer_test.ini`. Shared files affect each
configuration that declares them. Use explicit names rather than wildcards.
Commas in filenames are unsupported. Changing the list also changes file
selection for old commits, without automatic filename migration.

Git is needed only for enabled history when a repository exists. Use the
complete MinGit distribution or an installed Git executable. No author, email,
or remote settings are needed because configview never creates commits.

For trusted shared directories, `trust_directory = yes` permits a different
filesystem owner. The exception applies only to each discovered repository during
configview's Git commands. It does not change permissions or write global Git
settings. Global settings, including global trust exceptions, are ignored.

Remove the former `archive` and `reports` keys from direct configuration
sections when upgrading. Existing
directory archives and report files remain untouched. They are not displayed or
automatically migrated. New reports belong to a separate viewer.

## Logging

The command line provides `--verbose`, `--quiet`, `--set`, `--version`, and
`--help`. The default threshold is `INFO`, `-v` selects `DEBUG`, `-vv`
selects `TRACE`, and `-q` selects `WARNING`. Handler `log_level` is an
additional minimum.

Console and pipe messages go to stderr. When stdout is not a terminal,
`[logging pipe]` replaces `[logging console]` and uses numeric severity
prefixes. Redirecting only stderr does not switch handlers. The example sets both handlers to `INFO`. An optional
`[logging file]` section enables file output with `log_file`. Keep application
logs outside the reviewed configuration roots.

### Examples

Console colors can be selected with `color_mode = auto`, `always`, or `never`.
For detailed diagnostics, set the handler floor to `TRACE`, then launch with
`-v` for DEBUG or `-vv` for TRACE. With `log_level = INFO`, those flags do not
lower the handler's minimum.

```ini
[logging console]
log_level  = TRACE
color_mode = auto

[logging pipe]
log_level = TRACE
```

For optional file output, select an existing log directory. An empty
`log_file` disables this handler. The same verbosity gate applies to file
output. Relative log paths use the application directory. These are the
available file handler settings:

| key           | default                                                        | meaning                         |
| ------------- | -------------------------------------------------------------- | ------------------------------- |
| `log_file`    | empty                                                          | output path                     |
| `log_level`   | `TRACE`                                                        | minimum severity                |
| `format`      | `[%(asctime)s] %(levelname)-7s - %(name)s - %(message)s`       | Python logging format           |
| `date_format` | `%Y-%m-%d %H:%M:%S`                                            | timestamp format                |
| `encoding`    | `utf-8`                                                        | text encoding                   |

```ini
[logging file]
log_file    = C:/logs/configview.log
log_level   = INFO
format      = [%(asctime)s] %(levelname)-7s - %(message)s
date_format = %Y-%m-%d %H:%M:%S
encoding    = utf-8
```

Keep logs outside the reviewed configuration roots. All handlers accept
`TRACE`, `DEBUG`, `INFO`, `WARNING`, `ERROR`, `CRITICAL`, or `SILENT`.
