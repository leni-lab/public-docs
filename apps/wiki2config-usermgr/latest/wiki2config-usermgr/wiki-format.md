[back to overview](overview.md)
---

# Wiki format

Supported content for the expanded Wikitext stream supplied to wiki2config-usermgr.

## Example

This complete example can be stored in one entry page:

```text
== Permissions ==
=== read_records ===
* permissions: records.read

== Groups ==
=== readers ===
* permissions: read_records

== Users ==
=== example.user ===
* groups: readers
* expires: 2026-09-30
```

Level-two headings for areas and level-three headings for entries are a useful
convention. Any heading depth is accepted, including skipped levels. A heading
belongs to the nearest preceding heading with a lower level.

Area titles start with `Users`, `Groups`, or `Permissions`. Optional labels,
such as `Users admin` and `Users it`, organize entries but do not create
separate namespaces. Areas can also appear inside documentation containers. Each
direct child heading of an area defines an entry. Further headings beneath an
entry are documentation and do not define additional entries or areas.

## Fields

| area          | field                    | meaning                                                        |
| ------------- | ------------------------ | -------------------------------------------------------------- |
| `Users`       | `groups`                 | comma-separated group names                                    |
| `Users`       | `disabled`               | `1` disables the user, empty or `0` is the default             |
| `Users`       | `expires`                | inclusive expiry date as `YYYY-MM-DD`, empty or `0` means none |
| `Users`       | `mail`, `password reset` | accepted but not emitted or acted on                           |
| `Groups`      | `groups`                 | comma-separated parent groups whose permissions are inherited  |
| `Groups`      | `permissions`            | comma-separated permission names or expressions                |
| `Permissions` | `permissions`            | comma-separated members of a permission bundle                 |

An expiry date ends at 23:59:59 in `Europe/Berlin`, including daylight saving
time. It is written as a Unix timestamp. For example, `2026-09-30` ends at
`2026-09-30T21:59:59Z`. There is no timezone setting.

## Defaults and names

- fields at the page root or in enclosing headings supply defaults
- a field replaces all assignments for that key from higher levels
- defaults from one page never apply to another page
- repeated default fields use the last assignment on the nearest level
- an entry's list replaces the default list, it does not extend it
- an empty list clears the inherited default
- field names and area headings are case-insensitive
- entry names and references are case-sensitive
- duplicate entries or repeated fields within an entry are errors
- names must be representable in Windows-1252 and valid as INI names

Use simple, stable names without INI delimiters or comma separators. Unknown
fields directly in an area or entry are errors. Fields in enclosing
documentation containers are inherited only when supported by the target area.

For example, the page-wide default below applies to both areas, while the `Users
it` default applies only to Bob:

```text
* disabled: 1

== Users admin ==
=== alice ===

== Users it ==
* disabled: 0
=== bob ===
```

## Documentation and comments

Ordinary text is ignored. Other areas, such as `Settings`, may contain data for
other readers. Recognized usermgr areas nested inside them are still processed.
Documentation below an entry may contain arbitrary fields and headings. Direct
children of a usermgr area always define entries, so place a separate
documentation section beside that area or below an entry.

Wiki comments (`<!-- ... -->`) are ignored everywhere, including multiline
comments and comments inside a line. Unterminated comments are errors. Malformed
headings and incomplete known fields within usermgr areas or entries are errors.
A page set with no recognized usermgr area is also an error.

## Expanded input and horizontal rules

wiki2config-usermgr reads an already expanded UTF-8 stream without a BOM. It does not open
input files or resolve includes. Both old and new unexpanded include directives
are errors. The separate wiki2config assembler resolves `# include:
[[Config:Groups]]` before starting this processor.

A complete line of at least four ASCII hyphens starts a new root. The exact
number of hyphens is immaterial. The line starts in column one and contains no
other text. Users can write the same rule explicitly:

```text
* disabled: 1
== users ==
=== alice ===
----
== users ==
=== bob ===
```

Alice inherits `disabled: 1`. Bob has no inherited flag. Records collected
before a rule remain part of the result, and duplicate names across roots are
still errors. Global physical line numbers continue after each rule.

Rules are recognized before comments. Every comment must close within its root.
A rule inside an open comment ends that root and exposes the unfinished comment
as an error, rather than hiding the following input.

## Reference rules

- an unknown group assigned to a user is omitted with a warning
- an unknown parent group is an error
- group inheritance contributes permissions without adding parent memberships
- group cycles and cycles between permission bundles are errors
- a permission bundle may include its own name as a leaf right
- a permission token without a bundle definition remains a leaf right

A misspelled leaf permission cannot necessarily be detected by conversion.
Review the resulting rights as well as the warnings. See
[operation](operation.md) for reports and generated files.
