# storeindex

storeindex maintains a searchable index of published news items. It reads new
news items from a store and uses a source-specific extractor to obtain JSON
fields. The external SQL schema determines their columns, relations, and indexes.
The bundled schema indexes LENI titles with SQLite full-text search and stores
the service as text, and ordered keywords and channels in linked tables for
separate search consumers.

Use `fill` for one pass over loose files, or `fill --watch` to keep processing.
Older news items may remain in daily ZIPs created by storepack. Use `fill --all`
to add missing entries from the entire store, or `fill --since YYYY-MM-DD` for a
date range. Use `replace` to reindex a range or `rebuild` to recreate the
database. Both include ZIPs and support `--since` to limit indexing.

- [quickstart](quickstart.md)
- [command line](cli.md)
- [settings](settings.md)
- [troubleshooting](troubleshooting.md)

Use is subject to [LICENSE](LICENSE).
