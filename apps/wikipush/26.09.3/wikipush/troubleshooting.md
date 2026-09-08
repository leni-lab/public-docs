[back to overview](overview.md)
---

# Troubleshooting

## Configuration or input not found

Check the configuration filename and `[input] path`. Relative input paths are
resolved from the configuration directory. Create every directory listed in
`[pages]`, including empty groups.

## Filename or encoding rejected

Use lowercase, Windows-safe `.wiki` filenames and UTF-8 without a BOM. Keep
selected files directly in their group directory. See
[settings](settings.md#filename-mapping).

## Namespace not found

Use the target Wiki's namespace name or canonical alias in lowercase, without
the trailing colon. A page prefix does not define a namespace by itself.

## Case conflict or duplicate destination

Review the listed input paths and Wiki titles. Resolve the ambiguous names,
then run `--dry-run` again. No pages are written when the preflight fails.
`--set push:check_case=false` disables the optional remote case check. It does
not disable detection of two local files targeting the same page.

## Login or write rejected

Check credentials and the account's namespace permissions. A successful dry
run confirms readable destinations, not permission to save every edit. Page
protection, content filters, and CAPTCHA requirements can still reject a write.

## Network failure or unconfirmed edit

The run stops without automatically retrying uncertain writes. Earlier
confirmed changes remain. An unconfirmed write may have reached the Wiki, so
inspect that page and rerun after connectivity is restored. Already matching
content is skipped.

## Preview differs from the completed run

The preview describes the Wiki state at the time it runs. Other edits can
change that state. MediaWiki can also transform Wikitext when saving, including
substitutions and signatures. The completed run treats an API-confirmed
unchanged edit as success.

Use `-v` for unchanged-page diagnostics and configure file logging as described
in [settings](settings.md#logging).
