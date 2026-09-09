[back to overview](overview.md)
---

# Installation and configuration

## Install the renderer

Requires Python 3.13 or newer and configflow 0.2. Install a renderer wheel into
a Python environment where the required dependencies are available:

```powershell
python -m venv .venv
.\.venv\Scripts\python.exe -m pip install "C:/packages/configflow-<version>-py3-none-any.whl"
.\.venv\Scripts\python.exe -m pip install "C:/packages/configview_usermgr-<version>-py3-none-any.whl"
.\.venv\Scripts\configview-usermgr.exe --help
```

Replace the example wheel paths and `<version>` with the supplied distributions. The package
installs Click and Jinja2 if they are not already available. Keep the Python
environment intact: its Windows console launcher is not a standalone EXE. On
Linux, the command is `.venv/bin/configview-usermgr`.

A configview source checkout can instead supply its existing Python environment
and pinned configflow installation. Install this renderer source checkout into
that environment with `python -m pip install <renderer-path>`, using that
environment's Python executable.

## Configure configview

The renderer has no settings file of its own. Set its executable path in
`configview.ini` and declare all three files in each configuration:

```ini
[format usermgr]
renderer = C:/apps/configview-usermgr/.venv/Scripts/configview-usermgr.exe
timeout  = 30s

[config usermgr test]
path  = C:/data/usermgr
files = users.wiki.ini, groups.wiki.ini, permissions.wiki.ini
```

For a complete configuration with Git, server, runtime, and logging examples,
use [configview.example.ini](https://github.com/leni-lab/configview/blob/main/configview.example.ini).
See [settings.md](https://github.com/leni-lab/configview/blob/main/user-docs/settings.md)
for the full settings reference. Logging sections belong to configview and do
not configure the renderer's stderr diagnostics.

Adjust both paths to the installed environment and configuration directory.
configview resolves relative paths against its settings file's directory. A bare
command name can be used when the renderer is on the service's PATH. Do not
append command-line arguments to the `renderer` setting.

| position | input       | sections              |
| -------- | ----------- | --------------------- |
| 1        | users       | `[user <name>]`       |
| 2        | groups      | `[group <name>]`      |
| 3        | permissions | `[permission <name>]` |

The order is required. Filenames may differ, but their basenames must be
distinct. Every version must contain the complete set. No local account files,
reports, includes, or other files are loaded. Each input is limited to 8 MiB.
Configurations may share a directory and Git repository while selecting
different filenames.

CSS and JavaScript are embedded in the HTML output. No asset export or
additional asset configuration is needed. configview embeds the trusted renderer
output and permits its inline styles and scripts. Configuration values are
escaped by the renderer.

## Command and diagnostics

```text
configview-usermgr <users-file> <groups-file> <permissions-file>
```

The command writes a UTF-8 HTML fragment to stdout and diagnostics to stderr. It
does not write the inputs. configview passes private copies of the selected
version and applies its configured process timeout.

A nonzero exit code indicates invalid input or a failed render. Syntax or domain
errors prevent a partial interpreted view. Invalid optional metadata is reported
separately. Check the file order, complete file set, and reported source
location when diagnosing an error. configview retains the file summary and
original INI links when the renderer fails.

See the [user overview](overview.md) for browsing and interpretation.
