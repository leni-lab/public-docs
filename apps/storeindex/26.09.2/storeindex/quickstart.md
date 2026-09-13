[back to overview](overview.md)
---

# Quickstart

Run the installed `storeindex` command or use the full path to its executable.
For LENI messages, also install `leniextract`.

1. Copy the [example configuration](storeindex.example.ini) to
   `storeindex.ini` in your working directory.
2. Set the store path, a local database path outside the store, and the
   extractor command.
3. Set the timezone to the timezone used by storepack.
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
