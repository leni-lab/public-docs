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

## Another process holds the store

One writer holds `.storepack.lock` for its complete run. Avoid overlapping
scheduler starts, or wait until the active writer finishes before retrying.
The lock file remains after shutdown
and is harmless. The operating system releases the lock if a process dies.
Do not delete the lock file while a writer may be running.

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
