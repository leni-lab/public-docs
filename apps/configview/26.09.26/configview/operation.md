[back to overview](overview.md)
---

# Operation

## Settings

The default settings file is `configview.ini`: beside the standalone EXE,
or in the working directory when running from Python. `--config` selects a
different file. Copy `configview.example.ini` to `configview.ini` and add one
section for each configuration:

```ini
[format usermgr]
description = User management

[config usermgr test]
path = ../wiki2user/output/ini
archive = archive
reports = reports
description = Test instance
```

The configuration section has the form `[config <format> <name>]`. Its format
and name are required, and `path` is required. Descriptions and `[format]`
sections are optional. Configuration names may contain spaces.

| section                  | key         | default     | meaning                                    |
| ------------------------ | ----------- | ----------- | ------------------------------------------ |
| `config <format> <name>` | path        | required    | current configuration directory            |
| `config <format> <name>` | archive     | `archive`   | version archive                            |
| `config <format> <name>` | reports     | `reports`   | report root, empty disables reports         |
| `config <format> <name>` | description | empty       | instance description                       |
| `format <id>`           | description | empty       | format description                         |
| server                   | host        | `127.0.0.1` | binding IP address or `localhost`           |
| server                   | port        | `8080`      | TCP port                                   |
| app                      | max_runtime | empty       | duration before shutdown, e.g. `8h`         |

A relative current path uses the directory containing `configview.ini`.
Relative archive and report paths use the resolved current path. Absolute
paths are accepted.

Toolkit supplies standard options:

```text
configview --config configview.ini
configview --set server:port=8081
configview --verbose
configview --version
configview --help
```

The server binds locally by default and has no built-in authentication.
Shared access requires an access-controlled deployment.

## Logging

Without verbosity flags the global output threshold is `INFO`. `-v` lowers
it to `DEBUG`, `-vv` to `TRACE`, and `-q` raises it to `WARNING`.
Verbosity also applies to third-party libraries.

The handler's `log_level` is an additional minimum threshold. For example,
`log_level = TRACE` alone does not enable trace output without `-vv`, and
`log_level = INFO` suppresses debug output even with `-v`.

Toolkit writes console and pipe messages to stderr. When stdout is redirected,
as under a supervisor, `[logging pipe]` replaces `[logging console]`.
Pipe messages use numeric severity prefixes. The example INI sets both
handlers to `INFO`.

Rendering reports can produce many `entering ... StateBlock(...)` messages
from the Markdown parser when debug output is enabled. To retain application
debugging while suppressing that parser's internal messages, add:

```ini
[logging]
/markdown_it = WARNING
```

The leading `/` selects an absolute library logger name. This setting still
allows its warnings and errors. To suppress debug and trace messages in all
supervisor output, use:

```ini
[logging pipe]
log_level = INFO
```

An optional `[logging file]` section enables file output with `log_file`.
Relative log filenames use the EXE directory or, for Python runs, the working
directory. Keep logs outside the reviewed configuration roots.

## Shutdown and restart

configview checks its settings file and included INI files every two seconds.
A change or removal stops the server with exit code 0. A supervisor such as
tiusnanny can then restart it to load the updated settings. Changes to the
displayed configuration files or reports do not stop the server.

Ctrl+C, SIGTERM, and Windows Ctrl+Break request server shutdown. The exit code
is 128 plus the signal number. The Windows single-file EXE also exits its
application child if a supervisor forcibly terminates the EXE parent process.
Forced termination does not perform graceful cleanup.

There is no `--watch` flag: settings monitoring is always active while the
server runs. A configured `[app] max_runtime` also requests shutdown.
configview does not reload settings or restart itself. Configure tiusnanny
to restart after a normal exit if settings changes should restart the service.

## Navigation

The start page lists all configured formats. A format page lists its named
configurations. A configuration page shows its roots, the latest modification
time of the declared current files, the latest report status, a link to the
current configuration, and all archived versions.

