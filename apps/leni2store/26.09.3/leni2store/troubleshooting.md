[back to overview](overview.md)
---

# Troubleshooting

## Diagnostic order

1. Check the startup message, selected configuration, and account permissions.
2. Check the destination and the source processing directories.
3. Run with `--verbose` to see completed and skipped processing decisions.
4. Use `-vv` when diagnosing file readiness or repeated failures.

## Source cannot be found

Confirm that the configured source exists for the account running the program.
A service or scheduled task may not see a mapped drive. Prefer a UNC path.
The importer does not create a missing input directory.

## A file stays in the source

Check the filename filter, file size and modification activity, and open
handles. A locked or changing file is deferred. Subdirectories are not
searched. Other files continue to be eligible for processing.

## Destination file did not change

Existing final filenames are intentionally skipped. Different content under
an existing name indicates a naming collision or manual reuse. Preserve both
copies and resolve the naming issue before resubmitting the source under a
new unique name. Check the [LENI2020 contract](leni2020.md).

## Retry, fail, or review contains files

`retry` contains temporary failures and recovered interrupted work. Fix network,
permission, or capacity problems and allow another attempt.

`fail` contains permanent failures or files that exhausted their retries.
`review` contains unexpected failures. Inspect the log, correct the cause,
and stop the importer before manually returning a file to the input directory
under its original name. Do not overwrite another file while doing so.

A directory or another nonregular entry at the destination filename is a
conflict, not a completed import. A successful copy followed by an archive
failure may leave the source in another processing directory. On resubmission,
the existing destination is skipped.

## Temporary files remain in the destination

A forced stop can leave `.leni2store-*.tmp` files, or files with the configured
temporary suffix. They are never treated as completed imports. After stopping
the importer and confirming no copy is active, remove only those abandoned
temporary files. A later retry uses a fresh temporary name.

## Shutdown takes longer than the runtime limit

The runtime limit requests shutdown. An active filesystem copy must finish or
fail before the source can be moved safely. An SMB outage can delay that
completion until Windows returns an error.

## Unexpected archive cleanup

`done_max_age` uses source modification time. Old exports or an offset source
clock can make files eligible immediately. Disable cleanup with `0s` when this
does not match the desired retention policy.
