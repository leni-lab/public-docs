[back to overview](../overview.md)
---

# filemill settings

all keys belong to a single INI section passed to `FileMill()`.

## directories

| key | default | notes |
| --- | --- | --- |
| `inbox` | *(required)* | input directory; scanner picks up files here |
| `work` | `${inbox}/work` | files are atomically moved here while being processed |
| `done` | `${inbox}/done` | files moved here on success |
| `fail` | `${inbox}/fail` | files moved here on permanent failure (`ProcessingError`) |
| `retry` | `${inbox}/retry` | files moved here on transient failure; filename encodes state |
| `review` | `${inbox}/review` | unexpected errors requiring manual inspection |

directories other than `inbox` are created automatically if absent.

inbox producer contract (normative):

- producer must publish files either via atomic rename or producer-held lock
- producer should prefer atomic rename
- consumer guardrails are a safety net, not a replacement for producer contract

filemill treats visible files as claim candidates and applies optional guardrails
before claim.

## processing

| key | default | constraints | notes |
| --- | --- | --- | --- |
| `poll` | `1s` | min `1s` | interval between inbox scans |
| `queue_size` | `200` | min `1` | max number of queued files |
| `workers` | `1` | min `1` | number of parallel worker tasks |
| `retries` | `3` | min `0` | max retry attempts per file; `0` disables retry |
| `backoff` | `1s` | min `1s` | initial retry delay; doubles on each attempt |
| `backoff_max` | `15s` | min `1s` | upper bound for exponential backoff |
| `work_timeout` | `60min` | min `1s` | max time a processor may run before the file is retried |
| `done_max_age` | `0` | min `0s` | max age of files in `done/` before deletion; `0` disables |
| `pre_claim_lock` | `true` | bool | pre-check lock state before claim and skip locked files |
| `pre_claim_stable` | `2s` | min `0s` | require mtime stability before claim; `0s` disables |
| `pre_claim_timeout` | `1min` | min `0s` | warn if pre-claim blocking persists; `0s` disables warnings |
| `match` | empty | matcher | glob pattern filter for inbox filenames; empty matches all |

`backoff` must not exceed `backoff_max`.

`match` applies only to inbox files; files already in `retry/` are not filtered.

time value policy:

- all internal time calculations use float seconds
- time values are rounded only at persistence boundaries (retry filename state)
- fractional retry delays are rounded up to preserve "not before" semantics

processing behavior summary:

- scanner checks `inbox/` and due entries in `retry/`
- workers claim files to `work/` before processing
- routing targets are `done/`, `fail/`, `retry/`, and `review/`
- leftover `work/` files are moved back to `retry/` at startup (crash recovery)
- processor timeout `work_timeout` cancels hung processors and schedules retry
- when `done_max_age > 0`, files in `done/` older than `done_max_age` are deleted at startup and every minute

for matcher and duration syntax see [syntax.md](../fields/syntax.md).
