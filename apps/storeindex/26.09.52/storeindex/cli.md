[back to overview](overview.md)
---

# Command line

```text
storeindex [--config <path>] fill [--watch]
storeindex [--config <path>] fill --since YYYY-MM-DD
storeindex [--config <path>] fill --all
storeindex [--config <path>] replace [--since YYYY-MM-DD]
storeindex [--config <path>] rebuild [--since YYYY-MM-DD]
```

| option or command               | meaning                                                                  |
| ------------------------------- | ------------------------------------------------------------------------ |
| `-c`, `--config`                | INI path, place before a command                                         |
| `-s`, `--set SECTION:KEY=VALUE` | override a config value, repeatable                                      |
| `-v`, `--verbose`               | increase logging verbosity, repeat for trace output                      |
| `-q`, `--quiet`                 | decrease logging verbosity, repeatable                                   |
| `-V`, `--version`               | print the version and build information                                  |
| `-h`, `--help`                  | print usage                                                              |
| `fill`                          | add missing entries from loose files once                                |
| `fill --watch`                  | repeat loose-file passes until interrupted                               |
| `fill --all`                    | add missing entries from all loose files and ZIPs                        |
| `fill --since YYYY-MM-DD`       | add missing entries from loose files and ZIPs from the date, inclusive   |
| `replace [--since YYYY-MM-DD]`  | delete and reindex selected entries, keeping schema and unrelated tables |
| `rebuild [--since YYYY-MM-DD]`  | recreate the entire database, then index the selected news items         |

A command is required. Without one, Storeindex prints usage and a missing
command error, then exits with code 2 before loading configuration. Use `fill`
for a single pass over loose news items. `--help` and `--version` work without
a command and exit with code 0.

The default config is `storeindex.ini` in the current directory for Python runs.
Packaged executables use an INI beside the executable, named after its
executable stem. Place global options before the command.

## Fill

`fill` processes only loose files, including old news items that arrived late.
Existing index entries remain unchanged. Use `--all` to include every daily ZIP,
or `--since YYYY-MM-DD` to include loose files and ZIPs from a store date.
Use `--watch` for continuous loose-file processing.

`--watch`, `--all`, and `--since` are mutually exclusive. The date starts at
local midnight. ZIPs older than that date are skipped without reading their
contents.

Place `--watch` after `fill`. A commandless invocation is equivalent to a
single `fill` pass.

## Watch

Start continuous processing with `storeindex fill --watch`.

The first pass checks all loose news items against the database. Later passes
check only new filenames and retry deferred news items. Permanently rejected
files move to `failed` and are no longer scanned. Successfully checked files
count as skipped without another database lookup. Files that disappear and are
later seen again are checked again.

Restart watch to check all loose news items again. Stop watch before maintenance
and restart it afterward. Published news item files must remain unchanged. A
single incremental pass checks every loose news item against the database.

## Rejected files

During `fill` or `fill --watch`, explicit extractor rejection and violated SQL
data constraints move the source file to `store/failed/<original filename>`. The
directory is created as needed. Storeindex and storepack ignore its contents.
The error log records the reason and destination. A single pass exits with 1 if
any file was rejected. Watch continues processing other files.

An existing destination is never overwritten. If moving fails, the run stops.
Operational failures such as an unavailable extractor or full disk also stop the
run and keep the source file. Timeouts and busy locks defer processing.

After fixing the input or the processing rules, move the file back to the store
root to retry. Stop store tools during manual recovery or acquire their shared
lock. Preserve the canonical filename. Maintenance commands do not process
`failed`.

## Stopping

Ctrl+C requests an orderly stop. Changes or removal of the INI or an included
file also stop the process. Configuration files are checked about every two
seconds, independently of `index.poll`. The process exits instead of reloading
configuration in place. A supervisor such as tiusnanny can restart it with the
new settings according to its restart policy.

The current news item finishes, then no further news item is indexed. Poll waits
are interrupted immediately. A running extractor may take up to `index.timeout`
to finish or time out. Every mode keeps already committed news items, including
interrupted maintenance. Data deleted by `rebuild` or `replace` is not restored.

During startup, a running extractor information request finishes or reaches
`index.timeout` before shutdown. No indexing starts after a stop request.

Windows Ctrl+Break is also handled. Forced process termination bypasses orderly
shutdown. Onefile builds use the toolkit parent guard so the application exits
if its bootloader is terminated.

## Maintenance

`fill --all`, `fill --since`, `replace`, and `rebuild` process loose files and
ZIPs. `replace` and `rebuild` select the entire store unless limited by
`--since`. Dates use `YYYY-MM-DD`. The selected range begins at midnight in the
local system timezone and uses the store timestamp, not the import time.

- `rebuild`: delete the entire database and create a new one from
	`storeindex.sql`, then index the selected news items
- `fill --all` or `fill --since`: add missing entries, keeping existing results
- `replace`: delete selected index entries first, then index that range again,
	keeping the schema, unrelated tables, and entries before `--since`

**`rebuild --since` still deletes the entire database, including older
entries.** The date limits only what is indexed afterward. Use `replace --since`
to retain older entries. Without `--since`, `replace` clears the entire index
while keeping the schema and unrelated tables.

Use `fill --since` to recover news items missed during an outage:

```text
storeindex fill --since 2026-09-01
```

Existing entries are identified by source, store timestamp, and suffix,
and skipped before reading their content or calling the extractor. They remain
even if their source files are missing. Use `replace` to reprocess successful
items after changing an extractor. Use `rebuild` for schema changes that require
recreating the database.

