[back to overview](overview.md)
---

# Troubleshooting

## Input cannot be read

Check the supplied path and read permissions. The input must contain one
complete UTF-8 JSON document. A UTF-8 byte order mark is accepted.

When using standard input, close the input stream after sending the document.
The command waits until the input is complete.

## Invalid export

The export must contain a `data` object. Its `headline` must be text or null.
Malformed JSON and incompatible values produce a nonzero exit code and a
diagnostic on standard error.

## Title is null

The export has no title or explicitly contains a null title. This is a
successful extraction, not a program failure.

## Unsupported field

This version supports only `title`. Check the spelling and remove empty
names, including trailing commas in `--field` values.

## Command cannot be found

Use the full executable path or activate the Python environment in which
leniextract was installed.
