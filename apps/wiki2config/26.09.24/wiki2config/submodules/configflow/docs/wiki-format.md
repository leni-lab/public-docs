[back to overview](../../../overview.md)
---

# Wiki format

This document defines the shared configuration language for Wiki authors.
The [parser contract](wiki-parser.md) describes access to the resulting data.
The [processor contract](wiki-processor.md) describes how named pages reach a
processor. Domain processors define record types and field meanings.
Field names in the examples illustrate the shared language, not a domain's
complete field schema.

## Pages and namespaces

Each file defines one page and one namespace. Remove the final `.wiki`
extension, matched case-insensitively, and normalize the remaining filename
to obtain the namespace. The namespace must be nonempty and have no surrounding whitespace:

| file               | namespace     |
| ------------------ | ------------- |
| `example.wiki`     | `example`     |
| `shared.wiki`      | `shared`      |
| `user_groups.wiki` | `user_groups` |

A page has an implicit root. Fields at that root supply defaults to its
headings. Defaults never cross page boundaries implicitly. A `use` directive
can explicitly import values from another page.

The page namespace is distinct from a MediaWiki namespace such as `Config`.
The latter identifies the source pages in include links. For example,
`Config:User Groups` maps to `user_groups.wiki`, whose configuration namespace
is `user_groups`.

Namespaces, heading names, types, field keys, and reference components use one
normalization rule: trim outer whitespace, convert to lowercase, expand German
umlauts (`ae`, `oe`, `ue`) and sharp s (`ss`), and replace each internal
whitespace run with `_`. Periods, hyphens, underscores, other punctuation,
and other Unicode characters remain unchanged. Directive keywords are
case-insensitive.

Normalization does not replace syntax or domain validation. For example,
`.` and `..` remain invalid complete path components, and processors check
whether IDs are suitable for their output folders. Distinct spellings that
normalize to the same complete heading path or page namespace are errors.
Equivalent field keys instead follow normal ordered assignment rules.

Node titles preserve the name part's original spelling without type or
outer whitespace. Field values retain case, umlauts, and internal whitespace
except when processed by an additive list operation. Explicit ID fields are
values and are not automatically normalized.

Two pages with the same normalized namespace are an error. Moving or renaming
a heading changes its path. Renaming a file changes its namespace and requires
updating cross-page references to it. Local references remain page-relative.

## Headings and paths

A heading occupies a complete line with matching, nonempty runs of `=` around
a nonempty title:

```text
= templates =
== mail ==
* sender: service@example.org
```

The number of `=` characters gives its level. A heading belongs to the nearest
preceding heading with a lower level, or to the page root. Skipped levels do
not create additional nodes. There is no fixed maximum level.

Every field, directive, and text line belongs to the current node. A new
heading closes preceding nodes at the same or deeper level. There is no
implicit return to a parent section.

In `example.wiki`, the heading above has the absolute path
`/example/templates/mail`. The page root has path `/example`. A complete
heading path identifies exactly one node.

- repeated complete paths are errors, including case-only differences
- repeated names under different parents or in different pages are allowed
- headings with the same path are never merged
- `/` is reserved as the path separator and cannot occur in a heading title
- `#` separates the page from the heading path in references and cannot occur
  in a heading title or page namespace
- `.` and `..` are not valid complete heading names or namespace components
- backslashes and control characters are not permitted in path components

### Typed headings

A heading can declare a type and a name:

```text
== user: Alice ==
```

The first colon separates the type from the name if the text before it,
trimmed of surrounding whitespace, is a valid type identifier. A type starts
with a Unicode letter and continues with letters, digits, `_`, `-`, or `.`.
Internal whitespace is not allowed in the type token. Its spelling uses the
common normalization rule.

Whitespace around the separating colon is syntax padding. The name is the
entire remaining text, normalized by the common rule. It must not be empty.
Further colons belong to the name. The original name part, without outer
whitespace, is the node title.

