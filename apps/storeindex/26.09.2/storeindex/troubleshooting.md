[back to overview](overview.md)
---

# Troubleshooting

## Store is already locked

Storepack or a rebuild currently holds the store. The incremental indexer
defers work. Retry a manual rebuild after the other operation finishes.
The lock file normally remains present between runs; do not delete it.

Storepack may also report a lock error if it starts during an incremental
read. Its next scheduled run can retry.

## Database is busy

Another writer may be rebuilding the index. The incremental indexer retries
on its next pass. Retry a manual command later if it cannot acquire access.

## Extractor cannot start or times out

Check the source's `command`, executable path, and permissions. Test the
extractor directly against the affected message. Adjust `index.timeout` only
if normal extraction requires more time.

## A title is missing

A null title can be a successful extraction of a message without a headline.
Check standard-error diagnostics for extraction failures. Loose failures are
retried on later passes.

## Messages are missing after an outage

Incremental passes inspect only loose messages. Files packed before successful
indexing require a manual rebuild covering their dates:

```text
storeindex rebuild --since 2026-09-01
```

The same applies when an extraction error persists until a message is packed.

## Rebuild reports an incomplete index

Individual read, ZIP integrity, filename, or extraction errors do not stop the
remaining work. A completed scan commits the readable results and reports
the failures. Correct the affected source data or extractor, then rebuild
the affected date range again.

Conflicting contents under the same message identity are reported and have no
searchable title. A missing search result after an incomplete rebuild does
not establish that the message never existed.

## Rebuild was interrupted

The selected index range remains as it was before the rebuild. Run the command
again when the cause has been resolved. Allow enough local disk space for a
large rebuild and avoid overlapping it with scheduled storepack runs.
