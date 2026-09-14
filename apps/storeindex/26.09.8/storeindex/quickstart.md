[back to overview](overview.md)
---

# Quickstart

Run the installed `storeindex` command or use the full path to its executable.
For LENI messages, also install `leniextract`.

1. Copy the [example configuration](storeindex.example.ini) to
   `storeindex.ini` in your working directory.
2. Set the store path, a local database path outside the store, and the
   extractor command.
3. Ensure this system uses the same timezone as the system running storepack.
4. Run one incremental pass:

```text
storeindex
```

To keep checking for new messages:

```text
storeindex --watch
```

Use Ctrl+C to stop. For an existing store containing ZIPs, initialize the
complete index with a manual rebuild:

```text
storeindex rebuild
```

Search the indexed titles:

```text
storeindex search "Kirchen"
```

The search prints a JSON array containing the source, timestamp, suffix, and
title of each match. See [settings](settings.md) for paths and extractor
configuration, and [command line](cli.md) for filtering and exit codes.

## Windows executable

If you received `storeindex.zip`, extract it to a local application folder.
Python is not required. Open PowerShell in that folder and run:

```powershell
./storeindex.exe --help
./storeindex.exe --version
```

If the archive includes an `_internal` folder, keep it beside the EXE.
This folder variant avoids unpacking the program at every start.

The archive includes `storeindex.example.ini`. Copy it to `storeindex.ini`
and set the store path. Install leniextract separately and configure its
executable, for example:

```ini
[source leni]
command = ["D:/tools/leniextract/leniextract.exe"]
revision = 1
```

An executable path with `./` is resolved relative to the INI file.
Start a scan with `./storeindex.exe --config ./storeindex.ini`.
Keep separate application folders for the folder variants of both programs.
