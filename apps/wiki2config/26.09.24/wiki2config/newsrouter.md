[back to overview](overview.md)
---

# Newsrouter subscriptions in the Wiki

Use this guide to write customer subscriptions and reusable news profiles in
the Wiki. It describes the shared Wiki syntax and the field names already
produced by profile migration.

Newsrouter delivery integration is planned. The current newsrouter application
does not load generated subscriptions or deliver news. The examples below are
valid Wiki configuration examples, not an activation procedure or a complete
supported delivery interface. Filter matching, delivery scheduling, and
transport validation still need a finalized Newsrouter contract.

## Start with one customer

A customer contains one or more subscriptions. Each heading starts a section.
Use `kunde:` for the customer and `abo:` for each subscription. Fields start
with `*`, followed by a name, a colon, and the value.

```text
= kunde: Example newsroom =
* kunde-id: example_newsroom
* format: eml
* format.from: news@example.org
* format.to: newsroom@example.org
* transport: mail
* transport.recipients: delivery@example.org

== abo: Regional news ==
* abo-id: regional
* dienst: lwd
* schlagworte: *
* ortsmarke: *
* zeitraum: 1.1.2026 - 31.12.2026
```

The subscription inherits the customer's format and delivery fields. Its
identity is `example_newsroom/regional`, using `kunde-id` and `abo-id`.
That pair is intended to identify the delivery queue independently of the
Wiki page name. Keep it unique across all subscription pages.

`format.to` is the visible mail header. `transport.recipients` identifies
the actual delivery recipients. Changing the visible header does not change
who should receive the message.

## Headings and stable names

| heading | purpose | automatic fields when absent |
| ------- | ------- | ---------------------------- |
| `= kunde: Example newsroom =` | customer defaults | `kunde-id: example_newsroom`, `kunde-title: Example newsroom` |
| `== abo: Regional news ==` | subscription | `abo-id: regional_news`, `abo-title: Regional news` |
| `== profil: West news ==` | reusable profile | `profil-id: west_news`, `profil-title: West news` |
| `= profiles =` | grouping section | none |

The number of `=` characters sets the nesting level. A heading inherits from
the nearest preceding heading with a lower level. Only `abo` headings are
intended as subscriptions. A profile or grouping heading alone creates no
subscription.

Automatic IDs use lowercase names, convert German umlauts to `ae`, `oe`, and
`ue`, convert sharp s to `ss`, and replace whitespace with underscores.
Explicit field values are not automatically normalized. Use stable, portable
IDs such as `example_newsroom` and `regional`. An explicit ID keeps the
subscription identity unchanged when its heading is renamed.

Identity defaults apply only when a field is absent. Inherited, imported, or
explicit empty IDs prevent that default. Keep customer fields on customers,
profile fields on profiles, and subscription IDs on subscriptions. Importing
another subscription can copy its `abo-id` too.

