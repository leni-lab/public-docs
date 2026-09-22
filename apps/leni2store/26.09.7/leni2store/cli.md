[back to overview](overview.md)
---

# Command line

```text
leni2store.exe [options]
```

The application processes the initial batch and exits. Use `--watch` for
continuous operation. Its default configuration is `leni2store.ini` beside
the executable. Existing continuous deployments must add `--watch` to their
startup command.

| option | value | purpose |
| --- | --- | --- |
| `-c`, `--config` | path | select another INI file |
| `-s`, `--set` | `SECTION:KEY=VALUE` | override a setting for this run, repeatable |
| `--watch` | - | watch continuously for new files and retry temporary failures |
| `--max-runtime` | duration | request a stop after this interval, overrides `[app] max_runtime` |
| `-v`, `--verbose` | - | increase logging, `-v` for debug and `-vv` for trace |
| `-q`, `--quiet` | - | decrease logging, repeatable |
| `-V`, `--version` | - | show version and build information |
| `-h`, `--help` | - | show help |

Verbose and quiet options cannot be combined. A runtime limit requests a
graceful stop. An active copy must finish or fail before its source is moved,
so shutdown can take longer when storage is slow or unavailable.

```text
leni2store.exe --config D:/jobs/leni2store.ini
leni2store.exe --watch
leni2store.exe --watch --max-runtime 30s --verbose
leni2store.exe --set input:pre_claim_stable=2s
```

## One-time import

After recovering interrupted work, the application selects matching input
files and retries already due. Files arriving later and future retries remain
for a later run. Each selected file gets at most one processing attempt.
Temporary failures are scheduled in `retry` for a later run.

With `pre_claim_lock` enabled, files already locked are deferred immediately.
The remaining candidates are observed for one shared `pre_claim_stable`
window, default `1s`, then checked again for unchanged size and modification
time and for locks. Changed or locked files stay in place and are reported as
deferred. This observation window is never restarted. `pre_claim_stable=0s`
disables the observation wait. The run does not wait for locks to be released.
`pre_claim_timeout` remains a warning interval, not a stop deadline.

The final report counts selected files as done, failed, review, deferred,
skipped (disappeared before claiming), or pending (not attempted before a
stop). Future retries and later arrivals are outside this report. An empty
batch succeeds. Existing destination files count as done after their sources
are archived.

## Exit codes

| code | meaning |
| --- | --- |
| `0` | all selected files succeeded, or the watcher stopped normally |
| `1` | application startup or runtime failure, or a one-time import had unsuccessful files or was stopped early |
| `2` | invalid invocation or configuration |
| `130` | stopped by Ctrl+C |

In watch mode, individual file failures do not stop the watcher or change a
normal exit code to failure. A runtime limit or configuration change also
exits with `0` in watch mode. In a one-time import, an external stop exits
with `1`, even if active copies finish successfully. Ctrl+C exits with `130`
in either mode. Inspect `retry`, `fail`, and `review` as part of operation.
