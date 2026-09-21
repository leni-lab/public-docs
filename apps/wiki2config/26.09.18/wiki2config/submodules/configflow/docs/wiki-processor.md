[back to overview](../../../overview.md)
---

# Wiki processor

This document defines the process interface between wiki2config and a domain
processor. Input consists of named Wiki pages in one JSON document. The shared
[parser](wiki-parser.md) resolves the [Wiki language](wiki-format.md), and the
processor validates domain records and produces a complete INI configuration.

## Responsibilities

| component   | responsibility                                                    |
| ----------- | ----------------------------------------------------------------- |
| wiki2config | input observation, include selection, named pages, and execution   |
| configflow  | JSON input, Wiki parsing, defaults, use resolution, and locations  |
| processor   | record selection, domain validation, and complete INI generation  |
| wiki2config | general INI validation, metadata, byte comparison, and activation  |
| wiki2config | independent reports and optional Git archival after activation    |
| configflow  | shared contracts, INI syntax, and metadata helpers                 |
| toolkit     | general application infrastructure                                |

wiki2config knows the common INI representation, but no usermgr schema.
The usermgr processor interprets users, groups, and permissions. A news
distribution processor interprets subscriptions and delivery settings. Both
use the same Wiki syntax and resolution rules. Application lifecycle and
subprocess management remain outside configflow.

## Process interface

| channel or argument | contract                                                       |
| ------------------- | -------------------------------------------------------------- |
| stdin               | one complete JSON input document, UTF-8 without BOM            |
| stdout              | Markdown report body, UTF-8 without BOM                        |
| stderr              | technical diagnostics, UTF-8                                   |
| `--output PATH`     | absolute path to an existing, empty working directory          |
| exit code 0         | complete, domain-valid output has been written and files closed |
| other exit code     | failed processing, no candidate activation                     |

The encoding is independent of the console code page. The processor reads until
EOF. Normal processing writes no startup banner, logging, JSON, or control
records to stdout. Its Markdown describes the current processing result, not
successful activation or archival. Help and version invocations are outside this
processing interface.

The processor receives no previous-output argument. It must not access or
modify the active output directory. wiki2config can report added, changed,
and removed files without interpreting their domain meaning.

The processor can write a useful Markdown error report before returning a
nonzero code. wiki2config retains that report and technical diagnostics, and
adds the failed phase. A crash, invalid stream encoding, or interrupted process
must never turn partial output into a successful result.

## JSON input

The envelope has this structure:

```json
{
	"version": 1,
	"pages": [
		{
			"source": "shared.wiki",
			"text": "= templates =\n== mail ==\n* sender: news@example.org\n"
		},
		{
			"source": "example.wiki",
			"text": "\n= abo: customer bas =\n# use: /shared/templates/mail\n* recipient: delivery@example.org\n"
		}
	]
}
```

| member         | requirement                                           |
| -------------- | ----------------------------------------------------- |
| `version`      | integer `1`                                           |
| `pages`        | nonempty array containing the entry and included pages |
| `pages.source` | source filename, including its `.wiki` extension       |
| `pages.text`   | decoded page content, with physical lines preserved    |

Each page object has exactly `source` and `text`. The envelope has exactly
`version` and `pages`. Missing or unknown members, duplicate JSON member names,
wrong types, unsupported versions, invalid Unicode, and trailing non-JSON
content are input errors. An empty source file is represented by a page with
empty text, not by omitting that page.

Source names are single filenames without directory components. They must
produce valid namespaces under the Wiki format rules. Namespace comparison is
case-insensitive, so `Example.wiki` and `example.wiki` cannot be separate
entries. Source spelling is retained for diagnostics. The processor treats
these names as identities and never opens them as filesystem paths.

wiki2config keeps the source-to-local-file mapping outside the processor.
Absolute local paths, active output paths, and file access credentials are
not part of the envelope.

### Assembly and source coordinates

