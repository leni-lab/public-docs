[back to overview](overview.md)
---

# Troubleshooting

| diagnostic                            | action                                                   |
| ------------------------------------- | -------------------------------------------------------- |
| `existing regular directory required` | create a separate working directory                      |
| `empty directory required`            | use a fresh working directory                            |
| `invalid UTF-8`                       | pass UTF-8 bytes on stdin                                |
| `UTF-8 without BOM required`          | remove the input stream's leading BOM                    |
| `expand includes before processing`   | assemble referenced pages before invoking wiki2config-usermgr      |
| `no configuration data areas found`   | include at least one users, groups, or permissions area  |
| `comment: not closed`                 | close the comment before the next horizontal rule or EOF |
| `Windows-1252`                        | remove unsupported characters from emitted data          |

A `line:<n>` report reference identifies a line in expanded stdin, not a line in
the original entry page. The assembler resolves it using its source map.
Horizontal rules reset headings and defaults but keep line numbers increasing.

Old `--config`, `--watch`, and `--check` commands are no longer accepted. See
[migration](settings.md). Do not activate files from a failed process.
