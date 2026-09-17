[back to overview](overview.md)
---

# Settings and operation

## Installation

storeview requires an existing storeindex database and read access to it.
The database must contain transmission times, services, channels, keywords,
and the title search index. storeview does not create or upgrade databases.

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
host = 127.0.0.1
port = 8080
```

| section  | setting       | default     | meaning                                  |
| -------- | ------------- | ----------- | ---------------------------------------- |
| index    | `database`    | required    | existing storeindex database             |
| server   | `host`        | `127.0.0.1` | IP address or `localhost` to listen on   |
| server   | `port`        | `8080`      | listening port from 1 through 65535      |
| app      | `max_runtime` | unlimited   | optional runtime limit, such as `8h`     |

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

Normal storeindex updates may continue while storeview is running. Reload the
browser to see new items. Stop storeview before a storeindex rebuild, then
start it again when the database is ready.

Service and channel choices are read at startup. Keyword suggestions use
frequencies from startup and include only keywords occurring more often than
the median. Restart storeview to refresh these choices. Free keyword input
continues to search the current database.

Ctrl+C stops the server. A configuration change also stops it so a supervisor
can restart it with the new settings. Without a supervisor, restart manually.
An optional `[app] max_runtime` stops the server after the configured duration.

## Troubleshooting

| symptom                         | action                                                |
| ------------------------------- | ----------------------------------------------------- |
| database not found              | check `[index] database` and file access              |
| port already in use             | stop the other listener or choose another port        |
| invalid transmission            | use local `YYYY-MM-DD HH:MM:SS`, without a timezone   |
| invalid keyword or title filter | correct the expression using the field's help         |
| no matching items               | clear filters or return to Latest                     |
| suggestions appear outdated     | restart storeview to refresh the choices              |
| index unavailable or timed out  | retry, narrow the filters, and check the server log   |
