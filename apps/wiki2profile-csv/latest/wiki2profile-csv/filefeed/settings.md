[back to overview](../overview.md)
---

# Filefeed settings

Pass one INI section as the options dictionary to `FileFeed`. Additional
keys are ignored, following the shared [field contract](https://github.com/leni-lab/py-cli-toolkit/blob/main/fields/README.md#configuration-keys).
`on_idle` is a Python constructor argument.

| key                  | default           | meaning                                                    |
| -------------------- | ----------------- | ---------------------------------------------------------- |
| `name`               | empty             | logging context                                            |
| `inbox`              | required          | existing input directory                                   |
| `work`               | `${inbox}/work`   | the active or waiting file                                 |
| `done`               | `${inbox}/done`   | successfully consumed files                                |
| `fail`               | `${inbox}/fail`   | permanently failed files                                   |
| `review`             | `${inbox}/review` | files needing inspection after unexpected errors           |
| `match`              | `*`               | inbox filename selection                                   |
| `poll`               | `1s`              | input and admission retry interval, minimum `1s`           |
| `claim_lock`         | `true`            | probe exclusive access before claiming                     |
| `claim_stable`       | `2s`              | unchanged size and mtime duration, `0s` disables           |
| `claim_first_stable` | `${claim_stable}` | stability required at startup and after idle               |
| `claim_warn_after`   | `1min`            | blocked-head warning threshold and interval, `0s` disables |
| `retries`            | `3`               | additional attempts after transient failures               |
| `backoff`            | `1s`              | initial failure retry delay, minimum `1s`                  |
| `backoff_max`        | `15s`             | maximum exponential retry delay, minimum `1s`              |
| `work_timeout`       | `60min`           | per-attempt timeout, minimum `1s`                          |
| `done_expire`        | `0s`              | deletion age based on mtime, `0s` disables                 |

`claim_first_stable` must be at least `claim_stable`. `backoff` must not exceed
`backoff_max`. Stability and retry waits use monotonic elapsed time.

Working directories are created as needed. They must not overlap each other or
contain the inbox. Keep all directories on the same filesystem. A single process
must own them. `match` does not exclude already claimed work.

Expiration runs between processing attempts and during idle, at most once per
minute. It does not measure time since arrival in `done`. Files with old source
mtime can expire immediately after successful processing.

See [value syntax](https://github.com/leni-lab/py-cli-toolkit/blob/main/fields/syntax.md) for durations and filename matchers.
