[back to overview](overview.md)
---

# Settings and operation

## Installation

newsview requires an existing newsindex database and read access to it.
The database must contain store timestamps, services, channels, keywords, locations,
the source document fields `src_id` and `src_rev`, `headline`, `timestamp`,
and the headline search index. Deploy with the matching Newsindex schema and
populate the index before starting Newsview. Store time comes from
`item.timestamp`. Source time fields remain separate content.
newsview does not create or upgrade databases.

When using a supplied Windows release, extract it and copy the
[example configuration](newsview.example.ini) to `newsview.ini`.
Set `[index] database` to your database, then start:

```powershell
.\newsview.exe --config .\newsview.ini
```

In an installed Python environment, use:

```powershell
python -m newsview --config newsview.ini
```

Open <http://127.0.0.1:8080> on the server. For access from another machine,
configure the listening address and use that machine's reachable address.

The default listener is local. newsview has no built-in authentication.
Use an access-controlled deployment when sharing news over a network.

## Application settings

The configuration is an INI file. Relative database paths are resolved against
the directory containing that file.

```ini
[index]
database = D:/data/newsindex.db

[server]
bind = 127.0.0.1
port = 8080
auto_refresh = 10s
source_link = https://leni.epd.de/detail/doc{src_id}/{src_rev}
```

| section  | setting        | default     | meaning                                     |
| -------- | -------------- | ----------- | ------------------------------------------- |
| index    | `database`     | required    | existing newsindex database                |
| server   | `bind`         | `127.0.0.1` | local addresses to listen on                |
| server   | `port`         | `8080`      | listening port from 1 through 65535         |
| server   | `auto_refresh` | `0s`        | refresh interval, `0s` disables it          |
| server   | `source_link`  | empty       | document URL template, empty disables links |
| app      | `max_runtime`  | unlimited   | optional runtime limit, such as `8h`        |

`bind` accepts comma-separated numeric IPv4 or IPv6 addresses, without ports
or IPv6 brackets. All addresses use `port`. Examples:

- `127.0.0.1`: IPv4 loopback only (default)
- `loopback`: IPv4 and IPv6 loopback
- `192.168.10.20, ::1`: selected local addresses
- `0.0.0.0`: all IPv4 addresses
- `::`: all IPv6 addresses
- `all`: all IPv4 and IPv6 addresses

`loopback` and `all` must appear alone. Hostnames and empty entries are not
accepted. A wildcard cannot overlap an explicit address of the same family.
Every requested listener must start successfully, including both families for
`loopback` and `all`. Without `bind`, the default
is `127.0.0.1`.

`source_link` adds a document icon at the right of each row, below the clear-all
button. `{src_id}` and `{src_rev}` are replaced with that row's source document
ID and revision. Use an absolute HTTP or HTTPS URL and plain placeholders
without `$` or format modifiers. Unknown placeholders prevent startup.
Source links reuse their own tab, separate from the stored-item detail tab.
Omit the setting or leave it empty to hide the icons.

The former setting name `detail_link` is no longer consumed. Rename it to
`source_link` to retain the external source link.

## Stored item details

Install Newsrender in its own Python environment. For neighboring
project directories, start the renderer through that environment:

```ini
[news]
path = D:/store

[renderer]
command = ../newsrender/.venv/Scripts/python.exe -m newsrender --processor --config newsrender.ini
cwd = ../newsrender
request_timeout = 30s
```

No Newsrender EXE build is required. The selected Python environment must have
Newsrender and its dependencies installed.

The store root and renderer working directory must already exist. Relative
executable paths containing a slash and `cwd` resolve against the Newsview
INI directory. Bare executable names use PATH.
Arguments are passed without a shell, with double quotes for paths containing
spaces. `--config newsrender.ini` is interpreted in the selected renderer working
directory. Commands are passed unchanged. For Newsrender, `--processor`
selects a persistent Toolkit MessagePack session. Newsview starts Newsrender
on first use and reuses it for subsequent detail requests. Those requests are
serialized through one renderer. Adding `--once` retains one-call behavior
and its repeated startup cost. Both applications require Toolkit processor
0.4. Update Newsview and Newsrender together for configuration monitoring.
Newsrender watches its INI and includes, finishes an active request, and then
closes its processor chain. Idle changes are detected within about two seconds.
The next detail call starts a fresh instance before submitting the document.
Restart Newsview after replacing processor executables.

