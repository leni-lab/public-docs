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
	--field title,src_id,src_rev
	--field keyword,service,channel,transmit_at
```

Indent command continuation lines. Repeat `--field` to split the selected
fields across lines.

Store, database, and extractor paths resolve beside the INI. Keep the database
on local storage outside the store. The store may contain both loose news items
and daily ZIPs.

Storeindex uses the local system timezone, including daylight saving time, like
storepack. Both systems must use the same timezone. A `timezone` entry in
`[store]` has no effect.

| setting                 | default              | meaning                                                      |
| ----------------------- | -------------------- | ------------------------------------------------------------ |
| `store.path`            | required             | existing published store                                     |
| `index.database`        | `storeindex.sqlite3` | local database path outside store                            |
| `index.schema`          | `storeindex.sql`     | UTF-8 SQL file, relative to the INI                          |
| `index.poll`            | `10s`                | time between completed `fill --watch` passes                 |
| `index.timeout`         | `30s`                | timeout per extractor call, including startup version checks |
| `index.busy_timeout`    | `1s`                 | database contention wait                                     |
| `source <name>.command` | required             | executable and arguments, with double-quote grouping         |

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
command = .venv/Scripts/leniextract.exe --field title,src_id,src_rev,keyword,service,channel,transmit_at
```

This relative path assumes `.venv` is beside the INI. Commands use that same
directory as their working directory. Additional arguments are passed unchanged.
Shell commands and shell expansion are not supported.

Separate arguments with whitespace and double-quote paths or arguments
containing spaces, for example
`command = "C:\Program Files\leniextract.exe" --custom`. Backslashes remain
literal. Inside quoted text, `""` represents a literal double quote. An empty
quoted argument is preserved, but the executable must not be empty.

Existing INI files must be migrated: change bare seconds such as `10` to `10s`
and decimal seconds such as `0.5` to `500ms`. Replace JSON command arrays such
as `["leniextract", "--custom"]` with `leniextract --custom`. JSON arrays are no
longer decoded. These changes also apply to command-line `-s` overrides.

Every distinct configured command is called with `--version` once at startup,
before opening the database. It must exit with `0` and write one nonempty UTF-8
line to stdout. Trailing line endings are ignored. The version is logged for
each source. A failed check stops the entire run, even for a source without
pending news items. The version is diagnostic only and is not stored or
compared.

Successfully indexed news items are skipped regardless of changes to the command
or program version. Use `replace` or `replace --since YYYY-MM-DD` to reprocess
them deliberately. Deferred incremental inputs are retried. Rejected inputs move
to `failed` only during incremental processing. The extracted `src_rev`
identifies a source document revision and does not trigger reprocessing.

In `mode = once`, the extractor exit codes form a contract:

| exit code              | meaning and action                                                                            |
| ---------------------- | --------------------------------------------------------------------------------------------- |
| `0`                    | validate the JSON response and store its fields                                               |
| `3`                    | permanently rejected input, report and continue, quarantine only in `fill` and `fill --watch` |
| any other nonzero code | operational failure, abort and keep the input                                                 |

Leniextract uses `1` for operational failures and `2` for invalid CLI arguments.
Use the updated Leniextract together with this Storeindex version. Older builds
report invalid documents as exit `1`, which now stops Storeindex.

Timeouts keep loose files eligible for retry during `fill` and `fill --watch`.
They abort `fill --all`, `fill --since`, `replace`, and `rebuild`. Failure to
start the extractor, invalid output, or configuration/schema mismatches abort
the run. Already committed results remain in every mode.

### Persistent extractor sessions

To reuse one leniextract process for a complete indexing run or watch lifetime:

```ini
[source leni]
mode = session
command = leniextract --serve
    --field src_id,src_rev,transmit_at,title,keyword,service,channel
```

Both updated programs are required. `mode` defaults to `once`, which starts one
process per document. Storeindex passes the command unchanged; `mode = session`
must be paired with the extractor's server option. A failed readiness check
stops the CLI before changing the database. Sessions process one document at a
time and keep the existing commit, rejection, and retry behavior.

`index.timeout` applies separately to session startup readiness and each
document exchange, including writing the input. A timed-out process is discarded.
Watch can create a fresh session for the next attempt. Normal shutdown finishes
the active document, then closes the session. Use the normal onedir leniextract
build. The session transport accepts documents up to 64 MiB and responses up to
16 MiB. Exceeding these limits stops processing without quarantining the input.

