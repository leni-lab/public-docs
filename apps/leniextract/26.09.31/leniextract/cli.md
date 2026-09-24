[back to overview](overview.md)
---

# Command line

```text
leniextract --field <name> [--field <name>] [--input <path|->] [--output <path>]
leniextract --processor [--once] --field <name> [--field <name>]
```

| option            | meaning                                                 |
| ----------------- | ------------------------------------------------------- |
| `--field`         | required field names, fixed for the process lifetime    |
| `--input`         | UTF-8 JSON file, or `-` for stdin; omit to initialize only |
| `--output`        | write the result to a file instead of stdout       |
| `--processor`     | serve sequential MessagePack requests                  |
| `--once`          | finish after one processor call                        |
| `--report`        | write report bytes to a file instead of stderr         |
| `-V`, `--version` | print version and build information                     |
| `-h`, `--help`    | print usage                                             |
| `-v`, `--verbose` | show debug diagnostics, repeat for TRACE timings        |
| `-q`, `--quiet`   | reduce diagnostics, repeat four times to silence logs   |

Index fields:

| field          | JSON input                                     | value                                       |
| -------------- | ---------------------------------------------- | ------------------------------------------- |
| `headline_raw` | `data.headline`                                | text or null, missing headline becomes null |
| `src_id`       | top-level `id`                                 | signed 64-bit integer or decimal string     |
| `src_rev`      | top-level `rev`                                | signed 64-bit integer or decimal string     |
| `locations`    | leading body dateline in `data.markdown`        | ordered string array, absent becomes `[]`   |
| `keywords_raw` | `data.keywords`                                | string array, missing or null becomes `[]`  |
| `service`      | `data.svc_name`                                | text or null, missing service becomes null  |
| `channels`     | `data.routing_released`                        | string array, missing or null becomes `[]`  |
| `dispatch_at`  | `data.transmit_at`, then top-level `update_at` | required nonnegative integer                |

Additional [content fields](content-fields.md) include Markdown body,
subline, authorline, teaser, location, public/private service metadata,
embargo, revision signal, and previous-publication information. They use the
same `--field` selection and session protocol. The source is parsed only when
a requested field needs it.

Transmission time uses `update_at` when `data.transmit_at` is missing, null,
empty, or zero. Both accept nonnegative integers or decimal strings within the
signed 64-bit range. A missing, null, or empty fallback rejects the input.
A fallback of zero is valid. Other invalid values reject the
input with direct CLI exit code 65. A valid nonzero transmission time takes precedence,
so an unused `update_at` is not validated. A `data` object is required.

Every requested field is validated and returned. Optional scalar fields use
null for missing values and array fields use `[]`. Requested fields are never
omitted. Unrequested fields are absent. Decimal strings such as
`"1117006"` and `"1"` are converted to JSON integers. Strings may contain
ASCII digits, an optional leading `+` or `-`, and leading zeros. Whitespace,
decimal points, and exponents are not accepted. Missing IDs or revisions,
null, booleans, floats, invalid strings, and values outside the signed 64-bit
range are rejected with direct CLI exit code 65 when the respective field is requested.

Keywords and channels require a `data` object. Exact duplicate strings are removed, keeping
the first occurrence and its order. Case, whitespace, and spelling are preserved.
For example, `["Religion", "Kirche", "Religion"]` becomes
`["Religion", "Kirche"]`. A single keyword still returns an array. Other values
or non-string elements are rejected with direct CLI exit code 65.

Locations use the same dateline extraction as the existing `location` content
field. Commas and slashes separate places, duplicates are removed, and order is
preserved. Missing datelines return `[]`. Invalid nonempty Markdown is rejected.
Service `orte` and withdrawal status do not change these source places.

Service also requires a `data` object. Its text is preserved, including an empty
string. Missing or null values return `{"service":null}`. Other types are rejected
with direct CLI exit code 65. For example, requesting service and channels can return:

```json
{"service":"lwd","channels":["arc","lwd.mecom"]}
```

The output field is `keywords_raw`. The source document uses `data.keywords`.

For Storeindex use `leniextract --processor --field headline_raw,src_id,src_rev,keywords_raw,service,channels,dispatch_at,locations`.
In Storeindex, map `headline = headline_raw`, `keyword = keywords_raw`,
`channel = channels`, and `location = locations` in `[fields]`. Other names pass through unchanged.
Names must match exactly, including case. Repeated names, surrounding whitespace,
empty names and unsupported names are errors. For example, use `--field headline_raw`
or `--field headline_raw,keywords_raw --field service`.

## Raw CLI results

With input, success writes exactly one JSON object to stdout or `--output`.
Without input, the command initializes and writes a readiness report to stderr
or `--report`. It does not read stdin or invoke extraction. A missing or null
title produces `{"headline_raw": null}`. An empty title remains an empty string.
Diagnostic messages go to standard error.

Unicode characters may appear as JSON escape sequences. A JSON reader restores
the original characters. The returned title is not shortened or reformatted.

| exit code | meaning                                                  |
| --------- | -------------------------------------------------------- |
| `0`       | successful extraction, including a missing title         |
| `1`       | Click abort                                              |
| `2`       | command-line usage failure, including unsupported fields |
| `65`      | input rejected, invalid UTF-8 JSON or document structure |
| `64`      | technical wrapper failure                               |

On failure, there is no result on standard output. Applications should accept
a result only when the exit code is zero.

Exit code `65` identifies a permanent rejection of this input. Other failures
do not establish that the document is invalid. Consumers must not quarantine
input based on technical or Click failures.


## Processing timings

Add `-vv` to emit a processing-duration line on stderr. Verbose options and
`-q` cannot be combined. Successful requests have no diagnostics by default.
Unexpected worker failures include a traceback. Failure diagnostics remain on
stderr even when ordinary logs are suppressed. Storeindex forwards bounded
extractor diagnostics at TRACE when started with `-vv`.

## Processor operation

`--processor` initializes and sends a MessagePack readiness response, then waits
for sequential requests. It cannot be combined with `--input`, `--output`, or
`--report`. Requests contain binary `input` with unchanged LENI bytes. Successful
responses contain binary `output` with the complete selected-field JSON object.
Selection remains fixed for the process lifetime.

A rejected input produces `error: 1` and a UTF-8 report. The next request may
succeed. Unexpected failures terminate the worker. Closing stdin between requests
ends it cleanly. stdout is reserved for protocol messages.

`--processor --once` sends readiness, handles one call, responds with `close: true`,
and exits zero. A host accepts that result only after clean stdout EOF and exit
zero. It can create a replacement process for the next call.

For Storeindex, put `--processor` and optionally `--once` directly in the
configured command together with the required `--field` selection. A direct CLI
invocation uses `--input` instead and adds no outer MessagePack envelope.

Output files are replaced only for a successful present output. Reports are
written on success or rejection when present. Empty reports create empty files;
absent reports leave files unchanged. Output and report destinations must differ.
Each file is replaced atomically, but the pair is not one transaction.
