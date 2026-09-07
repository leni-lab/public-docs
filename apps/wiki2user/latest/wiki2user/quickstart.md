[back to overview](overview.md)
---

# Quickstart

Extract `wiki2user.zip` to a writable application directory. The package
contains `wiki2user.exe` and `wiki2user.example.ini`.

Run wikiread and verify that the local entry page and included pages are current
and reside in one directory.

Copy [wiki2user.example.ini](wiki2user.example.ini) to `wiki2user.ini`
beside the executable and set at least:

```ini
[input]
file = ../wikiread/output/config/users.wiki

[output]
path = output/ini
```

Relative paths use the directory containing `wiki2user.ini` as their base.

Validate without writing:

```text
wiki2user --check
```

Then publish and activate the first version:

```text
wiki2user
```

Verify the three INI files in `output/ini`, the timestamped complete set in
`output/ini/archive`, and the matching Markdown file in
`output/ini/reports`. Review its header status, warnings, and activation
section.

Later successful runs create no additional report when they reuse the archived
version and write no current file.

For continuous operation:

```text
wiki2user --watch
```

The process converts immediately and then observes local Wiki changes.
Ctrl+C requests a graceful stop. A settings change stops the process; restart
it to apply the new configuration.

When adopting an existing generated set, provide all three files as the
initial baseline or leave the current output directory complete. See
[settings](settings.md) and [operation](operation.md).
