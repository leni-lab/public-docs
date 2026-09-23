[back to overview](overview.md)
---

# Command line

```text
leniextract --field <name> [--field <name>] [--input <path|->] [--output <path>]
leniextract --session --field <name> [--field <name>]
```

| option            | meaning                                                 |
| ----------------- | ------------------------------------------------------- |
| `--field`         | required field names, fixed for the process lifetime    |
| `--input`         | UTF-8 JSON file, or `-` for stdin; omit for information |
| `--output`        | write the once result to a file instead of stdout       |
| `--session`       | framed stdin/stdout session; no input/output options    |
| `-V`, `--version` | print version and build information                     |
| `-h`, `--help`    | print usage                                             |
| `-v`, `--verbose` | show debug diagnostics, repeat for TRACE timings        |
| `-q`, `--quiet`   | reduce diagnostics, repeat four times to silence logs   |

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

With input, success writes exactly one JSON object to stdout or `--output`.
Without input, the command validates arguments and returns information text.
It does not read stdin and always exits after the once request. A missing or null
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
input based on exit code `1` or `2`.


## Processing timings

Add `-vv` to emit a processing-duration line on stderr. Verbose options and
`-q` cannot be combined. Successful requests have no diagnostics by default.
Unexpected worker failures include a traceback. Failure diagnostics remain on
stderr even when ordinary logs are suppressed. Storeindex forwards bounded
extractor diagnostics at TRACE when started with `-vv`.

## Processor modes

Once is the default and supports file/stdin input with raw JSON output. Every
invocation validates all CLI arguments. For a startup check, omit `--input`:
the response is free text suitable for the caller's log, followed by exit 0.
An empty input file is a data request and is rejected as invalid LENI JSON.

`--session` validates arguments and sends an implicit information response using
`toolkit.processor/2`, then waits for framed requests. `--input` and `--output`
are errors in this mode. Request payloads are unchanged LENI bytes, without an
application parameter line. Result payloads are complete selected-field JSON
objects. Field selection stays fixed across the session. Per-request arguments
are reserved for future extension.

An information request has `size: null`; empty data has `size: 0`. A nonfatal
source rejection leaves the session usable. Fatal errors end it. Closing stdin
between requests ends the session cleanly. stdout contains only frames.

For Storeindex, configure `mode = once` or `mode = session` and the command with
its `--field` arguments. Toolkit supplies the transport arguments.