The current row describes the files currently present in `path`. It is not
assigned an archive version merely because an importer normally activates its
latest result.

The archive list contains every non-dot direct child directory, newest first.
Invalid or incomplete entries remain visible with a diagnostic. Select an ID
to inspect the archived configuration.

The title bar links each navigation level: `configview > usermgr > test`.
Current configuration is at `/usermgr/test/current`; archived configurations
are at `/usermgr/test/<version-id>`, without a `versions` URL segment.
Reports are at `/usermgr/test/reports` and
`/usermgr/test/reports/<report-id>`.

The current page has a headerless file table below its heading. Each row
contains a plain filename and modification time, with encoding, line endings,
and an optional BOM marker in parentheses. Archived pages instead expose
an optional `file timestamps` table when file-level metadata exists.
Filenames in that table link to their interpreted sections.

The current page's menu links to `latest report` when available. This does
not establish that the report describes the current bytes. An archived page
links to the newest report referencing that version as `related report`.
The report page offers `related version` when its referenced archive is
available. Filenames are not menu items.

A report page is headed `report <local timestamp> (<status>)`.
An initial `# Import report` heading in the Markdown body is omitted in the
display. Tables, filenames, and comparison prose remain producer-authored;
configview does not turn plain filenames or timestamps in them into links.
Each report represents one completed import. Status is `ok`, `warning`, or
`error`. A report may reference a new or reused version; an error may have no version. The
viewer obtains status and navigation only from the machine-readable header.

All structured timestamps use the timezone of the computer running
configview and the form `yyyy-mm-dd hh:mm:ss`. Stored IDs, report contents,
and link targets are not rewritten.

## usermgr view

The current and version pages show users, groups, and permission bundles.
The user columns are:

| column     | content                    |
| ---------- | -------------------------- |
| name       | stable username            |
| groups     | direct group memberships   |
| disabled   | `disabled`, or empty       |
| created    | marked time, or empty      |
| expires    | local timestamp, or empty  |
| changed    | marked time, or empty      |

An empty `disabled` cell means the configuration does not disable the account.
An empty `expires` cell means no expiry. Empty metadata means unknown.
The overview includes `created` and `changed` columns only when at least one
entry supplies that marker.

Group rows show configured permissions and direct members. Permission bundle
rows show configured and resolved expressions. Group and bundle references
stay within the selected configuration page. The generated group file already
contains flattened Wiki inheritance; configview does not reconstruct it.

Metadata times describe when a producer observed configuration output.
They are not exact Wiki edit, import, publication, or activation times.
Changing a group's rights does not change a user's own marker.

Select a username to see its groups, effective permission expressions,
disabled state, creation time, and expiry. A `changed` row appears when
known. Long group and permission lists wrap in the detail and history tables.

## Effective history

The user detail page compares that username across readable archived
configurations and lists observed additions, removals, and changes, newest
first. It includes indirect permission changes through groups and bundles.
Changes in disabled state, expiry, or section timestamps also create rows.
Adjacent equal states are collapsed.

Rows link to the corresponding archived user, or to the configuration for
a removal. The `disabled` column contains `disabled` or remains empty.
The history covers the archive even when viewing an older version. It does
not add an unarchived current state. Unreadable versions are skipped, so gaps
cannot establish that no change occurred.

Effective permissions are configured expressions, not proof of actual
access. Wildcards are not expanded against a resource inventory, and
disabled or expired users still show their configured expressions.

## Diagnostics and security

Missing files, invalid IDs, malformed reports, unsupported formats, INI
errors, and metadata errors are shown explicitly. Unknown formats are not
interpreted. Dot-prefixed archive and report entries are ignored.

Reports are passive Markdown. Raw HTML and images are disabled. Local and
relative file links are inactive. No raw configuration download is offered.

configview reads only declared files inside configured roots. It excludes
passwords, personal settings, unknown fields, and arbitrary local files from
browser responses. It never modifies current configurations, versions, or
reports.
