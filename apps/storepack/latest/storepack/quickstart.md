[back to overview](overview.md)
---

# Quickstart

Run the installed `storepack` command, or `storepack.exe` when using a Windows
executable build. The executable needs no separate Python installation.

1. Place a `storepack.ini` beside the executable, or in the working directory
   when using the installed Python command.
2. Set the path to your existing store:

```ini
[store]
path = D:/data/store
match = *.json
min_age = 48h
```

3. Preview the eligible days without changing the store:

```text
storepack --config storepack.ini --dry-run
```

4. Pack the selected files:

```text
storepack --config storepack.ini
```

Expect a monthly directory containing a ZIP for each eligible day. Its entries
have the original filenames. Originals disappear only after verification.
Recent files remain directly in the store. If no complete day is old enough,
the run succeeds with zero selected files.

For continuous operation, add `--watch`. The default scan interval is five
minutes. See [command line](cli.md) for exit codes and shutdown behavior,
[settings](settings.md) for configuration, and [restore](restore.md) for
unpacking ZIPs.