| title                     | type      | name                     |
| ------------------------- | --------- | ------------------------ |
| `user: Alice`             | `user`    | `alice`                  |
| `User:Alice`              | `user`    | `alice`                  |
| `USER : Alice`            | `user`    | `alice`                  |
| `abo: Customer: North`    | `abo`     | `customer:_north`        |
| `templates`              | none      | `templates`              |
| `Delivery notes: Mail`   | none      | `delivery_notes:_mail`   |
| `Notes: Delivery`        | `notes`   | `delivery`               |
| `user:`                  | error     | missing name             |

If no colon is present, or its left side is not a valid type identifier, the
heading is untyped and its complete title is its name. Grouping titles such
as `customers` and `templates` are untyped. A single identifier followed by a
colon is reserved for typing, including otherwise ordinary words such as
`Notes`. Use a title such as `Delivery notes` for untyped documentation.

Only the normalized name identifies a heading in its path. The type is an
attribute, not a path component. Under the same parent, `user: Alice`,
`group: alice`, and untyped `ALICE` are duplicate definitions. Changing only
the type leaves paths and references unchanged.

For example, `user: Alice` under `staff` in `users.wiki` has the path
`/users/staff/alice`. A local use reference is `#staff/alice`. Reference path
components are names, not titles: colons within a name are literal and are
never interpreted as type separators during reference lookup.

The parser recognizes every syntactically valid type identifier without a list
of domain types. A processor selects the types it supports. Other types can
belong to another processor sharing the same pages. Domain contracts define
their field schemas and handling of unused input.

Type, name, and original title belong to the node itself. They are never
inherited from parents or imported by use. A field assignment cannot change
the type declared by a heading.

### Automatic identity fields

After inherited fields and all local instructions, including use operations,
have been resolved, each typed node supplies two missing fields:

- `<type>-id`: the normalized node name
- `<type>-title`: the original name part, without type or outer whitespace

Each default applies independently and only if that field is absent.
Existing fields from parents, use, or local assignments win, including empty
values. The defaults are ordinary fields, with the heading as their diagnostic
source. Children inherit them and use imports their finished values.
Untyped headings and page roots create no identity fields.

```text
= profiles =
== profil: West aktuell ==
* dienst: lwd

= kunde: Profil Frerichs =
== abo: Morning ==
* /use: #profiles/west_aktuell
```

The subscription has `kunde-id: profil_frerichs`, `kunde-title: Profil Frerichs`,
`profil-id: west_aktuell`, `profil-title: West aktuell`, `abo-id: morning`,
and `abo-title: Morning`. Its own name and title remain `morning` and `Morning`.

These defaults have no domain-specific uniqueness rule. Processors validate
the identities they use. To keep an ID independent of a heading rename,
set the field explicitly. A same-type parent or use target can supply an
identity too; set an explicit local value when a different identity is needed.
Additive use treats generated fields like all other fields, including the
comma-list rules.

## Fields

A field assignment occupies one physical line. It either replaces or extends
the current value:

```text
* name: value
* name +: value
```

There is exactly one leading `*`. The first colon separates a nonempty field
name from its value. A terminal `+` before that colon selects addition and
is not part of the name. Padding around the name, operator, and value is
removed. `name+: value` and `name + : value` have the same meaning as
`name +: value`. Further colons belong to the value. Names cannot begin with
`*`, end with `+`, or contain a colon. `/include` and `/use` are reserved
directives. Their old names `include` and `use` remain reserved and cannot be
field names.

Repeated assignments are allowed and evaluated in order. An ordinary
assignment replaces the entire current value, including with an empty value.
An additive assignment appends list elements to the current value. An
assignment to a previously absent field creates it, even when the result is
empty. Empty and absent fields are distinct.

### Additive lists

Addition treats both the current text and the added text as comma-separated
lists. An absent current field or empty text represents an empty list.
Surrounding whitespace is removed from each element. Elements retain their
case, internal whitespace, order, and duplicates. The result is text with
elements separated by `, `. There is no domain-specific normalization.

An empty addition adds no elements. Empty elements in nonempty list text,
such as `read,,write` or `read,`, are errors. There is no quoting or escaping
for commas within individual elements.

```text
* permissions: records.read
* permissions +: records.search, records.read
* permissions +: records.write
```

