[back to overview](overview.md)
---

# troubleshooting

common operator problems and fast fixes.

## diagnostic order

- validate section-name mapping first: `[input <name>]`, `[transfer <name>]`, and
	referenced `[sftp <name>]`
- run host-key diagnostics next: `sftpbeam --check <name>`
- inspect transfer bounds and retry controls: `transfer_timeout`, `retries`,
	`backoff`, `backoff_max`
- inspect file routing state: `retry/`, `fail/`, `review/` and current app logs

## check mode argument errors

symptom:

- `NAME requires --check`
- `--accept-new-key and --remove-key require --check NAME`

cause:

- invalid option combination in check mode

fix:

- valid forms:

```bash
sftpbeam --check
sftpbeam --check <name>
sftpbeam --check <name> --accept-new-key
sftpbeam --check <name> --remove-key
```

## host key mismatch

symptom:

- `error: host key mismatch for <host>`

cause:

- server key changed
- wrong host or wrong known_hosts entry

fix:

- verify host and port in `[sftp <name>]`
- rotate key entry explicitly:

```bash
sftpbeam --check <name> --remove-key
sftpbeam --check <name> --accept-new-key
```

## missing sftp section in check mode

symptom:

- `no [sftp <name>] sections`
- `[sftp <name>] missing`

cause:

- config has no named sftp section
- passed `<name>` does not exist in config

fix:

- define at least one `[sftp <name>]`
- use the exact section suffix as check name

## transfer timeout

symptom:

- `transfer timeout: <file>`

cause:

- network path is slow or blocked
- `transfer_timeout` too low for current file sizes

fix:

- test connectivity to sftp target
- increase `transfer_timeout` in `[transfer]` or `[transfer <name>]`
- verify retry settings: `retries`, `backoff`, `backoff_max`

## files stay in retry or move to review

symptom:

- files remain in `retry`
- files move to `review`

cause:

- transient errors continue, retries not exhausted yet
- unexpected processor error routed to manual review

fix:

- inspect app log file for root cause
- verify credentials, remote path, and permissions
- check retry timing and attempt limits in `settings.md`
- after fix, reprocess files from `retry` or `review`

## no files picked from inbox

symptom:

- app runs, but no file is claimed

cause:

- `match` excludes files
- producer writes non-atomically and files stay unstable/locked
- wrong pipeline name started

fix:

- start with permissive matcher: `match = *`
- verify producer contract (atomic rename or producer-held lock)
- confirm you run the intended pipeline name

## see also

- [overview.md](overview.md)
- [quickstart.md](quickstart.md)
- [cli.md](cli.md)
- [settings.md](settings.md)
- [config/syntax.md](config/syntax.md)
