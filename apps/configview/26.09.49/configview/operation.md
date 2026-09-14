[back to overview](overview.md)
---

# Operation

## Settings

Start from [configview.example.ini](configview.example.ini) and follow the
[settings reference](settings.md) for configurations, renderers, Git, the
server, and general runtime and logging options.

## Navigation

The start page lists apps in compact rows with titles and descriptions side by
side. Narrow screens place descriptions below the titles. Long descriptions
are shortened on the start page; their full text remains on the app detail page.

Each named `[appinfo <name>]` section defines an area, using its `title` or name.
Areas follow settings order and start open. Select an area heading to collapse
or expand it; its app count remains visible. Apps without `group` appear first
within each area, followed by group headings in alphabetical order, ignoring
case. Groups combine apps from manifests and profiles within the same area.
Selecting an app opens its
versions list with Current first and archived versions below. No separate group
or profile page is needed. The title bar links directly back to the start page:
`configview > User management`.

The optional `title` replaces the app name in visible labels. Profiles select
renderers but do not appear in the navigation or page titles. Discovered app
URLs use `/app/<name>-<suffix>`. The suffix comes from the full manifest path
and section name and stays unchanged when other apps are added or removed.
Same-named apps have distinct links and show their manifest paths on the start
page. Old profile/name URLs redirect when unambiguous. Ambiguous old links ask
the user to select an app on the start page. Former profile overview URLs
redirect home. Direct configurations retain their existing URLs.

The app detail page shows the full `appinfo.ini` path as a single collapsed
control. Expanding it shows the source loaded at startup with
syntax highlighting and line numbers. The app's section is emphasized. The
source remains unchanged until settings are loaded again, even if the manifest
is edited or removed. It contains the configured file paths, so the detail page
does not add separate file-root or Git-root metadata rows.

For example, current configuration is at `/app/usermgr-a82f194c013b/current`.
Historical configurations append `/<commit-id>` to the same app URL. Links use
the full commit ID. Visible
version labels use commit timestamps in the server's local timezone, as
`yyyy-mm-dd hh:mm:ss`. Commit IDs are not displayed as labels.

Current pages always read the declared files directly from their selected root.
For appinfo filenames this is their common containing directory, regardless of
relative or absolute spelling. Direct configurations use their configured
`path`. Git history finds the nearest repository for each file, including
parent directories, and requires one shared repository. Current pages do not
substitute an archived version or assume the latest
commit matches live bytes.
The file summary shows modification time, encoding, line endings, and any BOM.
Select a filename to open its INI viewer, for example
`/usermgr/test/current/files/users.wiki.ini`. The viewer shows the original
file text and metadata with a dark editor theme, syntax highlighting, and line
numbers. Comments, blank lines, indentation, and all values are retained. The
timestamp is the filesystem modification time in the server's timezone. Missing
or invalid files produce a diagnostic instead of a partial view.

Source views and comparisons accept assignment continuations and brace-delimited
block values, such as a tiusnanny `licence` block. Block contents remain literal
text. Includes are not loaded, and expressions are not evaluated. Unfinished
blocks and other malformed input still produce a diagnostic.

Archived configuration pages also list filenames with links to INI viewers, for
example `/usermgr/test/<commit-id>/files/users.wiki.ini`. Each viewer reads the
original file from that exact commit, even when current files change. Its
timestamp is the commit time because Git does not store filesystem modification
times. Encoding and line endings describe the archived bytes.

## Compare versions

Select two checkboxes in the versions list, then choose `compare selected`.
Current is always the top row. Once two rows are selected, other checkboxes are
disabled until one selection is cleared. Unavailable versions cannot be
selected.

The older archived version starts on the left, with the newer version or Current
on the right. Archive ordering follows Git history, even when timestamps are
equal or out of order. Below the `compare config` heading, each version appears
below the horizontal rule and above its column. Its label links to that
version's configuration page. Current is labeled `current (<timestamp>)`. The
heading, versions, and change navigation stay visible while scrolling. To select
another pair, return to the versions list using the configuration breadcrumb.
Current is marked with a blue edge in that list.

