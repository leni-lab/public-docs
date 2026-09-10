# Overview

wiki2config turns mirrored Wiki input into active configuration through a
separate domain processor. It assembles includes, runs the processor, checks the
common INI output, maintains section timestamps, and activates the result.
Optional Git archival follows activation. Markdown reports are independent.

The processor decides the domain format and the complete file set. wiki2user is
one such processor for usermgr. wiki2config itself knows no users, groups,
rights, or fixed filenames.

- [command options](cli.md)
- [troubleshooting](troubleshooting.md)
- [first run](quickstart.md)
- [settings and processor arguments](settings.md)
- [include syntax](includes.md)
- [operation, reports, and recovery](operation.md)
- [example configuration](wiki2config.example.ini)
- [license](LICENSE)
