[back to overview](overview.md)
---

# Publication documents

Extract a version-1 document for a supported ordinary article:

```text
leniextract --document --input article.leni.json
leniextract --document 1 --input article.leni.json --output article.json
leniextract --processor --document
```

`--document` defaults to version 1. The default remains 1 when later versions
are introduced. Select either document output or `--field`, never both.
Without either selection, invocation fails. Unsupported versions fail before
initialization. The selection stays fixed throughout a processor session.

The result contains `schema_version`, `metadata`, and `content`, a string
containing one root `article` with a `div data-epd-role="body"`. Article-wide media
are direct children of `article`, while positioned media are inside the body.
Withdrawals retain `content: ""`. Version 1 is retained during coordinated
development. Consumers must adopt this shape together with the extractor. The same JSON is returned directly or in the processor's `output`.
See the [complete example](https://github.com/leni-lab/leniextract/blob/main/docs/document-contract.md#simple-article-example).

## Initial coverage

This implementation supports ordinary articles with nonempty Markdown bodies.
It is a development subset, not a verified replacement for the legacy IPTC or
NewsML converters. Supported metadata includes:

- required source ID, revision, and dispatch time
- optional update time, service, priority, category, genre, and raw/clean keywords
- headline, subheadline, byline, teaser, dateline, and agency credit line
- editorial signals for repeats, minor corrections, corrections, updates, and withdrawals
- unknown editorial reasons preserved as a literal kind/label object
- optional revision explanations as public `revision_short` and `revision_detail` notes
- previous received publication ID and optional UTC time from source history
- embargo time and comment
- header notices and the six reviewed service-note roles and visibilities

Optional absent or empty metadata is omitted. Explicit priority zero is kept.
`keywords_raw` preserves source order and spelling, including control markers
and colon-containing values, with exact duplicates removed after their first
occurrence. `keywords_clean` applies the agreed cleanup. Both lists remain
available on withdrawals and are omitted independently when empty. IPTX uses
the clean list plus structured signal and embargo facts. The planned NewsML
mapping uses the raw list. See the [keyword rules](https://github.com/leni-lab/leniextract/blob/main/docs/field-catalogue.md#clean-keywords).

Time values use UTC strings such as `2026-09-28T08:30:00Z`. The source continues
to provide epoch seconds. The [time contract](https://github.com/leni-lab/leniextract/blob/main/docs/time-semantics.md#timestamp-representation)
defines zero handling, fallback, and validation.

Body text supports paragraphs, headings `h1` through `h6`, emphasis, strong
emphasis, flat lists starting at 1, quotations, horizontal rules, deliberate
line breaks, and
ordinary HTTP, HTTPS, and mailto links. The evidenced LENI spelling
`[Contact](mailto: contact@example.org)` tolerates ASCII spaces immediately
after `mailto:` and produces `href="mailto:contact@example.org"`. This narrow
normalization does not rewrite escaped brackets, literal preformatted text,
other schemes, or spaces within an address. Incidental source newlines remain soft
breaks. Literal `<br>`, `<br/>`, `<br />`, and Markdown backslash breaks become
HTML `br`. The existing LENI container parser strips trailing spaces, so two
trailing spaces do not introduce a hard break.

An indented paragraph becomes `pre` when every line starts with an ASCII
space. Exactly one leading space per line is removed. Further indentation and
line breaks remain, and separate paragraphs remain separate blocks. This also
applies to a single indented line. Long lines are not wrapped during extraction.
Plain text and emphasis are supported inside these blocks: ` **Bold**` becomes
`<pre><strong>Bold</strong></pre>` and ` *Emphasis*` becomes
`<pre><em>Emphasis</em></pre>`. Nested and multiline emphasis retains the
remaining whitespace. This is a LENI extension, not a CommonMark code block.
Lines consisting only of underscores or stars remain literal separator text.
A mixed-indentation ordinary paragraph remains a flowing paragraph,
matching the legacy all-lines-indented condition. Indented list-like lines
inside it do not create a new list.

HTML text and attributes are escaped. Block serialization uses LF separators.
LENI annotation targets outside the ordinary link schemes are removed while
their visible text is retained. `leni:` links remain unsupported. Raw HTML
other than the recognized line breaks is rejected, not executed.

The following cases fail explicitly without a partial result:

- revision explanations without a revision signal
- Markdown image syntax such as `![Photo](photo.jpg)` and arbitrary embedded HTML
- paragraph classes, literal tabs, nested lists
  requiring indentation, tables, and code
- links, raw HTML, escapes, and entities in preformatted text
- unsupported attributes, including link titles and non-default list starts
- empty bodies, malformed input, or invalid metadata required by this operation

Reference-like literal text is accepted when it does not use the evidenced
structural syntax. Examples are body `image:` lines, `link: external-id; Label`,
`link: doc123` without a semicolon, and indented literal document-link lines.
Unindented document declarations start nested `article` occurrences with empty
`a data-epd-role="include"` links and URIs such as `de.epd:leni/doc/123`.
Source leading zeros are removed, and all reference info after the semicolon
is ignored. Nothing is fetched and no revision is invented. Subsequent text
and media belong to the occurrence until another declaration or heading.
Initial `title` and `teaser` fields become local semantic paragraphs.
`Inhalt-Gewicht` becomes `data-epd-toc-weight`, preserving missing, empty, and
zero without an inferred threshold. Other initial fields remain visible with
the `unknown` role and an unmapped-field diagnostic. Body `bild:` declarations
use the media blocks described below, also within article occurrences.
See the [reference contract](https://github.com/leni-lab/leniextract/blob/main/docs/document-contract.md#document-references) and the
[reference review](https://github.com/leni-lab/newsrouter/blob/main/docs/background/reference-content-audit.md).

These restrictions must be resolved through reference comparisons before
claiming publication compatibility. Raw field selection remains independently
available even when a document operation cannot handle the article.

## Existing indexes

Selected timestamps now also return UTC strings. Optional times return null
for absent or zero values, and a zero required dispatch fallback rejects.
Custom indexes that store these fields need matching text columns, queries,
and migrated or rebuilt data. The bundled Newsindex selection does not request
these fields. Its filename-derived store timestamp remains an integer.


## Publication identity

Document metadata includes optional `message_id`, an opaque string from
`data.msg_seq`. Strings are preserved unchanged, including alphabetic suffixes
such as `260928001L`, leading zeros, and punctuation. Nonnegative JSON integers
become strings. Missing, null, and empty values omit the field. Explicit zero
is retained as `"0"`. Booleans, negative integers, and other types are rejected.
The identifier is not a number and does not follow an inferred numeric pattern.
This identity is independent of `src_id`, `src_rev`, and store filenames.
It is available in document mode only. IPTX uses `"0"` when it is absent,
matching the reference default without inventing a publication identity.


## Associated image

Header `bild` becomes an include anchor in a media block directly under
`article`. `titel`, `copyright`, and `bu` become paragraphs with roles `title`,
`copyright`, and `caption`. This replaces `metadata.image` and uses the same
HTML structure as body media. The reference is preserved without retrieval.
Descriptions without a reference remain in an incomplete media block and
produce a diagnostic. Opaque targets remain inert anchor text. IPTX omits
direct article media and formats positioned media inside `body`.
The main text and media must be migrated with the formatter: flat fragments
and old `metadata.image` are no longer accepted by IPTX.
See the [image contract](https://github.com/leni-lab/leniextract/blob/main/docs/document-contract.md#images-and-media).


## Revisions and withdrawals

`RPT` maps to `repeat`, `RPX` to `minor_correction`, `REV`/`COR` to `correction`,
`UPD` to `update`, and `KIL` to `withdrawal`. An unknown reason becomes
`{"kind": "unknown", "label": "<original reason>"}`. Signal selection uses the
structured source reason, never keywords or a text comparison.

`metadata.previous` uses the last matching `rx|<word>` entry in source array
order. It contains `id` and optional `at`. Only the selected timestamp is
validated. No history match omits the object; a missing or zero time omits `at`.

Withdrawals have `content: ""` and a mandatory public `withdrawal` instruction,
plus any revision explanations. The identifying headline, source identities,
priority, classification, cleaned keywords, and previous reference remain.
Old subheadline, byline, teaser, dateline, footer, embargo, image, general
notices, and contacts are omitted. Old Markdown is not parsed or republished.

The normalized instruction is "Bitte verwenden Sie diese Meldung nicht."
The formatter owns the detailed target wording, including local display of
the previous UTC time. Missing-history placeholders are never source facts.
The separate raw field-selection interface still exposes source Markdown.


## Unpublished source fields

Header and service fields without a publication mapping do not block
extraction. Their parsed values travel in `metadata.unknown.header` or
`metadata.unknown.service_fields`. The optional document API `diagnostics` list
also retains them, and the unchanged source preserves their original spelling.
They never become public notes or inferred aliases. This includes new field
names, `rubrik`, `heftnummer`, and `layout_hinweis`, pending their normalized
mapping for other products. `rubrik` is not an alias for `data.cat` or
`data.pubcat`. Service `bild` and `titel` do not become associated article media.
Likewise, `intern` is not interpreted as `internet`.

The CLI reports field names, not potentially private values, on stderr or in
the successful processor response. The router logs this report and continues
delivery. For example:

```text
input: markdown header: unpublished fields (dienstleitung)
```

Each diagnostic has `section`, `name`, raw `value`, and `kind` (`unmapped` or
`directive`). Diagnostics are separate from the document, while the unmapped
values themselves are now part of its metadata. Empty sections and an empty
`unknown` object are omitted. Explicit empty field values remain strings.
Equal field names in header and service stay distinct. No source data is
modified. These values are intended for manual analysis. Formatters ignore
them entirely, including for private annexes or fallback values. Future agreed
mappings belong in regular extracted metadata. See the
[unassigned-information contract](https://github.com/leni-lab/leniextract/blob/main/docs/document-contract.md#unassigned-information).

Service `meta` accepts any parsed value, including unknown instructions,
combinations, and explicit false values. These strings remain opaque under
`metadata.unknown.service_fields.meta` and in diagnostics, never executed or published. Absence produces no diagnostic; an explicit empty
value does. Extraction does not interpret directive syntax or contradictions.
Repeated field names keep the parser's existing last-assignment behavior,
while the original source retains every occurrence.
Revision short notes preserve supplied line breaks, including trailing blank
lines, instead of rejecting them as multiline metadata.


## Body media

Each body `bild:` declaration becomes an independent `div` with
`data-epd-role="media"`. Its include anchor holds the HTTP(S) reference in
`href`. `titel`, `bu`, and `copyright` become paragraphs with roles `title`,
`caption`, and `copyright`, without source field labels in their text.
Repeated references stay separate and preserve description order.

The block remains media-neutral: `bild:` can refer to a video or provider page.
Nothing is fetched or embedded as an actual image during extraction. Missing,
opaque, or malformed references remain inert and produce diagnostics without
rejecting the article. Additional body fields keep their literal text in
paragraphs with `data-epd-role="unknown"`, plus an unmapped diagnostic. They
remain visible without an inferred caption or title alias.

CLI reports identify `body media: unresolved fields` by name only. Original
values are available in the optional diagnostics list. IPTX generates its own
field labels and respects the new block boundaries. See the
[media contract](https://github.com/leni-lab/leniextract/blob/main/docs/document-contract.md#content-positioned-media).
