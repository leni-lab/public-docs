[back to overview](overview.md)
---

# Troubleshooting

## Store is already locked

Storepack or a maintenance command currently holds the store. The incremental
indexer defers work. Retry maintenance after the other operation finishes. The
lock file normally remains present between runs. Do not delete it.

Storepack may also report a lock error if it starts during an incremental
extraction or quarantine. Its next scheduled run can retry.

## Database is busy

Stop watch before maintenance. Only one Storeindex CLI process can use a given
database at a time, enforced by `<database>.lock`. The lock file may remain on
disk and must not be deleted. Other SQLite writers can also cause contention.
Incremental processing retries SQLite contention on its next pass.

## Extractor cannot start or times out

Check the source's `command`, executable path, and permissions. Test the
extractor directly against the affected news item. Adjust `index.timeout` only
if normal extraction requires more time.

## A headline is missing

A null headline can be a successful extraction of a news item without a headline.
Check standard-error diagnostics for extraction failures. Rejected loose inputs
are moved to `failed`. Timeouts are retried.

## News items are missing after an outage

Incremental passes inspect only loose news items. Files packed before successful
indexing require `fill` covering their dates:

```text
storeindex fill --since 2026-09-01
```

The same applies when a timeout persists until a news item is packed.

## Maintenance failed

Already saved items remain. Rejected documents, data constraint violations, and
file or ZIP errors are reported while processing continues. Operational errors
stop the run. Correct the reported cause and retry with `fill --all`, or with
`fill --since` and the original cutoff. No loose files or ZIP entries are moved
during maintenance.

`rebuild` deletes the entire old database, even with `--since`. `replace`
deletes only selected index entries, keeping the schema and unrelated tables.
Neither restores removed data on failure. Use a manual backup if you need the
previous state. Resume with `fill --all` or `fill --since` to retain saved
progress.

## Files in failed

The log contains the rejection reason and destination. Fix the document,
extractor, or data rules, then move the file back to the store root while store
tools are stopped. Its original name is retained for this purpose. A collision
in `failed` stops processing without overwriting either file. Inspect both
copies and resolve the collision manually before restarting.

## Maintenance was interrupted

The database contains the results saved before interruption. The remaining
selected items are missing until processed again. Run `fill --all`, or
`fill --since` with the same date if the interrupted run used a cutoff. Existing
entries are skipped before reading content or calling the extractor. Keep the
same schema and extractor configuration while resuming. Allow enough local disk
space and avoid overlapping maintenance with scheduled storepack runs.
