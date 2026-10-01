[back to overview](overview.md)
---

# Command line and lifecycle

```text
wiki2profile-csv [--config PATH] [--check]
    [--set SECTION:KEY=VALUE] [-v | -q]
```

| option | purpose |
| ------ | ------- |
| `-c`, `--config PATH` | application INI file |
| `-s`, `--set SECTION:KEY=VALUE` | override a setting, repeatable |
| `--check` | validate Wiki input and render CSV without publication |
| `-v`, `--verbose` | increase logging verbosity, repeatable |
| `-q`, `--quiet` | decrease logging verbosity, repeatable |
| `-h`, `--help` | show command help |
| `-V`, `--version` | show version and build information |

`python -m wiki2profile-csv` and `python -m wiki2profile_csv` are equivalent.
Python execution defaults to
`wiki2profile-csv.ini` in the startup working directory. A packaged executable
defaults to an INI beside that executable with the same base name. Application
paths in the INI are relative to its directory; logfile paths use the program
directory. See [settings](settings.md).

Quote overrides for section names containing spaces:

```text
wiki2profile-csv --set "export profildienste:date=2024-04-15"
wiki2profile-csv --check --set "export profildienste:output_path=review/csv"
```

## Execution

All named export settings and directory relationships are validated before
any job starts. Jobs then run sequentially in INI order. An expected input or
publication failure is logged with the job name, does not skip later jobs,
and makes the invocation fail. An unexpected exception stops execution.

Only each configured Wiki entry page and its includes participate. Input uses
local mirrored pages, without accessing a Wiki server. Wiki errors identify
source pages, lines, and relevant field provenance.

`--check` assembles input, resolves fields, and renders the complete CSV bytes.
It does not create output directories or inspect output files for publication
conflicts or writability. Configured logging remains active.

Use an external scheduler for recurring execution. There is no watch mode.
The evaluation month and the preceding three months are calculated in full.
For example, `date=2024-04-15` exports January through April, including
subscription days after April 15. Input files need not change between runs.

Prevent overlapping processes against the same output directory. Files without
newly generated rows remain untouched, including files inside the export
window. A publication failure may leave a partially updated set of months.
See [file retention](wiki-format.md#file-retention).

## Shutdown and status

Toolkit handles Ctrl+C, termination signals, changes to the application INI,
and an optional `[app] max_runtime`. These request cooperative shutdown.
The current input/render phase finishes, then skips publication if stopped.
Once publication starts, it finishes the current job before stopping, unless
writing fails. Remaining jobs are skipped. Blocking I/O can delay shutdown
beyond the configured limit. The application does not restart itself.

Exit status 0 means normal completion or cooperative shutdown on a settings
change or runtime limit. It does not guarantee that every job was completed;
inspect the per-job log messages. Processing failures produce status 1,
invalid invocation or settings status 2, and Ctrl+C status 130. A failed job
remains a failure even if a later job succeeds or a cooperative stop occurs.

The application runs independently of wiki2config and does not accept its
processor protocol.
