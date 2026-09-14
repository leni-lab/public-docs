[back to overview](../../../../overview.md)
---

# Zoom::Config INI contract

Status: implemented by `configflow.zoom_config`. wiki2user uses this package.
The module also retains the bounded migration reader extracted from toolkit.

This contract defines the common byte representation and passive syntax for
configuration files read through the Zoom::Config family of readers. It is
independent of a particular producer, consumer, and domain format.

A format contract declares its files, section kinds, recognized keys, defaults,
relationships, and semantic equality. Those concerns do not belong to this
common contract.

## Canonical representation

A conforming producer writes:

- Windows-1252 text
- no byte-order mark
- CRLF line endings

ASCII text is also valid Windows-1252 output. A producer must fail when a
character cannot be represented in Windows-1252. It must not replace,
transliterate, or silently discard that character.

UTF-8 and LF-only files are not canonical producer output. A tolerant review
consumer may accept them, but that acceptance does not prove that every target
program using a Zoom::Config reader will interpret the same bytes as intended.

## Passive syntax

The contract subset contains:

- section declarations in the form `[section name]`
- assignments in the form `key = value`
- blank lines
- full-line comments beginning with `#` or `;`
- end-of-line comments whose `#` or `;` marker follows whitespace

A section declaration begins in column one and has a nonempty name. Only
whitespace and an optional end-of-line comment may follow its closing `]`.
Assignments occur inside a section. Surrounding assignment whitespace is
ignored; section names, key names, values, spelling, and source order are
otherwise retained for the format interpreter.

Quote, percent, and dollar characters are ordinary value characters. Quotes do
not escape comment markers, trigger unquoting, or enable multiline values.
Control characters other than horizontal tabs and the declared line endings are
invalid.

The subset does not contain includes, directives, continuation lines,
here-document values, encrypted values, macros, or executable expressions. A
passive consumer never expands or executes such constructs.

Repeated sections and keys remain syntactically visible. A format contract
decides whether they are valid and how values such as lists, booleans, and
timestamps are interpreted.

## Metadata comments

Files may contain the common [configuration metadata comments](metadata.md).
These comments remain outside the configuration's semantic content. Their
placement determines file, section, or key scope.

## Consumer behavior

A consumer must decode without replacement characters or silent data loss. By
default, the reader classifies ASCII-only input as ASCII, valid multibyte UTF-8
as UTF-8, and remaining valid input as Windows-1252. It exposes that encoding
and the detected CRLF, LF, mixed, or absent line endings on the `Document`. This
detection cannot distinguish every Windows-1252 byte sequence from UTF-8.
Callers comparing known canonical output must select `parse(...,
encoding="cp1252")` explicitly. Strict UTF-8 selection is also available through
`encoding="utf-8"`.

A consumer must not rewrite a file merely to normalize its representation. A
producer that republishes a configuration writes the canonical representation.

## Compatibility matrix

| construct                    | default reader        | migration reader                    | writer             |
| ---------------------------- | --------------------- | ----------------------------------- | ------------------ |
| sections and assignments     | ordered, literal      | ordered, literal                    | canonical layout   |
| repeated declarations        | retained              | retained across includes            | retained           |
| comments and metadata        | source positions      | source and physical positions       | explicit comments  |
| Windows-1252, CRLF or LF     | strict                | strict                              | Windows-1252, CRLF |
| UTF-8 with BOM               | strict UTF-8          | strict UTF-8                        | never emitted      |
| UTF-8 without BOM            | strict auto-detection | strict auto-detection               | unsupported        |
| include directives           | rejected              | bounded local resolution            | unsupported        |
| assignment continuations     | rejected              | joined with original whitespace     | unsupported        |
| brace blocks                 | rejected              | opaque, complete raw lines retained | unsupported        |
| heredocs and encrypted input | rejected              | rejected                            | unsupported        |
| comment-mode directives      | rejected              | rejected                            | unsupported        |
| macro/expression evaluation  | never                 | never                               | never              |

The writer emits a blank line after each section. Empty output is one CRLF.
Declaration order is preserved. No unquoting, escape decoding, timestamp
generation, or default application takes place. Metadata keys use the order
defined by the [output contract](output.md). A leading literal comment marker in
a value uses key=#value or key=;value so that formatting cannot erase it. Values
with significant surrounding whitespace or embedded whitespace-comment sequences
cannot be represented by this subset and are rejected.

Before expanding this matrix, verify examples against the actual target
Zoom::Config implementation. The current tests establish the contracts
documented here, not complete Perl compatibility.

## Migration semantics and reference

The migration mode is explicitly selected with load() or parse(...,
extended=True). parse() never opens includes. The canonical writer and default
reader continue to implement the passive contract above.

The original Zoom::Config _read implementation (revision 92, reviewed in
usermgr20/lib/Zoom/Config.pm) supplies these tested rules:

- strip end-of-line comments before continuation processing, even in quotes
- remove one trailing backslash and append the next line with its indentation
- keep section context across includes, including after returning
- keep raw scalar quotes and escapes for the consumer
- consume brace blocks through a column-one closing brace, including payload
  lines that resemble sections, assignments, comments, or includes

The shared parser retains duplicate declarations rather than overwriting them.
The user2wiki adapter applies its existing last-value-wins and defaults. Opaque
block values cannot be used as scalar administrative fields there.

Deliberate migration limits and differences:

- includes use the explicit root/source policy documented in README.md,
  rather than the Perl process working directory
- malformed input and unfinished continuations/blocks fail explicitly
- UTF-8 with BOM is accepted for existing migration copies
- heredocs, encrypted blocks/files, comment-mode directives, and arbitrary
  expression evaluation remain unsupported
- values.decode() preserves the existing Python migration's safe literal
  decoding policy, not general Perl evaluation

The complete Perl module could not run in the available MSYS environment because
its platform-specific Zoom::Util::Unix dependency was unavailable. Rules were
checked against source, synthetic regression fixtures, and a byte comparison
with the previous Python migration on the local input copy. No complete
differential equivalence with the Perl runtime is claimed.
