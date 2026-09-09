[back to overview](overview.md)
---

# Quickstart

Install wiki2config and a processor implementing its process interface, such as
[wiki2user](https://github.com/leni-lab/wiki2user) 26.09.16 or later. An older
wiki2user executable with watch and archive options does not implement this
interface.

For an EXE installation, extract the application package and copy
[wiki2config.example.ini](wiki2config.example.ini) to `wiki2config.ini`
beside the executable. Use `--config PATH` to select a settings file elsewhere.
Set the input entry file, namespace, and processor executable:

```ini
[input]
file = ../wikiread/output/config/users.wiki
namespace = Config

[processor]
path = ../wiki2config-usermgr/dist/wiki2user.exe
```

Use the actual installed executable name. The current usermgr processor builds
`wiki2user.exe`, even when its checkout directory is named
`wiki2config-usermgr`. Adjust the copied example's processor path accordingly.

Convert old `* include:` directives to `# include:` and put them at the start of
every page. Only blank lines may precede or separate these directives. Move
`__NOTOC__`, comments, and prose below them. See [includes](includes.md).

Choose a dedicated active output directory containing generated INI files only,
apart from its optional `.git` directory. Move pre-existing report or legacy
archive directories elsewhere before using that output directory. wiki2config
does not move or migrate those directories automatically.

Validate with the actual processor, without activation, reports, or Git:

```text
wiki2config --check
```

Run one complete import, or observe future input changes:

```text
wiki2config
wiki2config --watch
```

Inspect `output/ini` and `output/reports`. Reports contain processor messages,
resolved source references, file changes, and activation or archive status. See
[settings](settings.md) and [operation](operation.md).