The result is `records.read, records.search, records.read, records.write`.
Whether repetitions are meaningful is a domain decision.

Ordinary assignments and replacing imports do not interpret commas. For
example, `* subject: Hello, editors` remains text. Only an additive operation
interprets its operands as lists. Dates, flags, rights, and transport
addresses otherwise receive meaning only from a domain processor.

## Defaults

Resolved fields of the parent supply defaults to a child. A child's own field
replaces a value inherited for that key. An explicit empty value also replaces
it. Siblings do not inherit from each other.

```text
= customers =
* options: noprefix, noimprint

== abo: A ==
* recipient: a@example.org

== abo: B ==
* options:
* recipient: b@example.org
```

A receives both option names as one text value. B receives an empty `options`
value. An ordinary local assignment replaces the complete inherited value;
an additive assignment extends it.

Defaults apply throughout the node's subtree, not to following sibling
sections. Each node starts with its parent's resolved values, then applies
its own field assignments and use directives in source order. The first
child heading closes its parent's local instructions; later lines belong to
that child or another following heading.

## Use

Use imports resolved fields from another heading:

```text
* /use: #templates/mail
* /use +: shared#text/imprint
```

Each directive occupies a complete line with exactly one leading `*`, the
keyword `/use`, a colon, and exactly one target.
Multiple directives are allowed, interleaved with field assignments. The
optional `+` before the colon selects addition; padding around it is ignored.
The complete trimmed remainder after the
colon is the reference, so spaces and commas in titles are not list separators.
Targets have no Wiki-link brackets or display labels.

| reference            | resolution                    |
| -------------------- | ----------------------------- |
| `#templates/mail`    | from the current page root    |
| `shared#text/imprint` | from the named page namespace |

Exactly one `#` separates the optional page namespace from the required
heading path. An omitted namespace selects the current page. An explicit
namespace is the normalized filename without `.wiki`, not a MediaWiki
namespace such as `Config`. Both forms start at the selected page root,
not the current heading. `/` separates heading names after `#`.

Path components are nonempty. Leading or trailing component whitespace,
leading or trailing `/`, and relative-navigation components are invalid.
References target headings, not page roots. Lookup normalizes the page
namespace and each path component and never falls back to a search in other
pages. These are configuration references, not MediaWiki section anchors.

Only pages selected by the entry page and its includes are available. Use does
not read a file or implicitly include a missing page. Forward references are
allowed because resolution follows the structural reading of all pages.

A use directive belongs to its containing node. It imports all resolved fields
of its target, including the target's defaults and imports. It imports no
type, name, title, child nodes, or prose. ID and title fields are ordinary
fields and are imported. Nested local references
retain the namespace of the page where they were written.

`/use:` replaces each supplied field's current value. `/use +:` appends each
supplied field's resolved text using the additive list rules. Both leave
fields not supplied by the target unchanged. An explicit empty target field
clears the current value with `/use:` and adds no elements with `/use +:`.
Both forms create a supplied field if it was absent, including an empty one.

The operation applies to every supplied field, including inherited fields.
Templates for additive use should therefore contain suitable list fields.
An ordinary field named `name` has no special treatment and is imported like
any other field.

Use imports finished values, never the instructions that produced them.
An additive assignment inside a template does not make ordinary use additive.
The target's own resolved values do not change when used elsewhere.

### Evaluation order

Resolve each node in this order:

1. take the resolved fields of its parent as defaults
2. apply local field assignments and use directives in source order

Later replacing operations win for the same key. Additive operations extend
the value present at that point. Different values from use targets are not
conflicts. Direct fields have no priority over later use directives.

A repeated additive use appends the target values again. Shared inherited
values can likewise appear more than once when several targets supply them.
The parser does not deduplicate values or use targets. Definition order and
page order do not affect field precedence; only local instruction order does.

```text
= templates =
== standard ==
* sender: standard@example.org
* options: noprefix

== editorial ==
* sender: editorial@example.org

= abo: customer bas =
* /use: #templates/standard
* /use: #templates/editorial
* sender: delivery@example.org
* options +: noimprint
```