For measurements, append `-vv` to the leniextract command and start Storeindex
with `-vv` as well. Leniextract now uses toolkit verbosity; its former `--trace`
option is no longer supported.

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
field options. Its output must be a UTF-8 JSON object whose keys name writable
payload columns in `item` or array fields following the naming conventions
below. The bundled schema defines `title`, `keyword`, `service`, `channel`, `transmit_at`,
`src_id`, and `src_rev`.
Leniextract reads the latter two from top-level
JSON `id` and `rev`. Both must be signed 64-bit integers. Missing values, null,
booleans, strings, and fractional numbers are rejected. Only requested fields
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
belong to the SQL file. For example, `title TEXT NOT NULL` rejects an explicit
null title. Foreign keys are enforced by SQLite when writing data. Indexes, FTS
definitions, and their maintenance triggers belong entirely to the SQL file.

IF NOT EXISTS checks names, not definitions. Added indexes can be created on
restart, but existing columns and triggers are not updated. For structural
changes, run `rebuild` to recreate the database. Add `--since` to index only
recent news items afterward, discarding older index entries. There is no
automatic migration. A newly created FTS index does not automatically include
old rows. Successful news items are never reprocessed merely because the schema
file or extractor command changed.

### Ordered keywords

With `--field keyword`, Leniextract reads `data.keywords` and returns a string
array, for example `{"keyword":["Religion","Kirche"]}`. A missing or null source
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
values are not included in the title full-text index.

Array fields use a fixed naming convention:

| field      | lookup table         | link table                          |
| ---------- | -------------------- | ----------------------------------- |
| `keyword`  | `keyword(id, value)` | `item_keyword(item, keyword, position)` |
| `channel`  | `channel(id, value)` | `item_channel(item, channel, position)` |
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

### Transmission time

Leniextract returns `transmit_at` from `data.transmit_at`. Missing, null, empty,
or zero values use top-level `update_at` instead. Integers and decimal strings
are accepted and stored as a required nonnegative integer in `item.transmit_at`.
If the fallback is missing, null, or empty, the document is rejected. Invalid
types, negative timestamps, and values outside the signed 64-bit range are
also rejected. A fallback of zero is valid.

Add `transmit_at` to the extractor field selection and run `rebuild` with the
updated schema to add the column and populate existing items.

### Service and channels

Leniextract returns `service` from `data.svc_name` as text or null. Missing or
null source values return null. Empty strings, case, whitespace, and spelling
are preserved. Storeindex stores the scalar in `item.service`.

The `channel` field comes from `data.routing_released` and always returns a
string array. Missing or null values return `[]`. Exact duplicates are removed,
keeping the first occurrence and its order. Other types or non-string elements
reject the input. Both fields require a `data` object when requested.

For example, `--field service,channel` can return:

```json
{"service":"lwd","channel":["arc","lwd.mecom"]}
```

Channels use `channel(id, value)` and `item_channel(item, channel, position)`
with the same ordering, foreign keys, and replacement behavior as keywords.
An explicit `[]` clears the assignments, and null clears `item.service`.
Neither field contributes to the title full-text index.

After adding these fields, use the updated schema and extractor command, then
run `rebuild`. `CREATE TABLE IF NOT EXISTS` does not add the `service` column to
an existing `item` table. Rebuilding also extracts the fields for existing items.

### Upgrading the schema and field name

This version uses `item`, `item_fts`, and `item_keyword` in place of `news_item`,
`news_item_fts`, and `news_item_keyword`. Update queries to use the new names and
link columns `item` and `keyword`. The `array_field` registry is removed.
Leniextract's output field and command option are now `keyword`. The old
`keywords` field name is unsupported. Its input path remains `data.keywords`.

Install the updated Leniextract and Storeindex, use the updated schema, and set
`--field title,src_id,src_rev,keyword,service,channel,transmit_at` in the extractor command. Run `rebuild` to
recreate and repopulate the index. Regular `fill` skips existing items. There
are no compatibility aliases or automatic migrations. Changing the selected
fields later also requires reindexing with the new complete response.

## News item names

News items use `<published_at>_<suffix>.<source>.json`, for example:

```text
1789203039_001.leni.json
```

The publication time `published_at` is whole Unix seconds without leading zeros.
The numeric suffix has at least three digits, padded with leading zeros. Source
names begin with a lowercase ASCII letter and otherwise contain lowercase
letters, digits, underscores, or hyphens. Imports may arrive in any order.

News items must be complete when published and unchanged afterward. ZIPs use the
storepack layout: `YYYY-MM/YYYY-MM-DD.zip` with flat news item entries belonging
to that local calendar day.
