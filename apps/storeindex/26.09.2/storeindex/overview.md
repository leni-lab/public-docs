# storeindex

storeindex maintains a searchable index of published messages. It reads new
messages from a store and uses a source-specific extractor to obtain their
titles. The current version supports full-text search over those titles.

Older messages may remain in daily ZIPs created by storepack. A manual rebuild
can include these ZIPs and replace either the entire index or a selected
date range.

- [Quickstart](quickstart.md)
- [Command line](cli.md)
- [Settings](settings.md)
- [Troubleshooting](troubleshooting.md)

Use is subject to [LICENSE](LICENSE).