The same heading name may occur under different customers. A complete heading
path must be unique within its page. See the full
[heading and identity rules](submodules/configflow/docs/wiki-format.md#headings-and-paths).

## Reuse a profile

Put common selection and formatting fields in a profile. Import it into each
subscription with `/use`. This complete single-page example defines two
subscriptions with different recipients:

```text
= profiles =
* format: eml
* format.from: news@example.org
* format.to: newsroom@example.org
* transport: mail

== profil: West news ==
* dienst: lwd
* schlagworte: *
* ortsmarke: *
* format.subject-prefix: West
* format.text.impressum1: Example publisher
* format.text.impressum2: Contact: news@example.org

= kunde: Example newsroom =
* kunde-id: example_newsroom
* transport.recipients: delivery@example.org

== abo: Morning ==
* /use: #profiles/west_news
* zeitraum: 1.1.2026 - 31.12.2026

== abo: Archive copy ==
* /use: #profiles/west_news
* transport.recipients: archive@example.org
* format.subject-prefix: Archive
* zeitraum: 1.1.2026 - 31.12.2026
```

Both subscriptions receive the profile's selection, formatting, and profile
identity fields. Their own IDs are `morning` and `archive_copy`. The second
subscription replaces the inherited recipient and the imported subject prefix.
The heading `Morning` is a name, not a scheduled delivery time.

`#profiles/west_news` starts at the current page root. Reference paths use
heading names without `profil:`, `kunde:`, or `abo:`. `/use` imports fields,
including inherited fields, but does not copy child headings.

## Split configuration across pages

Include every page used by the configuration. For an entry page named
`subscriptions.wiki`, with the Wiki namespace configured as `Config`:

```text
* /include: [[Config:Profiles]]
* /include: [[Config:Customers]]

__NOTOC__
```

Place the `profiles` section from the previous example on `profiles.wiki` and
the customer section on `customers.wiki`. Change both imports on the customer
page to:

```text
* /use: profiles#profiles/west_news
```

The first `profiles` identifies the page filename without `.wiki`. The second
identifies the grouping heading. Include links use Wiki brackets and the
configured Wiki namespace. Use references have neither.

Includes must appear at the very beginning, before comments, headings, prose,
or `__NOTOC__`. Blank lines are allowed between them. `/use` does not load a
page by itself. Defaults do not cross page boundaries unless imported. See
[includes](includes.md) for page naming and resolution.

## Replace, extend, and clear fields

Each section starts with its parent's resolved fields. Its own assignments
and `/use` directives are then applied in their written order. A later
assignment replaces the previous value. Put subscription-specific overrides
after the profile import.

```text
* /use: #profiles/west_news
* transport.recipients: first@example.org
* transport.recipients +: second@example.org
* format.subject-prefix:
```

The resulting recipient text is `first@example.org, second@example.org`.
The empty prefix clears the inherited prefix. Use `+:` only for list values:
it splits on commas, preserves duplicates, and rejects empty list entries.
It does not perform address validation.

`/use +:` extends every imported field as a comma list, including IDs and
titles. Use ordinary `/use:` for complete profiles. Reserve additive imports
for templates containing only suitable list fields.

Customer defaults must precede the first subscription heading. Fields below
that heading belong to the subscription, not to the customer. Sibling
subscriptions do not inherit from each other. A horizontal rule (`----`)
does not end a section or reset defaults.

## Field reference

These are the Wiki authoring names used by profile migration. Required-field
validation and the complete accepted field set for Newsrouter delivery are
not finalized. A field's presence in this table does not imply that delivery
currently consumes it.

| field | use |
| ----- | --- |
| `kunde-id` | stable customer identity, inherited by its subscriptions |
| `abo-id` | stable subscription identity within the customer |
| `kunde-title`, `abo-title` | display titles supplied by typed headings when absent |
| `profil-id`, `profil-title` | reusable profile identity and title, imported with the profile |
| `dienst` | service selection, for example `lwd` or `bas` |
| `schlagworte` | keyword selection, `*` is used by migration for unrestricted selection |
| `ortsmarke` | location selection, `*` is used by migration for unrestricted selection |
| `zeitraum` | subscription period, `D.M.YYYY - D.M.YYYY` or `D.M.YYYY -` |
| `format` | output format, `eml` for the mail examples |
| `format.from` | visible From header |
| `format.to` | visible To header, independent of actual recipients |
| `format.subject-prefix` | prefix before `: ` and the news headline, empty means no prefix |
| `format.charset` | requested text encoding, the current mail formatter defaults to `utf-8` |
| `format.text.impressum1`, `format.text.impressum2`, ... | numbered imprint paragraphs, rendered in numeric order |
| `transport` | delivery method, `mail` for the examples |
| `transport.recipients` | actual mail recipients |

Selection values above describe the migrated configuration vocabulary.
Newsrouter's exact matching rules, combinations of filters, handling of empty
filters, and supported selection expressions are still open. Do not infer
AND/OR behavior, regular expressions, or exclusion syntax from these examples.

An open period omits the end date. The existing fixed profile CSV export treats
it as 31 December 2037 and uses inclusive dates. Newsrouter's handling of open
periods, date boundaries, and timezones is not yet specified. A valid Wiki
date value alone does not activate or schedule delivery.

The Wiki name `format.subject-prefix` differs from the current mail formatter
parameter `subject_prefix`. Likewise, `dienst`, `schlagworte`, and `ortsmarke`
are Wiki names, while the router draft uses `service`, `keyword`, and
`location`. Automatic translation is not yet an available delivery feature.
Use the Wiki names in this guide when editing migrated pages.

Each field occupies one physical line. Write separate numbered fields for
imprint paragraphs. To suppress an inherited imprint, clear every inherited
imprint paragraph field. Migration omits suppressed imprint fields and uses
no general `optionen` field in its output.

## Optional profile CSV fields

The same subscriptions can also supply the separate profile CSV export.
Set `csv-name` only for subscriptions that should participate in that export.
It selects the output directory, not a Newsrouter queue or mail recipient.

The CSV export also requires `kunde-id`, `abo-id`, `profil-title`, and
`zeitraum`. Optional copied fields are `kundennummer`, `name`,
`ansprechpartner`, `adresse`, `telefon`, `bestelldatum`, and `monatspreis`.
They do not define news selection or mail formatting.

A direct mail subscription can omit `csv-name` and all profile fields, as in
the first example. The CSV export then ignores it.

## Review and common corrections

Before handing configuration to an operator, check customer and subscription
IDs, periods, imported profiles, and actual recipients. Valid shared Wiki
syntax confirms structure and references, not complete delivery validity.

| symptom | check or correction |
| ------- | ------------------- |
| profile reference cannot be resolved | include its page and use `page#heading/path`, without type prefixes or Wiki brackets |
| unexpected recipient or prefix | put the override after `/use` and inspect fields supplied by the profile |
| customer default affects only one subscription | move the field above the first `abo` heading |
| duplicate heading path | rename one heading under that parent |
| duplicate subscription identity | assign distinct `abo-id` values within that customer, including across pages |
| template dependency cycle | remove the circular import, including any import of a descendant |
| renamed heading changes an identity | set an explicit stable ID and update references to renamed headings |
| changed To header does not change intended recipients | edit `transport.recipients` |

For all shared syntax details, including comments and name normalization, see
the [Wiki format reference](submodules/configflow/docs/wiki-format.md).
Once a delivery processor is available and configured, operators should review
the conversion report described in [operation and recovery](operation.md)
before relying on generated configuration.
