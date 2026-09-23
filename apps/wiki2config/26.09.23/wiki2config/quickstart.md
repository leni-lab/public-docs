[back to overview](overview.md)
---

# Quickstart

Install wiki2config and a domain processor implementing the shared
[processor interface](submodules/configflow/docs/wiki-processor.md).

For an EXE installation, extract the application package and copy
[wiki2config.example.ini](wiki2config.example.ini) to `wiki2config.ini`
beside the executable. Use `--config PATH` to select a settings file elsewhere.
Set the input entry file, namespace, and processor executable:

```ini
[convert]
input_path = ../wikiread/output/config
namespace = Config
output_path = output/config/${name}
report_path = output/reports/${name}

[convert usermgr]
.parent = convert
input_file = users.wiki
processor = ../wiki2config-usermgr/dist/wiki2config-usermgr.exe
```

Adjust the processor path to the installed `wiki2config-usermgr.exe`.

Put `* /include:` directives at the start of every page. Only blank lines may
precede or separate these directives. Place `__NOTOC__`, comments, and prose
below them. See [includes](includes.md).

Choose a dedicated active output directory containing generated INI files only,
apart from its optional `.git` directory. Keep reports and other archives in
separate directories.

Validate with the actual processor, without activation, reports, or Git:

```text
wiki2config --check
```

Run every configured job once, or observe future input changes:

```text
wiki2config
wiki2config --watch
```

Inspect `output/config/usermgr` and `output/reports/usermgr`. Reports name their
job and contain processor messages,
resolved source references, file changes, and activation or archive status. See
[settings](settings.md) and [operation](operation.md).
