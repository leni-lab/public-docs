[back to overview](overview.md)
---

# Quickstart

First working setup path for wikiread operators.

## prerequisites

- installed `wikiread` command
- network access to the MediaWiki API
- MediaWiki username and password with read access

## package contents

- `wikiread` command
- `wikiread.example.ini` template

## setup local config

- create `wikiread.ini` from `wikiread.example.ini` beside `wikiread.exe`
- set `api`, `username`, and `password` in `[mediawiki]`
- choose a dedicated directory in `[output]`
- define at least one output group in `[pages]`
- keep `wikiread.ini` local because it contains credentials

Minimal example:

```ini
[mediawiki]
api             = https://example.org/w/api.php
username        = wikiread
password        = bot-password

[output]
path            = output

[pages]
legacy          = keywords, stichworte
config          = config/*
```

This creates files such as `output/legacy/keywords.wiki` and
`output/config/mail.wiki`.

See [settings.md](settings.md) for selector syntax and all configuration keys.

## run one synchronization

```text
wikiread
```

The command reads all selected pages, updates changed local files, removes
selected files whose Wiki pages disappeared, and then exits.

## validate the result

- each group with selected pages has one direct subdirectory below the output
  path
- selected pages appear as normalized `.wiki` files
- file contents are raw Wikitext
- file modification times match the stored MediaWiki revisions
- no error or warning remains unresolved in the log

Do not place consumer caches or manually maintained `.wiki` files in the
output tree. Directories are created when files are written, and empty
directories are removed after synchronization.

## run continuously

```text
wikiread --watch
```

Watch mode performs one initial synchronization and then reacts to the global
MediaWiki Recent Changes marker. Use `-v` when the configured log file should
also contain `DEBUG` details:

```text
wikiread -v --watch
```

A configuration change requests a graceful stop. Use a process manager when
the application should restart automatically with the new configuration.

## see also

- [overview.md](overview.md)
- [cli.md](cli.md)
- [settings.md](settings.md)
- [troubleshooting.md](troubleshooting.md)
