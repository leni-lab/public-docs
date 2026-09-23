[back to overview](overview.md)
---

# Application settings

Start with [wiki2profile-csv.example.ini](wiki2profile-csv.example.ini).
The local `wiki2profile-csv.ini` is ignored by Git. These are application
settings; the fixed CSV schema and subscription fields are described in the
[Wiki format reference](wiki-format.md).

## Export jobs

Each `[export <name>]` section defines one job. At least one is required.
`[export]` holds optional shared defaults and is never executed. Inheritance
uses the toolkit `.parent` setting explicitly:

```ini
[export]
input_path = ../wikiread/output/config
namespace = Config
output_path = output/csv/${name}
date =

[export profildienste]
.parent = export
input_file = profildienste.wiki

[export review]
.parent = export profildienste
date = 2024-04-15
```

`${name}` resolves to each job name, including in inherited values. Jobs keep
INI order. The section name identifies the job; no `name` field is needed.
Names must be nonempty, without surrounding whitespace, control characters,
colons, brackets, or path separators. Unknown application keys are ignored;
consumed values are validated.

| key | default | meaning |
| --- | ------- | ------- |
| `input_path` | required | existing directory of mirrored Wiki pages |
| `input_file` | required | relative `.wiki` entry filename directly in `input_path` |
| `namespace` | `Config` | accepted Wiki include namespace |
| `output_path` | `output/csv/<job name>` | root of `<csv-name>/<YYYY-MM>.csv` output |
| `date` | empty | evaluation date as `YYYY-MM-DD`, empty means today in Berlin |

`input_path` and `output_path` are relative to the selected INI file, unless
absolute. `input_file` is relative to `input_path`. The entry may be temporarily
missing at startup; its job then reports a read failure while other jobs can
still run. Input directories must exist. Output directories are created only
when publishing files. A filesystem root cannot be an output directory.

Jobs may share input directories. Output directories must not overlap each
other or any job's input directory. Publication rejects linked output paths.
Output files and archive-retention behavior are unchanged by job names.

If `date` is empty, the application takes today's date in `Europe/Berlin`
once at the start of the invocation for all jobs using that default. Dates
before `0001-04-01` are invalid because the four-month window would extend
before year 1. The date controls evaluation, not scheduling.

## Logging and runtime

Logging uses the same toolkit sections as wiki2config:

```ini
[logging console]
log_level = INFO
color_mode = auto

[logging pipe]
log_level = INFO

[logging file]
log_file = wiki2profile-csv.log
log_level = DEBUG

[app]
max_runtime = 10min
```

`[app] max_runtime` is optional and must include units. It limits the whole
invocation, including all jobs. Empty or omitted means unlimited runtime.
Changes to the INI request shutdown. See [lifecycle](cli.md#shutdown-and-status).

Relative log paths use the startup working directory for Python execution,
or the executable directory for a packaged application. An empty `log_file`
disables file logging. Create a custom log parent directory before use.
`-v` enables DEBUG detail where handler floors permit it; `-q` reduces output.
The example keeps console and redirected output at INFO and allows DEBUG in
the logfile. See the [toolkit logging reference](logs/settings.md).
