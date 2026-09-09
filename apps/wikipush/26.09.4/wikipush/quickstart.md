[back to overview](overview.md)
---

# Quickstart

## Configure

Copy [wikipush.example.ini](wikipush.example.ini) to `wikipush.ini` and set the
MediaWiki API URL, username, and password. The account must be able to create
and edit pages in the selected namespaces.

Relative input paths are based on the configuration file directory. Relative
log paths are based on the working directory for Python or the EXE directory
for a Windows executable, even when `--config` selects another file. Keep the
local configuration out of version control.

For the Windows EXE, place `wikipush.ini` beside `wikipush.exe`, or select a
configuration explicitly with `--config`. The Python command searches the
working directory by default.

## Prepare files

Create the directories next to the configuration file:

```text
input/
  config/
    keywords.wiki
  dist/
    release_notes.wiki
```

Write complete Wikitext page content into each file using UTF-8 without a BOM.
Both configured directories must exist, even if one is empty.

The default mapping produces `Config:Keywords` and `Dist:Release notes` on a
Wiki using these namespace names and first-letter capitalization. wikipush
uses the actual names and capitalization rules reported by the target Wiki.

## Preview and publish

```powershell
wikipush --dry-run
wikipush
```

The preview authenticates and reads the Wiki, checks inputs and enabled name
conflict rules, and reports planned creations and updates. It does not edit
pages or guarantee that all writes will pass the Wiki's permission and content
checks later.

Run again after a successful upload to check that the content is unchanged:

```powershell
wikipush -v
```

The summary should report all selected pages as unchanged. With the example
configuration, per-page DEBUG messages appear in `wikipush.log`. See
[logging](settings.md#logging) to also show them on standard output.

If the input directories are directly beside `wikipush.ini`, set `[input]`
`path = .`. See [settings](settings.md) for the full reference and
[troubleshooting](troubleshooting.md) for failed or partial runs.
