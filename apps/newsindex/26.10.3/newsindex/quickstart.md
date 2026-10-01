[back to overview](overview.md)
---

# Quickstart

Run the installed `newsindex` command or use the full path to its executable.
For LENI news items, also install `leniextract`.

When deploying a changed schema, update Newsview and the processor together
with Newsindex and run `newsindex rebuild` before starting the reader.

1. Copy the [example configuration](newsindex.example.ini) to
	`newsindex.ini` in your working directory, together with
	[newsindex.sql](newsindex.sql).
2. Set the store path, a local database path outside the store, and the
	extractor command.
3. Ensure this system uses the same timezone as the system running newspack.
4. Run one incremental pass:

```text
newsindex fill
```

To keep checking for arriving news items:

```text
newsindex fill --watch
```

Use Ctrl+C to stop. For an existing store containing ZIPs, fill missing index
entries with `fill --all`. Stop watch first. Existing entries are retained, and
an interrupted run can be resumed with the same command:

```text
newsindex fill --all
```

The resulting SQLite database is available to separate search consumers. See
[settings](settings.md) for paths and extractor configuration, and
[command line](cli.md) for maintenance commands and exit codes.

## Windows executable

If you received `newsindex.zip`, extract it to a local application folder.
Python is not required. Open PowerShell in that folder and run:

```powershell
./newsindex.exe --help
./newsindex.exe --version
```

If the archive includes a `newsindex_lib` folder, keep it beside the EXE. This
folder variant avoids unpacking the program at every start.

The archive includes `newsindex.sql` and `newsindex.example.ini`. Keep the SQL
beside the INI. Copy the example to `newsindex.ini` and set the store path.
Install leniextract separately and configure its executable, for example:

```ini
[source leni]
command = D:/tools/leniextract/leniextract.exe --field headline_raw,src_id,src_rev,keywords_raw,service,channels,locations

[fields]
headline = headline_raw
keyword = keywords_raw
channel = channels
location = locations
```

An executable path with `./` is resolved relative to the INI file. Start a scan
with `./newsindex.exe --config ./newsindex.ini`. Keep separate application
folders for the folder variants of both programs.
