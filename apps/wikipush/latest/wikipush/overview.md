# Overview

wikipush publishes local Wikitext files as MediaWiki pages. It is intended for
manually controlled migration runs.

## Behavior

- one run per invocation, with an optional `--dry-run` preview
- one direct input directory per configured target namespace
- create missing pages and replace existing page content completely
- skip unchanged content, accounting for trailing whitespace removed by the Wiki
- optionally detect existing titles that differ only in capitalization
- retain Wiki pages when local files are removed or renamed

The local files are authoritative. Edits made directly in the Wiki are
overwritten when the corresponding local content differs.

## Input

The default example maps `input/config/*.wiki` to the `config` namespace and
`input/dist/*.wiki` to the `dist` namespace. Files contain UTF-8 Wikitext without
a byte order mark. Filenames follow the lowercase, Windows-safe rules used by
wikiread. File contents may contain Unicode.

## Requirements

- installed `wikipush` command or Windows executable
- reachable MediaWiki API and credentials with read, edit, and create access
- existing input root and configured group directories

## Boundaries

Files are prepared before writing, but a run is not a multi-page transaction.
An error while writing stops the run and retains earlier successful changes.
Review the log and rerun after resolving the error.

wikipush does not upload attachments, convert Markdown, follow redirects, delete
pages, move pages, or monitor directories continuously. A redirect at the exact
destination is replaced like any other page.

Start with [quickstart](quickstart.md), then see [settings](settings.md) and
[CLI](cli.md).
