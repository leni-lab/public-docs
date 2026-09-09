[back to overview](overview.md)
---

# CLI

```text
wikipush [options]
```

Each invocation performs one run and exits.

The default configuration is beside the Windows EXE, or in the working
directory when running through Python. `--config` selects another location.

## Options

| option            | value               | purpose                         |
| ----------------- | ------------------- | ------------------------------- |
| `-c`, `--config`   | `TEXT`              | config file, default `wikipush.ini` |
| `-s`, `--set`      | `SECTION:KEY=VALUE` | repeatable configuration override |
| `--dry-run`        | -                   | preview without editing pages   |
| `-v`, `--verbose`  | -                   | increase verbosity              |
| `-q`, `--quiet`    | -                   | decrease verbosity              |
| `-V`, `--version`  | -                   | version and build information   |
| `-h`, `--help`     | -                   | help                            |

`--verbose` and `--quiet` cannot be combined. `-v` permits DEBUG and `-vv`
permits TRACE. Each `-q` reduces output, from warnings through silence.
`--set` changes values only for that invocation.

## Examples

```powershell
wikipush --dry-run
wikipush
wikipush --config d:/migration/wikipush.ini --dry-run
wikipush --set push:check_case=true --dry-run
wikipush --set input:path=d:/migration/input
```

## Results

Per-file messages show planned or completed changes. Completed writes include
the revision ID. The final summary reports selected, created, updated, and
unchanged pages. In a dry run, creation and update counts describe the plan.

- exit `0`: run completed, including an empty selection
- exit `1`: operational or unexpected failure
- exit `2`: invalid invocation, configuration, input, or detected name conflict

A failed run can have completed earlier writes. See
[troubleshooting](troubleshooting.md).
