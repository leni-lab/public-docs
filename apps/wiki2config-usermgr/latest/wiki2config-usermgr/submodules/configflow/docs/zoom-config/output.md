[back to overview](../../../../overview.md)
---

# Normalized output contract

This contract defines deterministic output for producers of the [Zoom::Config
syntax](syntax.md). It introduces no importer controller, application schema,
report format, or persistence mechanism.

## Representation

| property          | canonical output                                                  |
| ----------------- | ----------------------------------------------------------------- |
| encoding          | Windows-1252, strict, without a byte-order mark                   |
| line endings      | CRLF                                                              |
| section           | `[name]` followed by its selected comments and assignments        |
| assignment        | `key = value`, except leading literal `#` or `;` uses `key=value` |
| spacing           | one blank line after each section                                 |
| empty document    | one CRLF                                                          |
| metadata order    | `created`, `changed`, then other keys alphabetically              |
| metadata spelling | lowercase keys and UTC timestamps with uppercase `T` and `Z`      |

Characters that cannot be encoded and values that cannot round-trip fail before
any output is published. Values are never silently truncated, escaped into a
different meaning, or replaced with substitute characters.

## Division of responsibility

The application supplies stable item identities, normalized scalar values, and
deterministic declaration order. Only the application knows defaults, list
semantics, case rules, dependencies, and whether an omitted value is equivalent
to an explicit default. The writer retains the supplied order because sorting
can alter the meaning of dependency-sensitive formats.

The format module serializes those values and maintains [metadata](metadata.md)
from explicit application decisions. The same ordered content and metadata
always produce identical bytes. No current time, import ID, source file time,
Git revision, or report ID is added implicitly.

## Metadata transitions

| previous item                              | semantic content | result                                                  |
| ------------------------------------------ | ---------------- | ------------------------------------------------------- |
| absent                                     | new              | `created = now`, no `changed`                           |
| present without metadata                   | equal            | creation stays unknown                                  |
| present without metadata                   | changed          | creation stays unknown, `changed = now`                 |
| present with metadata                      | equal            | preserve valid metadata                                 |
| present with metadata                      | changed          | preserve creation and unknown keys, set `changed = now` |
| deleted and later absent from the baseline | reappears        | begin a new lifetime                                    |

`now` is explicit and timezone-aware. A semantic change whose timestamp would
precede an existing `created` or `changed` fails. A producer cannot reconstruct
deleted history from file modification times. Metadata normalization itself does
not constitute a semantic change.

## Comparing and publishing

A producer can render its complete candidate set, then compare candidate bytes
with the files currently in its output directory. A changed byte sequence
requires replacement. Identical bytes require no write. An externally modified
or older noncanonical file can require one normalization write even when its
semantic content is equal. That write preserves lifetime timestamps.

Preparing all candidates, validating domain references, activating files,
retrying failures, and optionally archiving output remain application concerns.
The pure reader, writer, and metadata helper perform no publication or file
replacement. Reports remain independent of this contract.
