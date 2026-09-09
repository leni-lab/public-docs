# Overview

wiki2config-usermgr is a domain processor for administrative usermgr
configuration. It reads expanded Wikitext from stdin, validates users, groups, and permission
bundles, and writes three normalized INI fragments to a working directory.

It handles group inheritance, deterministic permission order, expiry dates, and
supported defaults. It produces a Markdown report for the current run. It does
not create local accounts, manage passwords, send mail, or modify an active
configuration.

The separate wiki2config application owns local source files and includes,
observation, source-reference resolution, metadata, activation, and optional Git
archival. wiki2config-usermgr can be used independently with a consolidated
input stream. Install wiki2config separately for the complete automated import.

## Documentation

- [first run](quickstart.md)
- [command options](cli.md)
- [input format](wiki-format.md)
- [output and reports](operation.md)
- [migration](settings.md)
- [troubleshooting](troubleshooting.md)
- [license](LICENSE)
