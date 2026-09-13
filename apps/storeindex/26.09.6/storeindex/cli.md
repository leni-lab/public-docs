[back to overview](overview.md)
---

# Command line

```text
storeindex [--config <path>] [--watch]
storeindex [--config <path>] rebuild [--since <date>]
storeindex [--config <path>] search <query> [options]
```

| option or command | meaning |
| --- | --- |
| no command | one incremental pass over loose messages |
| `--watch` | repeat incremental passes until interrupted |
| `--config` | INI path, defaults to `storeindex.ini`; place before a command |
| `--version` | print the installed version |
| `--help` | print usage |
| `rebuild` | replace the complete index using loose messages and ZIPs |
| `rebuild --since` | replace messages from the specified date, inclusive |
| `search` | search indexed titles and print a JSON array |

## Rebuild

Dates use `YYYY-MM-DD`. The selected range begins at midnight in the local system
timezone and is based on the message timestamp, not the import time.

```text
storeindex rebuild --since 2026-09-01
```

Older index entries remain unchanged. Rebuild waits neither for an active
storepack run nor indefinitely for a busy database. Retry later if the
required access is unavailable.

A completed rebuild with individual read or extraction errors replaces the
selected range and reports an incomplete result. An interrupted rebuild or
a fatal database or store-access failure preserves the previous index.

The incremental indexer may keep running during a rebuild. It retries deferred
work afterward. Storepack cannot run while a rebuild holds access to the store.

## Search

```text
storeindex search "Kirchen AND Reform*" --source leni
storeindex search "Kirchen" --since 2026-09-01 --limit 100
```

| search option | meaning |
| --- | --- |
| `--source` | restrict results to one source |
| `--since` | include messages from local midnight on the given date |
| `--limit` | maximum results, default `50`, allowed range `1` to `10000` |

Queries use FTS5 syntax, including phrases, prefixes, `AND`, and `OR`. Results
are ordered by relevance, then by descending message timestamp. Search is
token-based; it does not provide fuzzy matching or automatic German stemming.

## Exit codes

| exit code | meaning |
| --- | --- |
| `0` | successful completion |
| `1` | failure, incomplete rebuild, or deferred work in a single pass |
| `2` | command-line usage failure |

Operational summaries and diagnostics go to standard error. Search results
go to standard output. In watch mode, individual message errors are reported
and retried on later passes.
