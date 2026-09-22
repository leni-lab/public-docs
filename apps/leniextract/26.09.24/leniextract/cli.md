[back to overview](overview.md)
---

# Command line

```text
leniextract --field <name> [--field <name>] [--input <path>]
```

| option            | meaning                                             |
| ----------------- | --------------------------------------------------- |
| `--field`         | required field name, repeatable and comma-separated |
| `--input`         | UTF-8 JSON input file, defaults to standard input   |
| `-V`, `--version` | print version and build information                 |
| `-h`, `--help`    | print usage                                         |
| `-v`, `--verbose` | show debug diagnostics, repeat for TRACE timings    |
| `-q`, `--quiet`   | reduce diagnostics, repeat four times to silence logs |

Available fields:

| field      | JSON input      | value                                      |
| ---------- | --------------- | ------------------------------------------ |
| `title`    | `data.headline` | text or null, missing headline becomes null |
| `src_id`   | top-level `id`  | signed 64-bit integer or decimal string     |
| `src_rev`  | top-level `rev` | signed 64-bit integer or decimal string     |
| `keyword`  | `data.keywords` | string array, missing or null becomes `[]`  |
| `service`  | `data.svc_name` | text or null, missing service becomes null |
| `channel`  | `data.routing_released` | string array, missing or null becomes `[]` |
| `transmit_at` | `data.transmit_at`, then top-level `update_at` | required nonnegative integer |

Transmission time uses `update_at` when `data.transmit_at` is missing, null,
empty, or zero. Both accept nonnegative integers or decimal strings within the
signed 64-bit range. A missing, null, or empty fallback rejects the input.
A fallback of zero is valid. Other invalid values reject the
input with exit code 3. A valid nonzero transmission time takes precedence,
so an unused `update_at` is not validated. A `data` object is required.

Every requested field is validated and returned. Optional scalar fields use
null for missing values and array fields use `[]`. Requested fields are never
omitted. Unrequested fields are absent. Decimal strings such as
`"1117006"` and `"1"` are converted to JSON integers. Strings may contain
ASCII digits, an optional leading `+` or `-`, and leading zeros. Whitespace,
decimal points, and exponents are not accepted. Missing IDs or revisions,
null, booleans, floats, invalid strings, and values outside the signed 64-bit
range are rejected with exit code 3 when the respective field is requested.

Keywords and channels require a `data` object. Exact duplicate strings are removed, keeping
the first occurrence and its order. Case, whitespace, and spelling are preserved.
For example, `["Religion", "Kirche", "Religion"]` becomes
`["Religion", "Kirche"]`. A single keyword still returns an array. Other values
or non-string elements are rejected with exit code 3.

Service also requires a `data` object. Its text is preserved, including an empty
string. Missing or null values return `{"service":null}`. Other types are rejected
with exit code 3. For example, requesting service and channels can return:

```json
{"service":"lwd","channel":["arc","lwd.mecom"]}
```

The output field is `keyword`. The source document uses `data.keywords`.

For Storeindex use `leniextract --field title,src_id,src_rev,keyword,service,channel,transmit_at`. These
title-only calls are equivalent:

```text
leniextract --field title
leniextract --field title,title
leniextract --field title --field title
```

Whitespace around names is removed and duplicate fields are combined. Empty
field names and unsupported names produce an error.

## Results

Success prints exactly one JSON object on standard output. A missing or null
title produces `{"title": null}`. An empty title remains an empty string.
Diagnostic messages go to standard error.

Unicode characters may appear as JSON escape sequences. A JSON reader restores
the original characters. The returned title is not shortened or reformatted.

| exit code | meaning                                                  |
| --------- | -------------------------------------------------------- |
| `0`       | successful extraction, including a missing title         |
| `1`       | operational or unexpected failure                        |
| `2`       | command-line usage failure, including unsupported fields |
| `3`       | input rejected, invalid UTF-8 JSON or document structure |
| `130`     | interrupted with Ctrl+C                                 |

On failure, there is no result on standard output. Applications should accept
a result only when the exit code is zero.

Exit code `3` identifies a permanent rejection of this input. Other failures
do not establish that the document is invalid. Consumers must not quarantine
input based on exit code `1` or `2`. This replaces the former combined error
code `1` for invalid input and operational failures.


## Processing timings

Add `-vv` to write a timing line to stderr, including on processing failure.
Verbose options and `-q` cannot be combined.
Successful calls emit no diagnostics by default.
Unexpected failures include a traceback with `-v`.

When stdout is redirected, log lines on stderr have numeric level prefixes:
`[0]` TRACE, `[1]` DEBUG, `[2]` INFO, `[3]` WARNING, `[4]` ERROR, and
`[5]` CRITICAL. Quiet options suppress logs without changing exit codes.

The JSON response on stdout and exit codes remain unchanged. Times are seconds
for field selection (`select`), input reading (`read`), JSON parsing and field
extraction (`extract`), and serialization and output (`output`). Only attempted
phases appear. The `total` covers processing after toolkit startup, including
rejection diagnostics but excluding the timing line itself.

These measurements exclude interpreter startup, imports, Click initialization,
toolkit startup, and process shutdown. Compare them with the caller's process duration
to estimate the remaining overhead, which also includes scheduling and pipe
communication. That difference is not a measurement of process startup alone.

For Storeindex, add `-vv` to the configured extractor command and run
Storeindex with `-vv`. Storeindex forwards stderr diagnostics at TRACE level.


## Persistent session

Use `--serve` to process multiple documents in one process:

```text
leniextract --serve --field title,src_id,src_rev,transmit_at,keyword,service,channel
```

This mode is for callers such as Storeindex, using a framed pipe protocol.
It cannot be combined with `--input`. Without `--serve`, the single-document
interface and exit codes remain unchanged. `-vv` enables per-request timings
on stderr through toolkit logging. Stdout contains only protocol responses.

For Storeindex, set `mode = session` in the source section and add `--serve` to
its configured command. Keep the existing `--field` arguments. One process
handles the complete indexing action or watch lifetime. A rejected document
produces a rejection response and the process waits for the next request.
Closing stdin ends the session. Use the normal onedir build for this mode.