wiki2config performs include selection according to
[Includes](wiki-format.md#includes). It traverses includes in listed order,
emitting completed included pages before the including page. Each resolved
file contributes one page object, including empty files. Page order does not
affect reference lookup or field precedence.

Source files are strict UTF-8 with an optional leading BOM. The reader removes
that BOM and normalizes CRLF and CR line endings to LF. Each consumed include
directive is replaced by an empty line, rather than deleting its physical
line. All other content and line positions are retained. In the example,
the entry page's first line represents its consumed include directive.

There are no inserted Wiki separators or namespace directives. Each JSON page
starts its own root. Horizontal rules within a page are ordinary text and do
not reset its defaults or namespace. JSON formatting and escaped newlines do
not participate in Wiki line numbering.

The shared input adapter validates the envelope before parsing its page
collection. The shared parser builds all page trees before resolving use.
Each page's comments must close within that page. Errors prevent a partial
document from reaching domain conversion.

Files are read and closed individually. Atomic replacement can make each file
complete, but the assembled collection need not represent one common Wiki
revision. The assembled collection is validated as a whole.

## INI output

The processor owns domain validity and completeness. In particular, the usermgr
processor must produce its three administrative INI files even when some
contain no entries. wiki2config has no configured list of their names and
cannot detect a domain-specific omission.

| property       | requirement                                                        |
| -------------- | ------------------------------------------------------------------ |
| file set       | at least one regular `.ini` file directly in the working directory |
| other entries  | no subdirectories, links, temporary files, or other output types   |
| representation | strict Windows-1252 without BOM, CRLF                              |
| syntax         | common passive INI syntax                                          |
| metadata       | no processor-generated structured metadata                         |
| completeness   | all files needed for the new state, never just changed files       |

The [INI syntax](zoom-config/syntax.md) and [normalized output
contract](zoom-config/output.md) are authoritative. Characters that cannot be
represented fail processing, without replacement or transliteration. The
processor supplies normalized domain values and a deterministic declaration
order. For example, only the usermgr processor decides how to order a group
list or omit a default value.

wiki2config validates the whole candidate before touching active files.
Successful exit with an empty directory is an error. A logically empty
configuration is represented by valid empty INI files instead.

## Metadata and comparison

wiki2config uses the current output directory as its only baseline and owns the
[metadata rules](zoom-config/metadata.md). Git history, input file
times, and reports do not supply missing lifetime information.

The producer maintains section-level `created` and `changed` metadata under
the general metadata contract. File and assignment lifetimes are outside this
producer's metadata profile.

Section identity consists of the output filename and literal section name.
wiki2config matches filenames case-insensitively to reflect Windows file
identity. Section and assignment names remain literal. If a format emits
repeated section names, occurrences are matched in their source order within
that name. Renaming or moving a section starts a new identity. A processor must
keep names and ordering stable when its normalized output has not changed.

The comparison content of a section is its ordered sequence of literal
assignment names and values as read through the common INI syntax. Metadata,
comments, and layout are not configuration content. wiki2config does not unquote
values, apply defaults, reorder lists, case-normalize domain names, or compute
effective rights. Repeated assignments remain ordered and visible.

The producer transition table in the [output
contract](zoom-config/output.md#metadata-transitions) applies with this equality
definition. Unchanged sections retain valid metadata, existing sections without
known creation time stay unknown, and deleted sections that reappear start a new
lifetime. Time is supplied explicitly once for the attempt. Invalid baseline
syntax or metadata is reported before activation rather than silently discarded.

After metadata processing, complete candidate bytes determine which files need
replacement. Identical bytes cause no write. A layout normalization can require
a write without advancing lifetime timestamps. There is no volatile import ID or
generation timestamp inserted into otherwise unchanged output.

## Reports and source references

Markdown stdout is the processor's report body. wiki2config adds file changes,
activation status, and optional archival results. Reports remain independent of
configview and Git. A report may refer to the resulting commit.

A source reference is an inline code span with exactly this content:

```markdown
- `source:users.wiki:42`: unknown group "editors"
```

The reserved content is `source:<source>:<line>` with an optional
`:<column>`. Line and column numbers are positive and refer to the original
page. Columns count Unicode code points. References identify an exact source
from the JSON collection, not a heading path or a physical JSON line.

Encode the source name as UTF-8 percent-encoded text, leaving only ASCII
letters, digits, `.`, `_`, and `-` unescaped. This allows filenames containing
spaces or Markdown punctuation without changing the reference grammar. The
example's `users.wiki` requires no escaping. A shared renderer constructs
references from location objects rather than from interpolated input text.

wiki2config decodes and validates the reference against its input source map
and original source coordinates. It replaces the span with an escaped source
label such as `users.wiki:42`. Unknown sources, malformed encodings, and
out-of-range coordinates are diagnostic contract errors, never guessed
locations. The start of an empty source can be referenced as line 1, column 1.

Only a single-backtick inline code span with the reserved form is a source
reference. Ordinary prose, spans with multiple backticks, fenced or indented
code blocks, and HTML blocks are not references. A processor quotes arbitrary
source text as literal content, not as a constructed reserved reference.

Errors involving several definitions can supply several source references.
Inherited and imported fields refer to their original assignments, with
additional references for the relevant use chain. Envelope errors without a
known Wiki location use ordinary diagnostics rather than fabricated references.

## Activation and recovery

The working directory is separate from active output and uses the same
filesystem for replacement. The active directory is dedicated to generated INI
files, except for Git's own repository data. Reports and working files live
elsewhere.

After successful processing and validation, wiki2config prepares all final files
with metadata before activation. It replaces changed files atomically per file
and removes formerly generated files absent from the new set. The set as a whole
is not atomically replaced. Consumers must tolerate an intermediate set using
their existing restart behavior.

Failure before activation discards the candidate and keeps the active state.
Failure during activation can leave a mixed set and is reported explicitly.
There is no persistent importer journal. On startup, wiki2config removes its own
stale working directory and generates a new complete candidate from current
input. If that input is invalid, it cannot repair a partial activation until a
valid candidate can be generated. Available active files retain the baseline
information still present in them.

Git archival is optional and follows complete activation. An archival failure
does not undo the active configuration and must be reported as such. Watch mode
retries a retained candidate before observing newer input. A one-shot invocation
reports the failure and exits. A restart can lose the opportunity to archive an
earlier activated state before newer input replaces it. No automatic push is
implied.

The external process manager prevents simultaneous instances. Reading input
files published by atomic replacement gives complete individual files, not a
common revision across all pages. The processor validates the assembled
combination before any output becomes active.
