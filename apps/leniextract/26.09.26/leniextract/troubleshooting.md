[back to overview](overview.md)
---

# Troubleshooting

## Input cannot be read

Check the supplied path and read permissions. The input must contain one
complete UTF-8 JSON document. A UTF-8 byte order mark is accepted.

When using standard input, close the input stream after sending the document.
The command waits until the input is complete.

## Invalid export

For `title`, the export must contain a `data` object whose `headline` is text
or null. For `src_id` and `src_rev`, the top-level `id` and `rev` must be
signed 64-bit integers or decimal strings such as `"1117006"`. Strings are
converted to JSON integers. Missing values, null, booleans, floats, invalid
strings, and values outside the signed 64-bit range are rejected. Only
requested fields are checked. Invalid JSON and incompatible values produce
exit code 3, diagnostics on stderr, and no result on stdout.

## Title is null

The export has no title or explicitly contains a null title. This is a
successful extraction, not a program failure.

## Unsupported field

See the [index fields](cli.md) and [content fields](content-fields.md).
Check spelling and remove empty names, including trailing commas in `--field`
values. `body` contains the article Markdown; `text` is not a field alias.

## Invalid article Markdown

Content extraction requires the LENI layout: headline, optional subline, a
blank line, optional header fields, article body, and optional agency line
followed by service fields. Metadata continuation lines start with spaces.
Malformed nonempty Markdown is rejected when requesting parsed content.
An index-only field selection does not parse it. No partially parsed article
is returned. Inspect the indicated Markdown line in the source document.

## Command cannot be found

Use the full executable path or activate the Python environment in which
leniextract was installed.
