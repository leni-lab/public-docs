[back to overview](overview.md)
---

# Settings

Configuration uses the standard toolkit INI loader. See the
[complete example](storeindex.example.ini).

```ini
[store]
path = D:/data/store

[index]
database = storeindex.sqlite3
schema = storeindex.sql
poll = 10s
timeout = 30s
busy_timeout = 1s

[source leni]
command = leniextract
	--field headline_raw,src_id,src_rev
	--field keywords_raw,service,channels,locations

[fields]
headline = headline_raw
keyword  = keywords_raw
channel  = channels
location = locations
```

Indent command continuation lines. Repeat `--field` to split the selected
fields across lines.

Store, database, and extractor paths resolve beside the INI. Keep the database
on local storage outside the store. The store may contain both loose news items
and daily ZIPs.

Storeindex uses the local system timezone, including daylight saving time, like
storepack. Both systems must use the same timezone. A `timezone` entry in
`[store]` has no effect.

| setting                 | default              | meaning                                                        |
| ----------------------- | -------------------- | -------------------------------------------------------------- |
| `store.path`            | required             | existing published store                                       |
| `index.database`        | `storeindex.sqlite3` | local database path outside store                              |
| `index.schema`          | `storeindex.sql`     | UTF-8 SQL file, relative to the INI                            |
| `index.poll`            | `10s`                | time between completed `fill --watch` passes                   |
| `index.timeout`         | `30s`                | timeout per extractor call, including startup readiness checks |
| `index.busy_timeout`    | `1s`                 | database contention wait                                       |
| `source <name>.command` | required             | executable and arguments, with double-quote grouping           |

Durations require an integer and a unit: `ms`, `s`, `min`, or `h`. Use `500ms`
for half a second. Values must be positive and finite. Additional entries and
sections may hold values for interpolation or inheritance. Unused entries,
including `min_age`, have no effect. Required settings and used values are still
validated.

## Shared configuration and logging

The loader supports `@include`, `${section:key}` interpolation, and `.parent`
section inheritance. Inline `#` comments require at least two whitespace
characters before `#`. UTF-8 files may have a byte-order mark.

```ini
[logging]
/asyncio = warning  # absolute logger name

[logging file]
log_file = storeindex.log
```

Relative log filenames resolve against the application directory, the current
directory for Python runs or the executable directory for packaged builds.
`[logging console]`, `[logging file]`, and `[logging pipe]` control the
respective handlers. `[logging]` sets per-logger levels. Logger names without a
leading slash are prefixed with `storeindex.`.

Use `-v` and `-q` to adjust verbosity, or `-s index:poll=5s` to override a
setting. Startup messages and operational logs go to stderr. Configuration is
loaded at startup. Changes to the INI or an included file stop the process after
the active news item. Restart to load the new configuration.

## Extractors

Configure at least one source. Each source may use a different extractor. An
executable name is resolved through PATH. Activate the appropriate Python
environment or specify an executable path, for example:

```ini
[source leni]
command = .venv/Scripts/leniextract.exe --processor --field headline_raw,src_id,src_rev,keywords_raw,service,channels,locations
```

This relative path assumes `.venv` is beside the INI. Commands use that same
directory as their working directory. Additional arguments are passed unchanged.
Shell commands and shell expansion are not supported.

Separate arguments with whitespace and double-quote paths or arguments
containing spaces, for example
`command = "C:\Program Files\leniextract.exe" --custom`. Backslashes remain
literal. Inside quoted text, `""` represents a literal double quote. An empty
quoted argument is preserved, but the executable must not be empty.

Every distinct invocation is initialized before database changes, including
sources with no pending items. Storeindex waits for protocol readiness, logs an
optional readiness report as text, and retains the processor. Failed readiness
stops the run. Configure the complete command, including `--processor` and,
optionally, `--once` for one document per child process.