The comparison shows the original text of all declared files, one below the
other. Each file has a separator and its own line numbers on both sides. Removed
lines are red on the left and added lines are green on the right. Empty
alignment cells keep corresponding lines at the same height. Long lines wrap
within their side.

`hide unchanged` keeps three context lines around each change. Use `show` to
expand one hidden region. A fully unchanged file collapses to its separator.
Clearing `hide unchanged` reveals all original lines. `previous` and `next`
navigate changes across all files. The filename links jump directly to a file,
and the active change has a blue outline.

Encoding, line endings, and the final newline are compared separately from text.
A CRLF-to-LF conversion does not mark every text line as changed. Comments,
indentation, and spaces remain part of the text comparison.

Current is read once for each displayed comparison. Folding and navigation do
not reread files. Reload the page in the browser to read a new Current snapshot.
Opening a new comparison also performs a fresh read. Comparisons between two
archive IDs are reproducible. A URL containing `current` uses the current files
when opened.

Comparison URLs use `left` and `right` query parameters on
`/usermgr/test/compare`, each containing a full commit ID or `current`. A
change can be linked directly using its `#change-<number>` fragment. Comparison
is limited to 40000 combined source lines per file.

## Git history

History comes from branch `main` in the files' repository, following first
parents. Only commits affecting the selected configuration's files are listed, newest in
ancestry first. The page reports `git: repository not found` when no repository
exists, and `git: no versions for these files` when the repository has no
matching commits. Separate repositories require separate app entries.
Disabled Git history does not invoke Git. A Git failure appears in the history
area while current configuration remains available.

The configured limit bounds the versions list. The page states when older
commits were omitted. Increase the limit when more history is needed.

A historical configuration must contain all files declared by its configuration.
Missing or oversized files are marked in the list. Invalid INI data and
nonregular Git entries are reported when opening a version. There is no fallback
to another commit or to current files. Unrelated files in a commit are ignored.
Commit timestamps describe Git history, not activation times.

Reads use immutable Git objects, without checkout, index refresh, locks,
initialization, commits, or network synchronization. Changes to the working
files do not change historical views. Report contents and arbitrary raw files
have no display or download route.

## usermgr view

The separately installed configview-usermgr renderer shows compact users,
groups, and permission bundles. Expand users to inspect their groups and
effective permissions, or search the selected configuration in the browser.
Disabled names are struck through. Opening an entry closes its siblings. Search
can display several matches together.

See the renderer's
[user guide](https://github.com/leni-lab/configview-usermgr/blob/main/user-docs/overview.md)
for interaction, timestamp interpretation, and the limits of effective
permissions. configview supplies version navigation and original-file
comparison. There is no separate user detail route or effective history.

## Logging

After loading settings, startup logs one line per app with its name, display
title, profile, and selected file directory, followed by the app count. The list includes
discovered apps and directly configured entries. These are `INFO` messages and
follow the configured handler levels and `--quiet` option.

See [logging settings](settings.md#logging) for console, redirected, and file
output, verbosity levels, and examples.

## Shutdown and restart

Settings and included INI files are checked every two seconds. Changes or
removal stop the server with exit code 0 so tiusnanny can restart it. Changes to
reviewed configuration or Git history do not stop the server.

Ctrl+C, SIGTERM, and Windows Ctrl+Break request shutdown with exit code 128 plus
the signal number. The single-file EXE also exits its application child if a
supervisor terminates the EXE parent. There is no `--watch` flag.
`[app] max_runtime` can request shutdown. configview does not restart itself.

## Diagnostics and access

The server binds locally by default and has no built-in authentication. Shared
access requires an access-controlled deployment. Each renderer controls which
fields its interpreted view exposes. configview trusts its HTML output. The INI
viewer shows the complete original contents of declared current or archived
files, including passwords, personal settings, or unknown fields when present in
those files. Arbitrary files have no display or download route.

Git errors, incomplete snapshots, renderer failures, and invalid values are
shown explicitly. Current file access rejects links and paths outside the
configured root. Git history requires a local `.git` directory and regular file
entries. configview never modifies the reviewed data.
