[back to overview](overview.md)
---

# Operation

## Reading the list

Open the address supplied by your operator. The **news items** table shows
transmission, service, channels, keywords, and title. A source column also
appears when several sources are available.

Items are ordered by transmission time, newest first. Future times appear red
and italic. Times use the server's local time.

A page contains about 50 items. Items with the same transmission time stay
together, so a page can contain more. Long keywords and titles wrap. On narrow
screens, scroll the whole page horizontally to reach the remaining columns.

## Filters

Filters in different columns combine with AND. Empty fields impose no
restriction. Change a field and leave it, or press Enter, to apply the filters.
Selecting suggestions keeps the field active so you can choose several values.

The small help control beside each heading explains the field's syntax.
Each populated field has an `x` control that clears it and applies the change
immediately. The far-right `x` clears all filters and returns to the latest
items. A spinner appears if loading takes longer than a brief moment.

| field        | input                                              |
| ------------ | -------------------------------------------------- |
| transmission | newest allowed time as `YYYY-MM-DD HH:MM:SS`       |
| source       | exact source name                                  |
| service      | one or more exact names separated by commas        |
| channels     | one or more exact names separated by commas        |
| keywords     | exact keywords combined with `,`, `+`, or `&`      |
| title        | words, phrases, and search operators               |

### Services and channels

Click the field to see the available values. Click a suggestion to select it,
and click it again to remove it. Check marks identify selected values.

Several values are displayed with a comma and a space, such as `bas, lnb`.
An item matches if any selected value matches. You can also enter names
directly. An empty field selects all values.

### Keywords

Keyword matches are exact and case-sensitive. Use a comma for OR and a plus
sign or ampersand for AND. There is no quoting or escaping.

| expression                  | matches                                     |
| --------------------------- | ------------------------------------------- |
| `Berlin`                    | the exact keyword Berlin                    |
| `Berlin, Hamburg`           | either keyword                              |
| `Berlin + Politik`          | both keywords                               |
| `Berlin & Politik`          | both keywords, equivalent to plus           |
| `Berlin + Politik, Hamburg` | Berlin and Politik together, or Hamburg     |
| `Deutsche Bahn`             | the single keyword Deutsche Bahn            |
| empty or `*`                | all items, including items without keywords |

Spaces around operators are ignored. Spaces inside a keyword are preserved.
A trailing operator is incomplete and produces a visible error.

Type the beginning of a keyword to see up to ten suggestions, ordered by
frequency. Suggestions ignore case while searching, and insert the keyword's
original spelling. They complete only the keyword at the caret and preserve
the surrounding expression.

Use the arrow keys and Enter, or click a suggestion. Enter first accepts a
highlighted suggestion. Press Enter again, or leave the field, to apply the
filter. Escape closes the suggestions.

Free keywords remain searchable even if they are absent from suggestions.
Keywords containing a comma, plus sign, or ampersand are displayed in the list,
but cannot be entered as a single keyword with this syntax.

### Titles

Title search uses SQLite FTS5 syntax and searches only titles. It retains
chronological ordering.

| expression                   | matches                                  |
| ---------------------------- | ---------------------------------------- |
| `berlin haushalt`            | both words                               |
| `berlin OR hamburg`          | either word                              |
| `"deutsche bahn"`            | the phrase                               |
| `bahn*`                      | words beginning with bahn                |
| `berlin NOT sport`           | berlin without sport                     |
| `(berlin OR hamburg) AND eu` | either city together with eu             |

Operators must be uppercase. Use double quotes for punctuation in title terms.
The [SQLite FTS5 reference](https://www.sqlite.org/fts5.html#full_text_query_syntax)
describes additional expressions.

## Navigation and transmission

| control              | action                                              |
| -------------------- | --------------------------------------------------- |
| double-left triangle | latest items, keeping the other filters             |
| left triangle        | newer items                                         |
| right triangle       | older items                                         |

Unavailable controls are gray. Paging fills the transmission field with the
newest displayed item's time. You can also enter an upper time limit directly,
for example `2026-09-17 12:30:00`. Empty means latest.

Use `YYYY-MM-DD HH:MM:SS` without a timezone, UTC offset, or `T` separator.
The field and navigation links use the same local-time format.

Pages are time windows. Reversing direction may regroup previously seen items.
During the repeated hour at the end of daylight saving time, a local timestamp
cannot identify which occurrence is intended. Navigation in that hour can
repeat or skip a window.

The item count includes every match up to the transmission field's time,
rather than only the visible page. The count therefore decreases as you
browse older items.

Clearing transmission returns to the newest matching items. To refresh while
already at the latest items, reload the page. There is no automatic refresh.

## Sharing and diagnostics

Copy the browser address to share the filters and navigation position with
someone who has access to the same storeview instance. Empty filters are left
out of the address. The matching data can change as the index is updated.

An invalid expression shows an error beside the filters. Correct it or clear
the field. An index error is reported explicitly rather than displayed as an
empty list. Retry or use narrower filters if a query times out.

Suggestions, automatic filtering on leaving a field, and individual clear
buttons require JavaScript. Text input and Enter submission also work without
JavaScript.