Successfully indexed news items are skipped regardless of changes to the command
or program version. Use `replace` or `replace --since YYYY-MM-DD` to reprocess
them deliberately. Deferred incremental inputs are retried. Rejected inputs move
to `failed` only during incremental processing. The extracted `src_rev`
identifies a source document revision and does not trigger reprocessing.

Requests carry unchanged source bytes in MessagePack binary values. Successful
responses contain complete JSON field objects. Controlled rejection permits
further calls and quarantine only during incremental work. Technical failures,
invalid output, and configuration errors stop the run without quarantine.
Reports do not affect this decision.

Timeouts keep loose files eligible for retry during `fill` and `fill --watch`.
They abort `fill --all`, `fill --since`, `replace`, and `rebuild`. Failure to
start the extractor, invalid output, or configuration/schema mismatches abort
the run. Already committed results remain in every mode.

### Extractor lifetime

To reuse a Leniextract process across documents and watch passes:

```ini
[source leni]
command = leniextract --processor
    --field src_id,src_rev,headline_raw,keywords_raw,service,channels,locations
```

Add `--once` to request one document per process. Storeindex accepts the result
only after clean announced termination, then starts a replacement for the next
call. The configured arguments stay fixed for each process.

`index.timeout` caps startup and request phases independently. Source settings
`startup_timeout` and `request_timeout` can impose shorter deadlines. Configure
`shutdown_timeout` for process completion, also capped by `index.timeout`.
`cwd` defaults to the INI folder. Relative executable paths use that folder.
Toolkit owns pipe draining and cleanup of the complete process tree.

Source byte limits are `input_limit`, `output_limit`, `report_limit`,
`message_limit`, and `stderr_limit`. Defaults are 64 MiB, 128 MiB, 4 MiB,
133 MiB, and 64 KiB respectively. Values are positive integer byte counts.
Rejection reports may supply diagnostic detail. Operating-limit violations are technical failures.
A timed-out processor is discarded; a later attempt uses a fresh object.
The host currently requires Windows and CPython.

For measurements, append `-vv` to the leniextract command and start Storeindex
with `-vv` as well. Leniextract uses Toolkit verbosity.

## Field assignment

The optional global `[fields]` section applies to every source and both
processor modes. Each entry is `database name = processor field`:

```ini
[fields]
headline = headline_raw
keyword  = keywords_raw
channel  = channels
location = locations
```

Unmapped fields retain their names. Mapped source names are replaced, not
copied. Values remain unchanged, including nulls, empty arrays, ordering,
case, and whitespace. Assignments are simultaneous, so their order does not
matter. Use each source once and distinct database targets, ignoring case
for target uniqueness. Reserved metadata names cannot be targets.

A configured source must occur in every successful response. Missing sources
or collisions with another result field abort the run before that item is
written, without quarantining the source document. The extractor remains
responsible for returning every selected field, including unmapped fields.
Storeindex does not infer selections from CLI arguments or inspect the schema.

Scalar targets name columns in `item`. Array targets name lookup/link tables,
so `keyword` uses `keyword` and `item_keyword`. The section performs no value
conversion, filtering, or source-specific interpretation.

## Schema and output fields

Place [storeindex.sql](storeindex.sql) beside the INI or select another file
with `index.schema`. After extractor checks, the SQL is executed once per start
on both new and existing databases, including in watch mode. Restart to apply
SQL changes. The complete script runs in one transaction.
A failure rolls back schema changes. `rebuild`, even with `--since`, deletes the
old database before executing the script, so schema failure cannot restore the
old index. Do not put transaction statements, connection PRAGMAs, or ATTACH in
the script. Storeindex owns those settings. The provided CREATE statements use
IF NOT EXISTS.

