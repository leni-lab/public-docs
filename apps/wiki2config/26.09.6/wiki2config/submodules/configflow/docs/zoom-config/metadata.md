[back to overview](../../../../overview.md)
---

# Configuration metadata contract

Status: implemented by configflow.zoom_config.metadata for consumers and
producers.

This contract defines optional, producer-maintained metadata comments for
line-oriented configuration formats. It is independent of a particular producer,
consumer, and configuration schema.

The configuration format must use `#` for comments and define recognizable file,
section, and assignment boundaries. A format that cannot preserve these comments
may represent the same metadata semantics differently.

## Syntax

A metadata comment has the exact form:

```text
# @meta: <key>: <value>
```

The separators are exactly one ASCII space after `#`, and one after each colon.
Keys use ASCII letters and hyphens. Matching ignores case. Producers emit
lowercase keys. Values occupy the remainder of the line and cannot contain
control characters. Metadata comments are never configuration assignments and do
not alter the configuration's semantic content.

## Scope

Position binds a contiguous metadata block to a configuration item:

- file scope: the block starts on the first line, before any section or
  assignment
- section scope: the block immediately follows the section declaration
- key scope: the block immediately follows the complete assignment

A blank line ends a metadata block. Section and key blocks allow no intervening
line. The format contract defines section declarations, assignments, and any
multiline values needed to determine these positions.

Example:

```ini
# @meta: created: 2024-03-12T08:15:00Z

[user alice]
# @meta: created: 2024-03-12T08:15:00Z
groups = editors
# @meta: changed: 2026-09-05T10:29:41Z
```

The first marker describes the logical file. The second describes the section.
The final marker describes the `groups` assignment.

Metadata keys and configuration keys are separate concepts. In this document,
`key scope` means the scope of a configuration assignment.

## Timestamp values

The initial metadata keys use UTC timestamps with second precision. The letters
`T` and `Z` are matched case-insensitively; producers emit uppercase:

```text
yyyy-mm-ddThh:mm:ssZ
```

These timestamps describe producer observations of generated configuration. They
are not exact source edit, import, publication, or activation times. Import and
publication timing belong in the import report.

## Defined keys

### `created`

`created` is the time at which the producer first observed the logical item
appearing in generated configuration.

The producer must not invent `created` for a pre-existing item whose first
appearance is unknown. Deletion followed by reappearance begins a new lifetime
and may receive a new `created` value.

### `changed`

`changed` is the time at which the producer first observed the most recent
semantic change to the logical item after establishing a comparison baseline. It
is omitted until such a change has been observed.

The applicable format contract defines semantic equality. Metadata comments
themselves do not cause `changed` to advance. When those scopes are maintained,
a key change advances the containing section and file if their semantic content
consequently changes.

When both timestamps are present in one scope, `changed` cannot precede
`created`.

## Preservation and validation

A producer preserves valid metadata for unchanged items. It emits at most one
value for each defined key in one scope.

A conforming consumer:

- validates the exact syntax and timestamp value of known keys
- reports malformed, misplaced, or duplicate known metadata
- leaves missing metadata unknown instead of deriving it from file times
- ignores unknown metadata keys for forward compatibility
- does not expose unknown keys or values without an explicit allowlist
- keeps valid configuration data available when only optional metadata is
  invalid

The initial contract defines only `created` and `changed`. A generation time
would change otherwise identical output and belongs in the report. A last
observation time would change on every run and is therefore not defined.

Producer transition rules and canonical key order are specified by the [output
contract](output.md). `metadata.update()` implements those transitions from an
explicit prior mapping, semantic-change decision, and observation time. It is
independent of the application's domain model.
