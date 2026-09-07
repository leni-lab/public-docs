# Overview

wiki2user converts local Wiki pages into administrative usermgr configuration.
Operators can validate changes, review conversion reports, and retain complete
configuration versions before using the generated files.

## Capabilities

- reads local pages provided by wikiread
- validates users, groups, permission bundles, and their references
- generates the three administrative INI fragments used by usermgr
- runs once or watches local pages for changes
- archives complete configuration versions
- reports changes, repairs, and errors
- preserves entry timestamps and unchanged output files

## Requirements

- installed `wiki2user` command and the example configuration
- local Wiki pages in the supported [data format](wiki-format.md)
- read access to input and write access to output, archive, report, and log paths
- one wiki2user process per output, archive, and report root

## When not to use

Do not use wiki2user to read MediaWiki directly. It reads local pages supplied
by wikiread, so a successful conversion does not prove that the mirror is
current.

Do not use it for local account creation, passwords, password resets, mail
delivery, or account deletion. It generates administrative memberships and
rights only.

Validation detects structural and reference errors. Operators still need to
review whether the configured memberships and permissions are appropriate.
Files received from wikiread can represent different Wiki revisions.

## Documentation

- first setup: [quickstart](quickstart.md)
- configuration reference: [settings](settings.md)
- command reference: [CLI](cli.md)
- editable Wiki content: [Wiki format](wiki-format.md)
- reports, archives, and continuous operation: [operation](operation.md)
- common problems: [troubleshooting](troubleshooting.md)
- configuration template: [wiki2user.example.ini](wiki2user.example.ini)
- license: [LICENSE](LICENSE)
