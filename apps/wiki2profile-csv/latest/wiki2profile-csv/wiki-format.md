[back to overview](overview.md)
---

# Profile CSV input and output

wiki2profile-csv generates the fixed CSV format used for profile
subscriptions. It is separate from newsrouter and a future general billing
exporter. Its output schema and CSV dialect are fixed, not Wiki-configurable.

Input uses the shared Wiki file adapter and resolved node API from configflow.
Only nodes of type `abo` with nonempty `csv-name` participate. Other types,
untyped templates, and records with empty or absent `csv-name` are ignored by
this processor. Shared syntax and use references must be valid on every page.

## Fields

| field | requirement or use |
| ----- | ------------------ |
| `kunde-id` | required customer identifier; supplies the CSV `kunde` column |
| `abo-id` | required identifier within the customer; deterministic row identity |
| `csv-name` | required single output directory component for participating records |
| `profil-title` | required profile label; lowercased for the CSV `dienst` column |
| `zeitraum` | required inclusive date range |
| `kundennummer` | copied, empty if absent |
| `name` | copied, empty if absent |
| `ansprechpartner` | copied, empty if absent |
| `adresse` | copied, empty if absent |
| `telefon` | copied, empty if absent |
| `bestelldatum` | copied, empty if absent |
| `monatspreis` | copied, empty if absent |

Fields are resolved before selection. Defaults and use references work without
domain-specific inheritance. Typed headings supply the common automatic
ID and title fields.
`format` and `transport` describe delivery and are not CSV settings.

`kunde-id`, `abo-id`, and `csv-name` use lowercase ASCII letters, digits, `.`,
`_`, and `-`, starting with a letter or digit and not ending with a period.
They are portable single directory components and exclude Windows device names, also with extensions. The
`profil-title` label is lowercased for CSV output but retains internal spaces
and umlauts, matching the legacy profile name. `profil-id` and `format.subject-prefix`
do not supply the CSV label.

The same customer, profile, and CSV destination can occur in several delivery
records. Each record generates its own monthly row. Time ranges are not
merged, overlapping days are not deduplicated, and prices are not aggregated.
Within a customer, delivery identifiers remain unique.

## Dates and monthly rows

`zeitraum` has the form `D.M.YYYY - D.M.YYYY` or `D.M.YYYY -`. Day and month
may have one or two digits. Dates are calendar dates and endpoints are
inclusive. The current fixed profile export interprets an open end as
31 December 2037. The end must be strictly after the start.

The invocation supplies an evaluation date. Its month and the three preceding
calendar months form the export window. With an evaluation date in October
2021, the window is July through October 2021, including complete months.
Without an explicit date, use the current date in `Europe/Berlin`.

Intersect each subscription range with each month in that window. A nonempty
intersection creates one row. `monat` is `YYYY-MM`, and `tage` is its inclusive
calendar-day count. Weekends are included. A range outside the window creates
no row. The price is copied unchanged; no prorated amount is calculated.

An invalid range fails processing with its source diagnostic. It must not
silently disappear from an apparently successful billing export.

## Files and ordering

Files have relative names `<csv-name>/<YYYY-MM>.csv`. The technical output
root comes from the export job's `output_path` setting. Names cannot escape that
directory. A month with
no rows produces no file. An entirely empty result is valid for this exporter.

Rows are ordered by normalized customer identifier, profile label, and delivery
identifier. The last component only breaks ties between separate deliveries.
Every produced file starts with the same fixed header:

```text
kundennummer;kunde;name;ansprechpartner;adresse;telefon;bestelldatum;monatspreis;dienst;monat;tage
```

This line shows column names and order, not serialized quoting. Each heading
is quoted by the same rules as every other cell.

## CSV representation

The fixed representation is Windows-1250 without a BOM, semicolon-separated
cells, CRLF row endings, and a final CRLF. Every field is processed as text:

1. encode using the profile format's Windows-1250 conversion
2. double every embedded double quote
3. replace bytes 0x00 through 0x1F with a period
4. leave empty cells and ASCII digit-only cells unquoted
5. surround all other cells with double quotes

Characters outside Windows-1250 become `?`, matching Perl Encode's default
conversion. The conversion and quoting order is fixed.
Missing data becomes empty text. Field spellings are exact: `preis
(monatlich)` does not supply `monatspreis`, and `bestellung von` does not
supply `bestelldatum`.

## Execution and compatibility

The application reads an entry Wiki file and its includes. Each export job's
`output_path` sets its output root. Its `date` setting fixes the evaluation date
for reproducible exports. When empty, the date in Europe/Berlin applies. `--check`
validates and renders without writing. All records are validated before any
output file is written.

Run the application periodically through an external scheduler, even when Wiki
files have not changed. The month window advances with the evaluation date.
Only one instance may write to a given output root at a time.

### File retention

Only generated files are published. Changed files are replaced atomically per
file after all new bytes have been staged. Identical files keep their contents
and timestamps. The whole file set is not replaced atomically. A failure during
replacement may leave some months updated and others unchanged. A subsequent
successful run for the same evaluation date completes the update.

Existing files absent from the generated result remain untouched. This applies
both to older months and to months inside the export window that now have no
rows. An entirely empty result changes no files. Consequently, retained files
can represent an earlier Wiki state even after a successful export. There is
no automatic cleanup, header-only replacement, or INI metadata injection.

Compatibility checks use an explicit shared evaluation date. Customer
identifiers replace customer-title values. Multiple deliveries retain separate
rows. Invalid input prevents publication and provides source diagnostics.