The record receives `options: noprefix, noimprint` and its explicit sender.
Without the local sender assignment, `editorial@example.org` wins. Moving
the local sender before the second use also makes that import win.

Every referenced node must itself resolve successfully. A consumer cannot
repair an invalid target by overriding one of its fields. Invalid additive
operations, missing targets, and dependency cycles are errors, even if later
assignments would hide their values.
Cycle detection includes both parent-default and use dependencies. A node
using one of its descendants therefore forms a cycle.

## Includes

Includes select additional pages for the same conversion:

```text
* /include: [[Config:Shared]]
* /include: [[Config:User Groups|Groups]]

__NOTOC__

= customers =
...
```

Each directive occupies a complete line with one `*`, the keyword `/include`,
a colon, and exactly one Wiki link. The configured MediaWiki namespace is
required in every link and compared without case sensitivity. A nonempty
display label is allowed and ignored. Section fragments and trailing text are
not allowed.

Includes occupy the initial block of a page. Blank lines may precede and
separate them. The first other nonblank line ends that block. Comments,
prose, headings, root fields, use directives, and `__NOTOC__` belong after it.
Inline comments are not part of include syntax.

Include selection is performed on the source's initial block before Wiki body
comment processing. Comments cannot wrap, enable, or extend that block. This
keeps the page reader independent of body interpretation.

### Local file mapping

All pages reside directly in the configured entry file's directory. To map an
include target to a filename:

1. validate and remove the configured MediaWiki namespace and colon
2. apply the common name normalization to the page title
3. append `.wiki`

An empty title, `/`, `\`, any `..` sequence, control characters, or an invalid
local filename is an error. There are no directory traversal, cross-directory,
or automatic filename-repair rules. Resolved files must remain inside the
input directory. The entry file is selected explicitly.

For example, `[[Config:User Groups]]` selects `user_groups.wiki`. The filename
then determines its configuration namespace, exactly as for an entry page.

### Page selection

Includes are recursive. Each resolved file is read once per conversion.
Repeated references to a completed page do not duplicate its definitions. An
active include cycle is an error with its include chain. Missing or unreadable
files also fail the conversion.

Include order provides a deterministic traversal order, not value precedence.
Included pages remain independent pages with their own roots and defaults.
Neither includes nor use change the ownership or namespace of a definition.

## Comments, prose, and horizontal rules

In page bodies, `<!-- ... -->` comments are removed before recognizing
headings, fields, and use directives. They may be inline or span lines, do
not nest, and end at the first `-->`. An unfinished comment is an error at its
opening position. Comments cannot continue into another page.

Visible characters on either side of an inline comment join together.
Physical line endings within comments remain, so source line numbers do not
shift and separate lines do not join into one assignment.

Unrecognized content remains prose. Horizontal rules such as `----` are prose
and have no effect on namespaces, defaults, or the current heading. Only the
technical page boundary starts another root. This language does not evaluate
MediaWiki templates, `nowiki` blocks, or rendering behavior switches.

Reserved directives must be well formed. Lines attempting `* /include` or
`* /use` with missing punctuation, missing targets, or invalid placement are
errors rather than silently ignored prose. The old `# include:` and `# use:`
forms are rejected, as are field-like `* include:` and `* use:` forms.
Use targets require `#path` or `page#path`; the old `path` and `/page/path`
forms are rejected. `/include`, `/use`, `include`, and `use` are reserved
directive names, not configurable field names.

## Validation and domain interpretation

The shared parser validates structural identity, field syntax, additive lists,
paths, use references, and dependency cycles. It exposes a complete
resolved document or errors, never a partially usable configuration.

Domain processors select nodes by type and validate their names and fields.
For example, user and group identities can be globally unique within usermgr
even when their Wiki paths belong to different pages. Group membership is a
domain relationship. Reusing field values uses the shared language and does
not itself establish membership or another domain relationship.

A node with enough fields to describe a record does not automatically become
one. Its declared type determines its role in the domain. Processors also define
which fields are configuration, reporting metadata, or unsupported input.
