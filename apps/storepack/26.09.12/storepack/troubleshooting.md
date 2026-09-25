[back to overview](overview.md)
---

# Troubleshooting

Start by checking the configured store path, filename filter, local timezone,
and day eligibility. Run `--dry-run --verbose` and inspect the reported day
and filename. See [command line](cli.md) for exit codes.

## No files selected

The age applies after the end of the whole day. A file being 48 hours old is
not sufficient by itself. Modification and arrival times do not count.
Only direct files matching the case-sensitive filter are considered.

Use `--verbose` to show the resolved store path, filename filter, and exclusive
local date boundary. For a run on September 13, 2026 with `min_age=48h`:

```text
store: path "D:\store", files matching "*" before 2026-09-11
store: 0 matching files, 0 done, 0 failed
```

`before 2026-09-11` includes only days through September 10. The summary's
`matching files` applies both the filename filter and this age boundary.
Zero matching files does not mean the store is empty.

Use `-vv` for trace diagnostics: direct entries, filter exclusions, matching
directories, files that are too young, and ignored unsupported files.
The internal lock file is excluded from these counts. Trace also shows the
earliest eligibility time among files that are still too young, in the local
timezone with its UTC offset.

For example, `1789203039_001.leni.json` belongs to September 12, 2026 in
Europe/Berlin. With `min_age=48h`, it becomes eligible on September 15 at
00:00 local time. Before then, this file does not count as a matching file.

`Using proactor: IocpProactor` is a normal Windows asyncio debug message.
It does not describe the store path or file selection.
To hide asyncio debug messages while retaining its warnings and errors, add
this setting to the INI file. Storepack debug messages remain available.

```ini
[logging]
/asyncio = warning
```

The example configuration already contains this setting.

## Another process holds the store

Storepack shares `.storepack.lock` with Storeindex and cooperating recovery
tools under the [newsstore contract](https://github.com/leni-lab/newsstore/blob/main/docs/store-contract.md).
Avoid overlapping scheduler starts and wait for the current holder before
retrying. The operating system releases ownership if a process dies. The
file's existence alone does not indicate ownership. Do not delete or replace it.

## Different content already in ZIP

The same name refers to different content in the ZIP and store. Both versions
are kept. Compare them and resolve the naming conflict before running again.
No entries for the affected day are replaced during this failed attempt.

## Corrupt ZIP or unexpected entry

The existing ZIP remains unchanged and the day's sources remain in the store.
Restore or repair the ZIP separately before retrying. Duplicate ZIP entry
names, entries from another day, encrypted entries, and directory entries
are rejected.

## File changed or cannot be opened

Producers must publish complete immutable files. A changed or inaccessible
file causes its day to fail without waiting. Fix the producer or access
problem and run again, or let the scheduler start the next attempt.

## Interrupted run or full disk

Replacement creation needs room for both the existing ZIP and its complete
replacement. Originals remain until the published ZIP has been verified.
A cleanup failure can leave some originals alongside that ZIP. Running again
recognizes their identical content and completes removal.

A forcibly terminated process may leave `.storepack-*.tmp` files inside a
monthly directory. After stopping all writers, these temporary files may be
removed. storepack never reads them as published ZIPs.

Verification detects corrupt data during packing. It is not a backup against
later disk failure. Power-loss guarantees depend on the filesystem and
storage hardware, including support for flushes and atomic replacement.
