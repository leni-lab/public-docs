[back to overview](overview.md)
---

# Settings and operation

## Installation

storeview requires an existing storeindex database and read access to it.
The database must contain publication times, services, channels, keywords, locations,
the source document fields `src_id` and `src_rev`, `headline`, `published_at`,
and the headline search index. Deploy with the matching Storeindex schema and
rebuild the index before starting Storeview.
storeview does not create or upgrade databases.

When using a supplied Windows release, extract it and copy the
[example configuration](storeview.example.ini) to `storeview.ini`.
Set `[index] database` to your database, then start:

```powershell
.\storeview.exe --config .\storeview.ini
```

In an installed Python environment, use:

```powershell
python -m storeview --config storeview.ini
```

Open <http://127.0.0.1:8080> on the server. For access from another machine,
configure the listening address and use that machine's reachable address.

The default listener is local. storeview has no built-in authentication.
Use an access-controlled deployment when sharing news over a network.

## Application settings

The configuration is an INI file. Relative database paths are resolved against
the directory containing that file.

```ini
[index]
database = D:/data/storeindex.db

[server]
bind = 127.0.0.1
port = 8080
auto_refresh = 10s
detail_link = https://leni.epd.de/detail/doc{src_id}/{src_rev}
```

| section  | setting        | default     | meaning                                     |
| -------- | -------------- | ----------- | ------------------------------------------- |
| index    | `database`     | required    | existing storeindex database                |
| server   | `bind`         | `127.0.0.1` | local addresses to listen on                |
| server   | `port`         | `8080`      | listening port from 1 through 65535         |
| server   | `auto_refresh` | `0s`        | refresh interval, `0s` disables it          |
| server   | `detail_link`  | empty       | document URL template, empty disables links |
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

`detail_link` adds a document icon at the right of each row, below the clear-all
button. `{src_id}` and `{src_rev}` are replaced with that row's source document
ID and revision. Use an absolute HTTP or HTTPS URL and plain placeholders
without `$` or format modifiers. Unknown placeholders prevent startup.
Omit the setting or leave it empty to hide the icons.

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

Normal storeindex updates may continue while storeview is running. Enable
`[server] auto_refresh = 10s` to update results automatically. Durations use
`ms`, `s`, `min`, or `h`; the default `0s` disables refresh. Refresh runs only
while the tab is visible, its window has focus, and all filters are empty.
Draft inputs and the published filter also pause refresh. Returning to the window
resumes refresh immediately if the interval has elapsed. Results and navigation
update without reloading the page or resetting the scroll position. Failed
requests keep the displayed results and retry after the interval.

Manual browser reloads also show new items. Stop storeview before a rebuild, then
start it again when the database is ready.

Service and channel choices are read at startup. Keyword suggestions use
frequencies from startup and include only values occurring more often than
the median, calculated separately for keywords and locations. Restart storeview to refresh these choices. Free keyword input
continues to search the current database.

Ctrl+C stops the server. A configuration change also stops it so a supervisor
can restart it with the new settings. Without a supervisor, restart manually.
An optional `[app] max_runtime` stops the server after the configured duration.

## Troubleshooting

| symptom                         | action                                                |
| ------------------------------- | ----------------------------------------------------- |
| database not found              | check `[index] database` and file access              |
| port already in use             | stop the other listener or choose another port        |
| invalid publication            | use local `YYYY-MM-DD HH:MM:SS`, without a timezone   |
| invalid keyword or title filter | correct the expression using the field's help         |
| no matching items               | clear filters or return to Latest                     |
| suggestions appear outdated     | restart storeview to refresh the choices              |
| index unavailable or timed out  | retry, narrow the filters, and check the server log   |
