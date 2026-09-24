[back to overview](overview.md)
---

# Content fields

These fields extend the index fields documented in [Command line](cli.md).
Select them with `--field` in raw CLI or processor modes. Configured processor commands include `--processor` and optionally `--once`.
Every selected key is returned, including absent optional values.

## Mapping

| field                       | LENI source                                       | output                                                         |
| --------------------------- | ------------------------------------------------- | -------------------------------------------------------------- |
| `markdown`                  | `data.markdown`                                   | original text or null, without parsing                         |
| `body`                      | parsed Markdown body                              | Markdown including dateline, without metadata or agency footer |
| `subline`                   | second title line                                 | text or null                                                   |
| `authorline`                | header `von`                                      | text or null                                                   |
| `teaser`                    | header `teaser`                                   | text or null                                                   |
| `editorial_notice`          | header `hinweis`                                  | text or null                                                   |
| `footer`                    | agency line beginning with `epd`                  | text or null                                                   |
| `location`                  | leading body dateline before `(epd).`             | ordered string array                                           |
| `service_info`              | service `info`                                    | text or null                                                   |
| `service_internet`          | service `internet`                                | text or null                                                   |
| `service_localities`        | service `orte`                                    | text or null, distinct from `location`                         |
| `service_editorial_note`    | service `red`                                     | text or null                                                   |
| `service_contact`           | service `ap`                                      | private contact text or null                                   |
| `service_editorial_contact` | service `kontakt`                                 | private editorial contact text or null                         |
| `embargo_until`             | `data.embargo_until`                              | nonnegative epoch seconds or null                              |
| `embargo_comment`           | `data.embargo_comment`                            | text or null                                                   |
| `signal`                    | `data.republish_reason`                           | normalized revision signal or null                             |
| `revision_short`            | `data.republish_short`                            | text or null                                                   |
| `revision_note`             | `data.republish_notice`                           | text or null                                                   |
| `previous_id`               | last `pub` entry whose `msg` ends in `rx\|<word>` | received identifier or null                                    |
| `previous_at`               | `update_at` in that same `pub` entry              | nonnegative epoch seconds or null                              |

The JSON headline remains authoritative for `headline_raw`; the duplicate headline
inside Markdown does not replace it. Existing title text is unchanged.

Missing/null/empty Markdown yields null for parsed scalar fields and `[]` for
`location` and the index field `locations`. Both share the same extraction.
Raw `markdown` preserves an explicit empty string. Malformed
nonempty Markdown is rejected only if a parsed content field is requested.
Header and service fields normalize names to lowercase with `_` replacing
`-`. Continuations lose indentation, duplicate fields use the last value.
Scalar metadata removes link/annotation targets and unescapes `\*` and `\_`,
matching the legacy Item accessors. Body Markdown retains its inline syntax.

The dateline location list splits on comma or slash and removes exact
duplicates, preserving order. A missing dateline gives `[]`. A source field
called `data.location` is not substituted for the legacy dateline selection.

Missing/null/empty embargo timestamps return null; zero is retained.
Other values must be nonnegative signed-64-bit integers or decimal strings.
Previous-publication entries are read in source order, not sorted by time.
Only matching received entries contribute; no match gives null. The two
previous-publication fields support withdrawal wording without store access.

| source code          | signal       |
| -------------------- | ------------ |
| `RPX`, `RPT`         | `repeat`     |
| `REV`, `COR`         | `correction` |
| `UPD`                | `update`     |
| `KIL`                | `withdrawal` |
| missing, null, empty | null         |

An unknown nonempty revision code is rejected when `signal` is requested.
It must not silently become an ordinary article.

## Formatter extraction

For example, select the implemented content fields together:

```text
leniextract
  --field headline_raw,body,signal,keywords_raw,dispatch_at
  --field subline,authorline,teaser,editorial_notice,footer
  --field embargo_until,embargo_comment,revision_short,revision_note
  --field service_info,service_internet,service_localities,service_editorial_note
  --field service_contact,service_editorial_contact,previous_id,previous_at
```

Join the displayed command lines when calling it from a shell. The toolkit INI
`command` field accepts indented continuation lines. Add identity or selection
fields when another consumer needs them. `body` is intentionally Markdown;
the output formatter constructs text and HTML alternatives.

These content fields are not selected by the bundled Storeindex configuration. Indexing a new
field still requires an explicit matching schema and extractor configuration.
