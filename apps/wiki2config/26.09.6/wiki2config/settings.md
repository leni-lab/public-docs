[back to overview](overview.md)
---

# Settings

Start with [wiki2config.example.ini](wiki2config.example.ini). Application
paths use the directory containing the selected INI settings file. Logfile
paths have a separate base, described under [logging](#logging).
See [CLI](cli.md) for file selection and command-line overrides.

| section     | key           | default          | meaning                                       |
| ----------- | ------------- | ---------------- | --------------------------------------------- |
| `input`     | `file`        | required         | explicit local `.wiki` entry file             |
| `input`     | `namespace`   | required         | allowed Wiki namespace, case-insensitive      |
| `processor` | `path`        | required         | executable path, resolved before invocation   |
| `processor` | `args`        | empty            | one complete argument per physical value line |
| `processor` | `timeout`     | `5min`           | maximum processor runtime                     |
| `output`    | `path`        | `output/ini`     | dedicated active INI directory                |
| `reports`   | `path`        | `output/reports` | independent Markdown report directory         |
| `watch`     | `poll`        | `1min`           | input observation interval                    |
| `watch`     | `backoff`     | `10s`            | initial transient-error retry delay           |
| `watch`     | `backoff_max` | `5min`           | maximum retry delay                           |

Timeouts and intervals must be at least one second. `backoff` cannot exceed
`backoff_max`. Unknown application keys are ignored. Known values and required
paths are still validated. Unknown keys in `[git]` are errors, including when
archival is disabled. Shared runtime and logging sections use their own
validation rules.

Input, output, reports, and work directories must not overlap. The working
directory is the fixed sibling `.<output-name>.wiki2config-work`, for example
`output/.ini.wiki2config-work`. Reserve it for this application. Work and active
output must use the same filesystem.

## Processor arguments

`path` names an existing executable, not a command to look up on PATH. No shell
command string is evaluated. The executable receives configured arguments
followed by `--output` and an absolute empty working directory. Do not configure
`--output` yourself. One argument per line avoids ambiguity with Windows
backslashes and spaces. Do not add shell quotes around an argument or executable
path. Leading and trailing argument whitespace is removed, and blank lines
supply no argument. For a development installation:

```ini
[processor]
path = ../wiki2config-usermgr/.venv/Scripts/python.exe
args =
    -m
    wiki2user
```

The checkout directory name does not determine the Python module name. The
current usermgr processor uses `wiki2user` for `-m` and builds `wiki2user.exe`.
Adjust the copied example to the installed processor's actual names.

Relative arguments belong to the processor and are not path-expanded by
wiki2config. Use absolute paths for script arguments. The child working
directory is inside the attempt workspace, never the active directory.

## Optional Git archive

```ini
[git]
enabled = yes
path = ../mingit/cmd/git.exe
name = Configuration Import
email = configuration@example.org
timeout = 30s
trust_directory = yes
```

| key               | default                 | meaning                                         |
| ----------------- | ----------------------- | ----------------------------------------------- |
| `enabled`         | `no`                    | archive after activation                        |
| `path`            | `../mingit/cmd/git.exe` | Git executable                                  |
| `name`, `email`   | empty                   | commit identity, required when enabled          |
| `timeout`         | `30s`                   | limit for each Git command, at least one second |
| `trust_directory` | `no`                    | trust this archive despite different ownership  |

Disabled archival is the default. Name and email are required when enabled.
`trust_directory` explicitly permits the archive directory to have a different
owner for these Git invocations only. It changes no global Git configuration and
does not grant filesystem permissions. The repository is initialized and
maintained through toolkit's application-owned archive, on branch `main`. No
remote or automatic push is configured.

## Runtime

`[app] max_runtime` optionally limits the entire invocation, including watch
mode. Empty or omitted means no runtime limit. For a regular restart managed
by a supervisor:

```ini
[app]
max_runtime = 8h
```

This is separate from `[processor] timeout`, which limits each processor run.
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
log_file = C:/logs/wiki2config.log
log_level = TRACE
format = [%(asctime)s] %(levelname)-7s - %(name)s - %(message)s
date_format = %Y-%m-%d %H:%M:%S
encoding = utf-8
```

Relative log paths use the program directory, not the selected INI file's
directory. An absolute path avoids that difference between development and
EXE installations. File logging has no automatic rotation. Arrange retention
separately and keep logs outside the active output directory.

Optional `[logging]` entries restrict individual loggers. For example,
`/asyncio = WARNING` uses an absolute logger name. Keys without the leading
slash are relative to the application name. These restrictions cannot lower
the CLI or handler floor.