The extractor command is used exactly as configured. Storeindex does not append
field options. Its output must be a UTF-8 JSON object whose keys name processor
fields. Storeindex applies the global [field assignments](#field-assignment)
before matching writable columns in `item` or array fields. The bundled schema
defines `headline`, `keyword`, `location`, `service`, `channel`, `src_id`,
and `src_rev`.
Leniextract reads the latter two from top-level
JSON `id` and `rev`. Both must be signed 64-bit integers. Missing values, null,
booleans, invalid strings, and fractional numbers are rejected. Decimal
strings within range are accepted. Only requested fields
are validated by Leniextract, so request both identifiers with the bundled SQL.
The unique key `(source, src_id, src_rev)` rejects a second copy of the same
source document revision. Different revisions and sources remain distinct.

The indexer has no special knowledge of these fields. For example, add nullable
`summary TEXT` and `priority INTEGER` columns in a custom schema and configure
an extractor that emits `{"summary":"Example","priority":2}`.

Scalar values may be strings, signed 64-bit integers, finite numbers, booleans,
or null. Booleans are stored as 0 or 1. Array fields accept only arrays of
strings. Objects, nested arrays, non-string array elements, duplicate keys,
unknown fields, and attempts to set indexing metadata abort the run as
protocol/configuration errors. Each field's type must stay fixed. The extractor
must return every requested field, using null for an absent optional scalar and
`[]` for an empty array. Requested fields must never be omitted. Storeindex
trusts this contract and does not maintain a separate field list. Failed
extractions do not create index entries. Generated columns belong to SQLite and
must not appear in the output.

Keep the core tables, column types, integer primary keys, and unique keys from
the example schema. Validate schema changes with tests before use. Storeindex
does not analyze table structure at startup. Payload types and constraints
belong to the SQL file. For example, `headline TEXT NOT NULL` rejects an explicit
null headline. Foreign keys are enforced by SQLite when writing data. Indexes, FTS
definitions, and their maintenance triggers belong entirely to the SQL file.

IF NOT EXISTS checks names, not definitions. Added indexes can be created on
restart, but existing columns and triggers are not updated. For structural
changes, run `rebuild` to recreate the database. Add `--since` to index only
recent news items afterward, discarding older index entries. There is no
automatic migration. A newly created FTS index does not automatically include
old rows. Successful news items are never reprocessed merely because the schema
file or extractor command changed.

### Ordered keywords

With `--field keywords_raw`, Leniextract reads `data.keywords` and returns a string
array, for example `{"keywords_raw":["Religion","Kirche"]}`. The mapping
`keyword = keywords_raw` selects the database target. A missing or null source
value becomes `[]`. Exact duplicates are removed, retaining the first occurrence
and original order. Case and spelling are preserved.

The bundled SQL stores distinct strings in `keyword` and their ordered
assignments in `item_keyword`. Foreign keys prevent broken references.
Deleting a news item removes its assignments. A keyword still in use cannot be
deleted. Saving an item replaces all its assignments, including clearing them
for an explicitly empty array. Scalar fields, new keywords, and assignments
commit together or all roll back. Unused keyword rows are retained.

Read an item's keywords in their original order using its internal database ID:

```sql
SELECT k.value
FROM item_keyword AS l
JOIN keyword AS k ON k.id = l.keyword
WHERE l.item = ?
ORDER BY l.position;
```

Positions start at zero. Always use `ORDER BY position` to retrieve the order.
Keyword lookup is exact and case-sensitive with the bundled schema. Keyword
values are not included in the headline full-text index.

Array fields use a fixed naming convention:

| field      | lookup table          | link table                                |
| ---------- | --------------------- | ----------------------------------------- |
| `keyword`  | `keyword(id, value)`  | `item_keyword(item, keyword, position)`   |
| `channel`  | `channel(id, value)`  | `item_channel(item, channel, position)`   |
| `location` | `location(id, value)` | `item_location(item, location, position)` |
| `category` | `category(id, value)` | `item_category(item, category, position)` |

For another array field, create its tables following the keyword example and
configure the extractor to return the field. No registry or additional array
setting is needed. Each link table requires a primary key on `(item, position)`,
a unique key on `(item, <field>)`, a reference from `item` to `item(id)` with
`ON DELETE CASCADE`, and a reference from `<field>` to `<field>(id)` with
`ON DELETE RESTRICT`. Follow the example's NOT NULL and nonnegative-position
constraints. Keep array field names distinct from columns in `item`.

Storeindex does not deduplicate arrays. Duplicate assignments violate the SQL
unique key and reject the whole item. Schema mismatches fail when SQL uses the
corresponding table or column.

### Store timestamp

`item.timestamp` is the permanent store time component from the filename,
under the [newsstore contract](https://github.com/leni-lab/newsstore/blob/main/docs/store-contract.md#timestamp-and-processing-position).
It uses nonnegative integer Unix seconds and may be a logical value oriented
to the clock. It does not establish a source release time or exact arrival
time. Rebuilding keeps the value. It is reserved metadata, so do not request
it from Leniextract or map an extracted field to it.

Source `released_at`, `published_at`, `transmit_at`, and `update_at` remain
independent content. If separately indexed, use distinct database names such
as `source_released_at`.

Storeindex, Storeview, the SQL schema, and extractor configuration must agree.
`rebuild` creates and repopulates the database. Initialization, `fill`, and
`replace` retain existing column definitions. Store filenames and JSON bytes
are independent of schema maintenance.

### Service and channels

Leniextract returns `service` from `data.svc_name` as text or null. Missing or
null source values return null. Empty strings, case, whitespace, and spelling
are preserved. Storeindex stores the scalar in `item.service`.

The `channels` field comes from `data.routing_released` and always returns a
string array. Missing or null values return `[]`. Exact duplicates are removed,
keeping the first occurrence and its order. Other types or non-string elements
reject the input. Both fields require a `data` object when requested.

For example, `--field service,channels` can return:

```json
{"service":"lwd","channels":["arc","lwd.mecom"]}
```

With `channel = channels
location = locations`, channels use `channel(id, value)` and `item_channel(item, channel, position)`
with the same ordering, foreign keys, and replacement behavior as keywords.
An explicit `[]` clears the assignments, and null clears `item.service`.
Neither field contributes to the headline full-text index.

### Schema and field changes

Deploy Leniextract, Storeindex, Storeview, the SQL schema, and the field
configuration together. Run `rebuild` to recreate and repopulate the index
before starting Storeview. Regular `fill` skips existing items. Changing a
field selection or mapping requires reprocessing the affected items. A schema
change requires rebuilding the database.

## News item names

News items use `<timestamp>_<suffix>.<source>.json`, for example:

```text
1789203039_001.leni.json
```

The store time component `timestamp` is whole Unix seconds without leading zeros.
The numeric suffix has at least three digits, padded with leading zeros. Source
names begin with a lowercase ASCII letter and otherwise contain lowercase
letters, digits, underscores, or hyphens. Historical imports may arrive in any order. Regular input requires ordered
publication and index visibility under the shared contract. See the current
[ordering and operating requirements](https://github.com/leni-lab/storeindex/blob/main/docs/architecture.md#ordering-and-visibility).

News items must be complete when published and unchanged afterward. ZIPs use the
storepack layout: `YYYY-MM/YYYY-MM-DD.zip` with flat news item entries belonging
to that local calendar day.


### Dateline locations

Select `--field locations` and map `location = locations`. Leniextract returns
the places before `(epd).` at the beginning of the Markdown body. For example,
`Berlin/Bonn (epd).` produces `["Berlin", "Bonn"]`. Commas and slashes separate
places, exact duplicates are removed, and source order is retained. These are
dateline places, independent of service `orte` or other places in the story.
A missing dateline returns `[]`, including missing or empty Markdown.
Malformed nonempty Markdown is rejected when locations are requested.

The bundled `location` and `item_location` tables follow the same constraints
and replacement behavior as keywords. Deploy Leniextract, the schema, field
selection, and Storeview together. Stop the consumers and run
`storeindex rebuild` with the updated configuration before restarting them. Existing items
are not enriched by a normal scan or fill.
