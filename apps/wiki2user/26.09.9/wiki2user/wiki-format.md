[back to overview](overview.md)
---

# Wiki format

Supported content for local Wiki pages supplied to wiki2user.

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

Use level-two headings for areas and level-three headings for entries.
Legacy level-one areas with level-two entries are also accepted. Use one
heading convention consistently within a page.

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

- fields between an area heading and its first entry supply defaults
- defaults reset at each area heading and page boundary
- an entry's list replaces the default list, it does not extend it
- an empty list clears the inherited default
- field names and area headings are case-insensitive
- entry names and references are case-sensitive
- duplicate entries or repeated fields within an entry are errors
- names must be representable in Windows-1252 and valid as INI names

Use simple, stable names without INI delimiters or comma separators.
Unknown fields are errors. Records in a `Settings` area are not supported.

## Includes

An entry page can include additional pages:

```text
include: [[Config:Groups]]
include: [[Config:Permissions]]
```

Only the `Config` namespace is supported. Page names become lowercase local
filenames with spaces replaced by underscores and `.wiki` appended.
`Config:User Groups` therefore reads `user_groups.wiki` beside the entry.
Include filenames use ASCII letters, digits, periods, underscores, and
hyphens. Unsafe paths and reserved Windows device names are rejected.

Includes can be recursive. Missing pages and include cycles stop conversion.
Every included page defines its own area headings and defaults.

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