Set `[renderer] prepare = yes` to start and check Newsrender during server startup,
without rendering a document. The default is `no`. Preparation checks Newsrender's
initialization, not every configured extractor or converter. A failed check is
logged while the search list stays available. Later calls may attempt a new
start. Source extractors and converters start when their views are first used.

Toolkit settings `startup_timeout`, `request_timeout`, and `shutdown_timeout`
default to `10s`, `60s`, and `5s`. The example limits requests to `30s`. Positive
durations accept `ms`, `s`, `min`, and `h`. The request budget includes watched admission, any replacement before input,
and extractor and converter work within Newsrender. Waiting for an earlier detail
request has no separate timeout. Optional `input_limit`, `output_limit`,
`report_limit`, `message_limit`, and `stderr_limit` use Toolkit byte limits.
Each stored item is limited to 32 MiB before MessagePack encoding.

Migration from Toolkit 0.2 requires updating both Newsview and Newsrender and
reinstalling their environments. Rename the old `timeout` to `request_timeout`
and add `--processor` to the Newsrender command. The old setting is rejected
with a migration hint; Newsview no longer adds transport arguments.

Omitting or clearing `[renderer] command` disables detail links. With a
renderer configured, a separate icon opens the stored item in a dedicated
detail tab. Subsequent selections reuse that tab, leaving the list open.
Direct `/view/<store-name>` URLs work without visiting the list. Newsview
reads loose files and daily ZIPs without parsing their content. Identity,
extension, and original bytes are supplied per request. Newsrender currently
supports UTF-8 JSON, with an optional UTF-8 BOM.

The process account needs read access to the store and permission to create
and delete its `.news.lock` coordination file. Use the same system
timezone as the other store programs. A busy lock reports a retryable error,
and conflicting loose/ZIP copies are reported instead of choosing one.
The lock is released before rendering. Renderer errors leave search usable,
and shutdown terminates active renderer processes.

Times are displayed and entered in the server's local time. There is no
separate timezone setting in the browser.

## Logging

The example configures console and redirected output separately:

```ini
[logging console]
log_level = INFO
color_mode = auto

[logging pipe]
log_level = INFO
```

Use `--help` to list command-line options. Startup and query errors are logged.
A missing database or invalid setting prevents startup.

## Updates and shutdown

Normal newsindex updates may continue while newsview is running. Enable
`[server] auto_refresh = 10s` to update results automatically. Durations use
`ms`, `s`, `min`, or `h`; the default `0s` disables refresh. Refresh runs only
while the tab is visible, its window has focus, and all filters are empty.
Draft inputs and the timestamp filter also pause refresh. Returning to the window
resumes refresh immediately if the interval has elapsed. Results and navigation
update without reloading the page or resetting the scroll position. Failed
requests keep the displayed results and retry after the interval.

Manual browser reloads also show new items. Stop newsview before a rebuild, then
start it again when the database is ready.

Service and channel choices are read at startup. Keyword suggestions use
frequencies from startup and include only values occurring more often than
the median, calculated separately for keywords and locations. Restart newsview to refresh these choices. Free keyword input
continues to search the current database.

Ctrl+C stops the server. A configuration change also stops it so a supervisor
can restart it with the new settings. Without a supervisor, restart manually.
An optional `[app] max_runtime` stops the server after the configured duration.

## Troubleshooting

| symptom                         | action                                                |
| ------------------------------- | ----------------------------------------------------- |
| database not found              | check `[index] database` and file access              |
| port already in use             | stop the other listener or choose another port        |
| invalid timestamp            | use local `YYYY-MM-DD HH:MM:SS`, without a timezone   |
| invalid keyword or title filter | correct the expression using the field's help         |
| no matching items               | clear filters or return to Latest                     |
| suggestions appear outdated     | restart newsview to refresh the choices              |
| index unavailable or timed out  | retry, narrow the filters, and check the server log   |
