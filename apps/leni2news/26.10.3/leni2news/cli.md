[back to overview](overview.md)
---

# Command line

```text
leni2news.exe [options]
```

The application processes the initial batch and exits. Use `--watch` for
continuous operation. Its default configuration is `leni2news.ini` beside the
executable.

| option            | value               | purpose                                                           |
| ----------------- | ------------------- | ----------------------------------------------------------------- |
| `-c`, `--config`  | path                | select another INI file                                           |
| `-s`, `--set`     | `SECTION:KEY=VALUE` | override a setting for this run, repeatable                       |
| `--watch`         | -                   | watch continuously for new files and retry temporary failures     |
| `--max-runtime`   | duration            | request a stop after this interval, overrides `[app] max_runtime` |
| `-v`, `--verbose` | -                   | increase logging, `-v` for debug and `-vv` for trace              |
| `-q`, `--quiet`   | -                   | decrease logging, repeatable                                      |
| `-V`, `--version` | -                   | show version and build information                                |
| `-h`, `--help`    | -                   | show help                                                         |

Verbose and quiet options cannot be combined. A runtime limit requests a
graceful stop. The active file must finish before its source is moved, so
shutdown can take longer when storage is slow or unavailable.

```text
leni2news.exe --config D:/jobs/leni2news.ini
leni2news.exe --watch
leni2news.exe --watch --max-runtime 30s --verbose
leni2news.exe --set input:claim_stable=2s
```

## One-time import

The application resumes an unfinished file in `work` first and captures the
initial matching input files. Later arrivals remain for another invocation.
There is one initial readiness window, using `claim_first_stable` (default
`2s`). All visible candidates are observed together. After a successful file,
uninterrupted processing uses `claim_stable` (default `1s`). A locked or
unstable head blocks later files. Subsequent blocking or a required retry ends
the one-time run. Claimed files awaiting retry remain in `work`.

Current/future source seconds, a busy store lock, or an ineligible store time
defer processing without consuming failed attempts. Watch retries after waiting
outside the store lock. Failure attempts and backoff deadlines are kept only in
memory and reset on restart. `claim_warn_after` controls blocked-input warnings,
not a deadline for discarding a file.

Filename corrections are warnings, not failures. Their allocation follows
the [store contract](https://github.com/leni-lab/store-contracts/blob/main/docs/news-store.md#regular-input-ordering).
Source archiving follows successful publication.

The final report counts selected, done, failed, review, deferred, skipped, and
pending files. Pending files were not attempted, for example because a prior
file blocked the sequence. Empty input succeeds. Startup verifies the loose
store anchor under the shared lock before claiming input.

## Exit codes

| code  | meaning                                                                                                  |
| ----- | -------------------------------------------------------------------------------------------------------- |
| `0`   | all selected files succeeded, or the watcher stopped normally                                            |
| `1`   | application startup or runtime failure, or a one-time import had unsuccessful files or was stopped early |
| `2`   | invalid invocation or configuration                                                                      |
| `130` | stopped by Ctrl+C                                                                                        |

In watch mode, expected processing failures do not change a normal exit code to
failure. Unexpected processor errors move the claimed file to `review` and stop
the run with full context. Runtime limits and configuration changes exit with
`0` in watch mode and `1` if a one-time import was stopped. Ctrl+C exits with
`130`. Inspect `work`, `fail`, and `review` during operation.
