[back to overview](overview.md)
---

# Command line

```text
leniextract --field <name> [--field <name>] [--input <path>]
```

| option            | meaning                                               |
| ----------------- | ----------------------------------------------------- |
| `--field`         | field names, required for raw CLI and optional processor default |
| `--processor`     | one Toolkit-framed request |
| `--serve`         | repeated Toolkit-framed requests |
| `--input`         | UTF-8 JSON input file, defaults to standard input     |
| `-V`, `--version` | print version and build information                   |
| `-h`, `--help`    | print usage                                           |
| `-v`, `--verbose` | show debug diagnostics, repeat for TRACE timings      |
| `-q`, `--quiet`   | reduce diagnostics, repeat four times to silence logs |

Index fields:

| field         | JSON input                                     | value                                       |
| ------------- | ---------------------------------------------- | ------------------------------------------- |
| `title`       | `data.headline`                                | text or null, missing headline becomes null |
| `src_id`      | top-level `id`                                 | signed 64-bit integer or decimal string     |
| `src_rev`     | top-level `rev`                                | signed 64-bit integer or decimal string     |
| `keyword`     | `data.keywords`                                | string array, missing or null becomes `[]`  |
| `service`     | `data.svc_name`                                | text or null, missing service becomes null  |
| `channel`     | `data.routing_released`                        | string array, missing or null becomes `[]`  |
| `transmit_at` | `data.transmit_at`, then top-level `update_at` | required nonnegative integer                |

Additional [content fields](content-fields.md) include Markdown body,
subline, authorline, teaser, location, public/private service metadata,
embargo, revision signal, and previous-publication information. They use the
same `--field` selection and session protocol. The source is parsed only when
a requested field needs it.

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

For Storeindex use `leniextract --field title,src_id,src_rev,keyword,service,channel,transmit_at`.
Names must match exactly, including case. Repeated names, surrounding whitespace,
empty names and unsupported names are errors. For example, use `--field title`
or `--field title,keyword --field service`.

## Raw CLI results

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
| `130`     | interrupted with Ctrl+C                                  |

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


## Processor modes

Use `--processor` for a single framed request or `--serve` for a persistent
session. Both use `toolkit.processor/1-draft` and advertise the operation
`leniextract.fields/1-legacy`. They cannot be combined with each other or
`--input`. Raw invocation without either flag still reads a LENI document and
prints one JSON result. There is no automatic detection of old protocols.

For Storeindex, set `contract = leniextract.fields`, `version = 1-legacy` and
`mode = once` or `mode = session`. Keep the existing `--field` arguments in
`command`, but remove mode flags. Toolkit adds the flag itself. The existing
index schema and field meanings remain unchanged, so no rebuild is required.

Each application request is a JSON parameter line plus LF, then unchanged source
bytes. `{"action":"catalog"}` with no source returns a JSON array of supported
field names. `{"action":"extract"}` uses the CLI field default. Optional
`fields`, an array of exact names, replaces that default for one request only.
Starting without a default is allowed; extraction then needs explicit fields.
Null, empty, duplicate and unknown selections reject the request.

Extraction returns a direct JSON field object inside the Toolkit result payload.
A rejected request has no partial result and leaves a healthy session usable.
Closing stdin between requests ends a session. `-vv` emits request timings on
stderr. Stdout contains only Toolkit framing and payloads.

The normalized field catalogue and its semantic renaming remain planned. The
intermediate operation lists only fields already implemented by this version.