Stop watch before maintenance. Close external database connections before
`rebuild`, including when using `--since`. Back up the database manually
beforehand if needed. Storeindex creates no backup and does not restore deleted
data on failure. `replace` also removes selected entries whose sources are
missing.

Each successful item is saved immediately. Errors and interruption leave already
saved results intact. Resume maintenance with **`fill --all`**, or with
**`fill --since`** and the same date if the interrupted run used a cutoff:

```text
storeindex rebuild
# after an interruption
storeindex fill --all

# resume a run limited to a store date
storeindex fill --since 2026-09-01
```

The store is scanned again, including earlier files that arrived later. Saved
items are skipped and missing items are retried. Keep the same schema and
extractor configuration when resuming to avoid mixing extraction results.

Permanently rejected documents, SQL data constraint violations, and individual
file or ZIP errors are reported. Processing continues with the remaining inputs.
For items first indexed during the current run, conflicting duplicates are
reported and the first successful result is retained. Entries saved before the
run are trusted, so their content conflicts and ZIP CRCs are not checked again.
Maintenance never moves loose files to `failed` and never changes ZIP archives.
Operational failures such as an unavailable extractor, extraction timeout, full
disk, or invalid configuration stop the run.

Completion reports indexed, skipped, and error counts. The exit code is 1 if any
error was reported, otherwise 0. Fix the reported causes and use `fill --all` or
`fill --since` to retry missing items.

Storeindex prevents a second CLI run from using the same database while a run is
active. Maintenance holds the store lock throughout, so storepack cannot run at
the same time. Retry later if the required access is unavailable.

## Exit codes

| exit code | meaning                                                            |
| --------- | ------------------------------------------------------------------ |
| `0`       | successful completion or orderly stop after a configuration change |
| `1`       | failure, rejected input, or deferred work in a single pass         |
| `2`       | invalid command-line options or configuration values               |
| `130`     | stopped by Ctrl+C (`SIGINT`)                                       |
| `149`     | stopped by Windows Ctrl+Break (`SIGBREAK`)                         |
| `143`     | stopped by `SIGTERM` where delivered as a signal                   |

## Logging

Operational messages go to standard error and the configured log file.

| verbosity               | output                                                                                                                   |
| ----------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| default (INFO)          | one `indexed` message per successfully indexed news item, plus errors and lifecycle notices                              |
| `-v` (DEBUG)            | processing pending files, maintenance processing, lock deferrals, and scan summaries when items were indexed             |
| `-vv` or `-vvv` (TRACE) | scan and cache counts, scan summaries with zero indexed items, skipped file decisions, and extraction details            |
| `-q`                    | warnings and errors                                                                                                      |

Each `indexed` message includes the filename and its store timestamp
decoded in the local system timezone. This is the store timestamp, not the
processing time. Timestamps outside the platform's date range are shown as Unix
seconds.

Already indexed files produce no INFO message. An idle watch produces no scan
summaries at INFO or DEBUG. During incremental processing, rejected files
are moved to `failed` and logged. Timeouts are retried on later passes. Errors
appear immediately with their cause, once per attempt. TRACE intentionally
includes every cache hit. Processor information is logged per distinct command and mode at startup.
The text does not cause automatic reprocessing.

Each maintenance command announces its start at INFO and logs `indexed` after
each successful item is saved. It ends with an INFO summary of indexed, skipped,
and error counts. Start, completion, and stop messages name the active command.

TRACE adds one timing line per processed or database-checked item, with seconds
for `find`, `read` (including ZIP decompression), `extract` (including process
startup and response validation), `begin`, `write`, and `commit`. Failed writes
can also report `rollback`. Only attempted phases appear. Archive opening is
reported separately as `archive_open`.

Each scan or maintenance run emits a TRACE timing summary, including on errors
and cancellation. It contains total elapsed time, indexed/skipped/error counts,
summed phase durations, and `list` time for store enumeration. Error counts refer
to reported item errors, not fatal exceptions. Phase timers exclude timing-log
output. Total time also includes logging, setup, metadata checks, and other
unmeasured work, so it exceeds the phase sum. Compare a representative run with
and without TRACE to assess logging overhead.

For example, use `storeindex -vv rebuild` or `storeindex -vv fill --all`.

TRACE also reports the extractor's complete process duration and the time to
decode and validate its response. These are details within `extract`, not
additional phases to add to the run total. Captured stderr is forwarded with
the item filename after extraction, outside the phase timer. Diagnostics are
limited to 8 KiB and 32 lines per invocation, with control characters removed.

To distinguish LENI document processing from process overhead, use a leniextract
version with toolkit logging and append `-vv` to its configured command.
Run Storeindex with `-vv`. Leniextract then reports its own `select`, `read`,
`extract`, `output`, and CLI `total` times on stderr. Subtracting that CLI total
from Storeindex's process total estimates the remaining overhead, including
startup, imports, scheduling, pipe communication, and shutdown. It does not
isolate process startup. Storeindex does not add extractor options automatically.


TRACE reports startup-to-readiness and each call's
round-trip time instead of a complete process run per document. Leniextract
reports internal request phases with request IDs on stderr. See the persistent
extractor configuration in [settings](settings.md#extractor-lifetime).

`--since` resolves the date to the inclusive lower bound `timestamp >= X`.
Use the same store timezone on all runs. Later historical imports can add
matches without changing that bound. The cutoff is not a delivery cursor.
