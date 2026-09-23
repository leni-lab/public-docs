[back to overview](../../../overview.md)
---

# Wiki parser

This document defines the shared parser's object model and access contract.
The [Wiki format](wiki-format.md) defines syntax and resolution rules. The
[processor contract](wiki-processor.md) defines the JSON envelope carrying
named pages. These contracts are independent of any domain schema.

Examples use `configflow.wiki` as `wiki` and the shared `configflow.report`
renderer as `report`.

## Processing boundary

The shared library performs these steps:

1. accept a complete collection of named page texts
2. parse each page independently, retaining its local source coordinates
3. build the case-insensitive namespace and heading-path index
4. validate uniqueness and resolve defaults and use dependencies
5. expose the resolved document to the domain processor

Resolution covers all supplied pages, allowing forward and cross-page
references. All nodes must be valid, including unreferenced templates. Syntax
errors, invalid additive lists, unresolved references, and cycles prevent a
successful document result.

The process input adapter decodes JSON and supplies pages to the same core
parser used by in-memory callers. It does not require a separate domain
implementation of use or inheritance. Core parsing does not read files,
write output, publish reports, or access active configuration.

The shared [file adapter](wiki-files.md) selects and reads include files.
The parser receives their named
contents through the process input contract. Use can only address nodes in
that supplied collection.

## Document and pages

### Entry points

Both public entry points return a fully resolved `Document`:

```python
document = wiki.parse(sources)
document = wiki.parse_json(text)
```

`parse()` accepts an iterable of `Source` objects containing a source
filename and its page text. It consumes the input completely before returning:

```python
sources = [
	wiki.Source("example.wiki", example_text),
	wiki.Source("shared.wiki", shared_text),
]
document = wiki.parse(sources)
```

Each source exposes `name`, including the `.wiki` extension, and `text`.
The name corresponds to `pages.source` in the JSON envelope. Page texts
preserve original physical line positions as required by the process contract.
Include selection must already have consumed include directives. A remaining
include directive is an input error; neither entry point performs page loading.

`parse_json()` accepts the decoded JSON text, validates its envelope, builds
the same source objects, and uses the same parser. Neither entry point reads
stdin or opens files. The caller owns I/O and byte decoding. The JSON process
input uses strict UTF-8 without a BOM.

Success means namespace, path, field, and dependency validation has completed.
Invalid input raises an exception. There is no separate public resolve call
and no unresolved document returned to the processor.

### Node selection

The document exposes heading nodes, optionally selected by type:

```python
for node in document.nodes(type="user"):
	process_user(node.name, node.fields())
```

`nodes(type=None)` visits all headings. A supplied type selects exact type
matches without case sensitivity, not title prefixes or path substrings.
The filter uses each node's own declared type and covers all supplied pages
and heading depths. It has no domain-specific list of supported types.

`nodes()` returns a tuple that can be traversed repeatedly. Order follows page
input order and depth-first heading order within each page. Implicit page
roots are excluded. Untyped headings are included when
no filter is supplied and have `node.type is None`. Selecting a type leaves
other types available for independent processors sharing the same pages.

The document's public selection surface is `nodes(type=None)`. Absolute-path
lookup and page-root indexing serve internal reference resolution. Processors
do not need to resolve use references or split title prefixes themselves.
Parent and child navigation are internal rather than part of the public API.

### Internal page structure

A document contains the ordered pages, their roots, and an index of unique
absolute paths. Empty and prose-only pages are valid parser input. Whether a
document contains enough domain data is a processor decision.

Each page has its source filename, filename-derived namespace, and implicit
root. The root owns page-wide fields and top-level headings. No root has a
parent in another page.

Page and node order is retained for traversal and reproducible diagnostics.
Only instruction order within a node determines field precedence. A heading's
depth is separate from its path: skipped levels do not create synthetic path
components.

Documents, nodes, fields, and diagnostics are read-only once constructed.
Returned collections cannot alter another node's resolved values. Processors
build their own domain objects instead of modifying parsed configuration.

## Nodes

There is one node per heading and one implicit root per page. Duplicate paths
are rejected rather than consolidated. Each node has one heading location.
All headings are available, including grouping nodes, templates, and nodes
with no effective fields.

The agreed access surface is:

| access                                 | meaning                                 |
| -------------------------------------- | --------------------------------------- |
| `node.path`                             | normalized absolute heading path        |
| `node.type`                             | normalized declared type, or `None`     |
| `node.name`                             | normalized name without the type        |
| `node.title`                            | original name part, without type or padding |
| `node.field(name)`                      | effective field, or `None` when absent  |
| `node.fields()`                         | read-only mapping of effective fields   |
| `node.diagnostic(message, related=())`   | new diagnostic bound to this heading    |

Paths and field lookup follow the common case-insensitive name rules.
[Typed headings](wiki-format.md#typed-headings) determine `type` and `name`.
For `User:Alice`, these are `"user"` and `"alice"`. An untyped heading has
`type is None` and a normalized name. Paths consist of the page namespace and
normalized names, without types. For example, `/users/staff/alice` addresses
`User:Alice` under `staff` in `users.wiki`.

Use normalized names for identity and comparisons. `node.title` provides
the original name part for display. It preserves case and internal whitespace.
It belongs to the node itself and never changes through assignments or use.
Original complete headings and field spellings remain in diagnostics.
There are no public label properties.

`wiki.normalize(text)` exposes the shared name transformation for producers
and processors. It does not validate a filename or normalize field values.
Field lookup and type selection use this same function.

The type is a node attribute, not part of its path or an effective field.
Neither inheritance nor use changes the node's type or name. The parser
splits the title but leaves the meaning of
types such as `user`, `group`, and `abo` to the processor.

Effective fields include parent defaults, resolved use imports, and automatic
`<type>-id` and `<type>-title` defaults. A
consumer does not call a second domain-level resolver. There is at most one
effective value per normalized field name.

```python
field = node.field("sender")
if field is not None:
	process_sender(field.text)
```

An empty field is present and has `text == ""`. It is different from the
absence result `None`. `fields()` maps normalized lowercase names to field
objects. Every mapping key equals its field's normalized `name`.
`field("Sender")` and `field("sender")` select the same effective field.

Both accessors always return resolved values. There are no switches for local
versus inherited fields or for following use. The parser keeps source
structure internally for resolution, validation, and explanation.

## Fields

Field values remain strings. The parser performs additive list operations
under the shared format rules. Domain interpretation, normalization, and
deduplication belong to processors. The public field surface is:

| access                                 | meaning                                 |
| -------------------------------------- | --------------------------------------- |
| `field.name`                            | normalized lowercase field key          |
| `field.text`                            | resolved text value                     |
| `field.diagnostic(message, related=())`  | new diagnostic bound to the field       |

Fields expose the final text after ordered assignments and imports. A caller
cannot inspect or replay the operations through the public API. Replacing a
value discards its previous contributors; adding retains the contributors
of both operands. Original assignment spelling is available only in diagnostics.

## Diagnostics

A `Diagnostic` connects a plain-text `message` with its source context.
Nodes and fields create diagnostics without formatting, output, or raising an
exception:

```python
diagnostic = field.diagnostic("invalid expiry date")
diagnostic = node.diagnostic('required field "recipient" missing')
diagnostic = node.diagnostic(
	'duplicate user "Alice"',
	related=(other_node,),
)
```

Node diagnostics bind the heading as their primary source. Field diagnostics
bind every assignment contributing to the effective value, including its
internal inheritance and use context. Optional `related` nodes or fields
identify additional involved definitions without replacing the primary source.
A missing required field is diagnosed on the node because no field exists.

For messages without a Wiki source, direct construction is available:

```python
diagnostic = wiki.Diagnostic(message="unsupported input version")
```

The same diagnostic type represents parser input errors and domain validation
errors. Consumers can read `diagnostic.message`. Source binding is internal:
consumers do not traverse origin objects or inheritance chains.

## Rendering

The common renderer returns text without writing to stdout, stderr, or logs:

```python
report.text(diagnostic, context=False)
report.markdown(diagnostic, context=False)
```

Text output includes readable source coordinates and the message:

```text
users.wiki:12: unknown group "editros"
```

Markdown output escapes the message as literal text and uses the shared
processor contract's machine-readable source references:

```markdown
- `source:users.wiki:12`: unknown group "editros"
```

Compact output names every distinct contributing assignment once. Related
definitions remain identifiable as additional sources. Without a source, only
the message is rendered. Formatting never invents a Wiki source for an
envelope-level error.

With `context=True`, the renderer additionally explains how a value reaches
the consuming node. It includes relevant parent inheritance and use positions
in source-to-consumer order. For example:

```text
shared.wiki:12: invalid sender
used at templates.wiki:8
used at customers.wiki:24
```

When several routes contribute, each route stays associated with its source.
A local overriding field is attributed to its own assignment, not to the
overridden values. Node context can identify the heading path and containing
section. Imported fields do not change the node's defining source.

There is one context flag, not separate short/long and context modes. Output
is deterministic. The processor owns the decision to write it as part of a
Markdown report, on stderr, or to a log. Nodes and fields do not expose a
separate source-formatting method.

## Internal source locations and report rendering

Locations identify a source page and one-based physical line and column.
Columns count Unicode code points in the decoded source line. Coordinates
refer to the original page, including comments and include lines, not to JSON
serialization or concatenated input.

Comment removal and line-ending normalization preserve those coordinates.
The implicit page root uses the start of its source as its location. A use
directive has its own location as well as a target path.

Locations contain source identities, not instructions to open files. The
controller owns the mapping from input source identities to local files and
published report links.

Inherited and imported fields retain original assignments and their routes
internally. That information is specific to the consuming node. Importing a
field elsewhere must not change another consumer's diagnostic context.

The shared report renderer uses structured coordinates directly to construct
reserved references. It never reparses readable source descriptions. Text and
Markdown are separate renderings of the same internal information.

## Errors

`wiki.Error` signals failed input validation and holds a nonempty tuple of
diagnostics in `error.diagnostics`. It is the common exception for expected
parser and domain-input errors, not a replacement for programming exceptions.

The parser collects independent errors wherever further checking is reliable.
Malformed JSON can prevent all page parsing. An invalid template should be
reported at its cause rather than repeated for every dependent record.
Diagnostics are returned in deterministic order, and no partially resolved
document is exposed.

Domain processors use the same mechanism:

```python
diagnostics = []
for node in document.nodes(type="user"):
	field = node.field("expires")
	if field is not None and not valid_expiry(field.text):
		diagnostics.append(field.diagnostic("invalid expiry date"))

if diagnostics:
	raise wiki.Error(diagnostics)
```

Constructing a diagnostic does not stop processing. Raising `wiki.Error`
signals that a complete valid result cannot be produced. A processor must not
emit a successful partial configuration when some records fail validation.

```python
try:
	document = wiki.parse_json(text)
except wiki.Error as error:
	for diagnostic in error.diagnostics:
		print(report.markdown(diagnostic, context=True))
```

`str(error)` renders all contained diagnostics as readable text with compact
source context, using the same formatting rules as `report.text()`. It does
not expose object representations. The explicit rendering helpers provide
Markdown or expanded context when required.

Errors carry a concise message, a primary source location when available, and
related locations or a dependency chain where useful:

| condition              | useful context                              |
| ---------------------- | ------------------------------------------- |
| duplicate namespace    | both source filenames                       |
| duplicate heading path | both heading locations                      |
| invalid additive list  | operation and affected operand assignments  |
| missing typed name     | heading location and declared type          |
| missing use target     | directive location and requested path       |
| dependency cycle       | parent/use chain with relevant locations    |
| unfinished comment     | opening marker                              |

JSON errors belong to the input adapter and may have envelope coordinates
instead of a Wiki location. Errors must not invent a page location when none
is known. The processor renders these errors through the shared
[source-reference contract](wiki-processor.md#reports-and-source-references).

Unknown groups and invalid values of supported domain fields are processor
errors. Domain contracts define which types and fields are consumed or
ignored. Unexpected programming errors are not
converted into successful empty documents or ordinary user-input errors.

## API boundaries

The public API exposes resolved records and diagnostic creation, not Wiki tree
navigation or inheritance mechanics. Field mappings are read-only, node
collections and exception diagnostics are tuples, and source input can be any
iterable. Implementation choices must preserve these observable behaviors.

There are no processor-specific switches for name comparison, default
precedence, list addition, or use resolution. The shared formatter owns
diagnostic presentation, and the processor owns domain meaning and output.
