[back to overview](overview.md)
---

# Settings

Start with [wiki2config.example.ini](wiki2config.example.ini). Application
paths use the directory containing the selected INI settings file. `input_file`
is resolved within `input_path`. Logfile paths have a separate base, described
under [logging](#logging). See [CLI](cli.md) for selection and overrides.

## Conversion jobs

Each `[convert <name>]` section defines one job. At least one is required.
`[convert]` provides defaults only and is never executed. Inheritance is
explicit, and a job's own values replace inherited values:

```ini
[convert]
input_path      = ../wikiread/output/config
namespace       = Config
use_git         = no
timeout         = 1min
output_path     = output/config/${name}
report_path     = output/reports/${name}
args            = --verbose

[convert usermgr]
.parent         = convert
processor       = ../wiki2config-usermgr/dist/wiki2user.exe
input_file      = users.wiki

[convert usermgr-test]
.parent         = convert usermgr
input_file      = users-test.wiki
args            =
```

`${name}` resolves to the job name when reading each subsection, including
inherited values. Here each job gets its own output and report directory.
Do not set a `name` key, the section name identifies the job. Job names must be
nonempty, have no surrounding whitespace, and contain no control characters,
colons, brackets, or path separators.

| key           | default                  | meaning                                                |
| ------------- | ------------------------ | ------------------------------------------------------ |
| `input_path`  | required                 | existing directory containing Wiki input               |
| `input_file`  | required                 | `.wiki` entry file directly in `input_path`            |
| `namespace`   | required                 | allowed Wiki namespace, case-insensitive               |
| `processor`   | required                 | existing executable, resolved before invocation        |
| `args`        | empty                    | arguments separated by whitespace, with double quoting |
| `timeout`     | `1min`                   | maximum runtime of each processor invocation           |
| `output_path` | `output/config/${name}`  | dedicated active INI directory                         |
| `report_path` | `output/reports/${name}` | Markdown report directory                              |
| `use_git`     | `no`                     | archive this job after activation                      |

The entry file may be temporarily absent at startup. The input directory and
processor executable must exist. All jobs are validated before any starts.
Unknown application keys are ignored, while known values are validated.
Shared runtime and logging sections use their own validation rules.

Jobs can share input directories and report directories. Output and work
directories must not overlap each other or any job's input or report directory.
Reports must not overlap input directories. Identical or nested output paths
are rejected even if jobs run sequentially, because each owns its entire set.
The reserved work directory is the fixed sibling
`.<output-name>.wiki2config-work`, for example
`output/config/.usermgr.wiki2config-work`. Work and active output must use the
same filesystem. Keep all processor executables outside output and work roots.

The previous `[input]`, `[processor]`, `[output]`, and `[reports]` layout is no
longer supported. Move their settings into named conversion sections.

## Processor arguments

`processor` names an existing executable, not a command to look up on PATH.
Do not quote the executable path. Configured arguments are followed by
`--output` and an absolute empty working directory. Do not configure `--output`
yourself. No shell command string is evaluated.

These forms supply the same arguments:

```ini
args            = --verbose --mode test --label "Test configuration"
```

```ini
args            =
    --verbose
    --mode test
    --label "Test configuration"
```

Continuation lines must be indented. Spaces, tabs, and line breaks outside
double quotes separate arguments. Double quotes group text and are removed.
Backslashes are always literal, so `"C:\Program Files\Tool\"` preserves its
trailing backslash. Inside quoted text, double a double quote to include one:
`"say ""hello"""` supplies `say "hello"`. Single quotes are literal. `""` supplies
an empty argument, while an empty `args =` supplies no arguments.
Unclosed quotes and NUL characters are errors.

A job's `args` replaces the entire inherited value, and `args =` clears it.
There is no shell expansion, wildcard expansion, or argument path expansion.
INI interpolation such as `${name}` still applies before argument parsing.
Unlike the old one-argument-per-line format, arguments containing spaces must
now be quoted. For a development installation:

```ini
[convert usermgr]
.parent         = convert
input_file      = users.wiki
processor       = ../wiki2config-usermgr/.venv/Scripts/python.exe
args            = -m wiki2user
```

The checkout directory name does not determine the Python module name. The
current usermgr processor uses `wiki2user` for `-m` and builds `wiki2user.exe`.
Adjust the processor path to the installed executable's actual name.
Use absolute paths for script arguments. The child working directory is inside
the attempt workspace, never the active directory.

## Watch settings

`[watch]` applies to all jobs, with independent observation and retry state.

| key           | default | meaning                             |
| ------------- | ------- | ----------------------------------- |
| `poll`        | `1min`  | input observation interval          |
| `backoff`     | `10s`   | initial transient-error retry delay |
| `backoff_max` | `5min`  | maximum retry delay                 |

Timeouts and intervals must be at least one second. `backoff` cannot exceed
`backoff_max`. The example overrides `poll` to `30s`.

## Optional Git archive

Set `use_git = yes` in `[convert]` or an individual job and supply a shared
commit identity:

```ini
[git]
path            = ../mingit/cmd/git.exe
name            = Configuration Import
email           = configuration@example.org
timeout         = 30s
trust_directory = no
```

| key               | default                 | meaning                                         |
| ----------------- | ----------------------- | ----------------------------------------------- |
| `path`            | `../mingit/cmd/git.exe` | Git executable                                  |
| `name`, `email`   | empty                   | commit identity, required if any job uses Git   |
| `timeout`         | `30s`                   | limit for each Git command, at least one second |
| `trust_directory` | `no`                    | trust archives despite different ownership      |

There is no `[git] enabled` switch. Unknown Git keys are errors even if all
jobs disable Git. Shared Git settings are loaded once. Each enabled job owns
an archive in its output directory, on branch `main`. No remote or automatic
push is configured.

`trust_directory` explicitly permits archive directories to have different
owners for these Git invocations only. It changes no global Git configuration
and does not grant filesystem permissions.

## Runtime

`[app] max_runtime` optionally limits the entire invocation, including watch
mode. Empty or omitted means no runtime limit. For a regular restart managed
by a supervisor:

```ini
[app]
max_runtime     = 8h
```

This is separate from `[convert <name>] timeout`, which limits each processor run.
Settings changes also stop a running invocation. wiki2config does not restart
itself. Temporary overrides use the normal CLI syntax, for example
`wiki2config --watch --set app:max_runtime=30min`.

## Logging

The example configures console and redirected output with an `INFO` handler
floor and enables `wiki2config.log` with a `DEBUG` floor. Normal runs show
`INFO` and above in all three handlers. With `-v`, the file also receives
`DEBUG`, while console and redirected output stay at `INFO`.

`-v` enables `DEBUG`, `-vv` enables `TRACE`, and `-q` restricts output to
`WARNING` and above. Each handler's `log_level` adds a restriction. Set a
handler to `TRACE` to let both verbosity flags take full effect, for example:

```text
wiki2config -v --set "logging console:log_level=TRACE" --set "logging pipe:log_level=TRACE"
```

| section           | key           | purpose                                          |
| ----------------- | ------------- | ------------------------------------------------ |
| `logging console` | `log_level`   | level floor for interactive stdout               |
| `logging console` | `color_mode`  | `auto`, `always`, or `never`                     |
| `logging pipe`    | `log_level`   | level floor when stdout is redirected            |
| `logging file`    | `log_file`    | optional log path, empty disables file output    |
| `logging file`    | `log_level`   | level floor for the logfile                      |
| `logging file`    | `format`      | Python logging format, percent signs are literal |
| `logging file`    | `date_format` | timestamp format for `%(asctime)s`               |
| `logging file`    | `encoding`    | file encoding, default `utf-8`                   |

Redirected output uses the pipe handler instead of the console handler. Its
fixed numeric level prefix is intended for process supervision. Console
messages and file logs are separate from the Markdown import reports.

File logging is disabled when `log_file` is empty or omitted. The example
enables it. To select an absolute path and allow trace diagnostics with `-vv`,
use an existing log directory:

```ini
[logging file]
log_file        = C:/logs/wiki2config.log
log_level       = TRACE
format          = [%(asctime)s] %(levelname)-7s - %(name)s - %(message)s
date_format     = %Y-%m-%d %H:%M:%S
encoding        = utf-8
```

Relative log paths use the program directory, not the selected INI file's
directory. An absolute path avoids that difference between development and
EXE installations. File logging has no automatic rotation. Arrange retention
separately and keep logs outside the active output directory.

Optional `[logging]` entries restrict individual loggers. For example,
`/asyncio = WARNING` uses an absolute logger name. Keys without the leading
slash are relative to the application name. These restrictions cannot lower
the CLI or handler floor.
