# Overview

newsview is a read-only news reader for a newsindex database. It brings
store timestamps, services, channels, keywords, locations, and titles into
one compact browser view.

## Capabilities

- newest-first list with navigation to older and newer news
- filters in column headers, with several services and channels selectable
- keyword and location combinations with suggestions for frequent values
- title search with words, phrases, and operators
- matching-item counts and links that retain filters and reading position
- optional stored-item display in one reusable detail tab, separate from source links

The interface is English.
Times use the server's local time, which may differ from the reader's time.

When configured, the stored-item view shows original JSON through Newsrender.
It does not yet provide an article preview. Automatic refresh is optional and
pauses while filters or draft edits are active.

## Getting started

Ask your operator for the newsview address and open it in a browser. Start
reading the newest items, or enter a filter in a column header. Leave the field
or press Enter to apply it.

Use the right triangle for older items, the left triangle for newer items,
and the double-left triangle to return to the latest matching news.
An empty filter means no restriction.

## Documentation

- [reading, filtering, and navigation](operation.md)
- [installation, settings, and troubleshooting](settings.md)
- [license](LICENSE)
