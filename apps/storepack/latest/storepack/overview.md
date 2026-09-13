# Overview

storepack reduces the space occupied by older individual files in a store.
It groups files into daily ZIPs, which remain working store contents.

```text
store/
    <recent individual files>
    2026-09/
        2026-09-10.zip
        2026-09-11.zip
```

## Dates and eligibility

Filenames must start with nonnegative integer Unix seconds followed by a
period and a nonempty suffix, for example `1789036496.0.data.json`.
The suffix is arbitrary. It is not a fractional part of the timestamp.

The local system timezone determines the calendar day. A complete day becomes
eligible 48 elapsed hours after the next local midnight by default. For
example, September 12 becomes eligible on September 15 at 00:00 if no clock
change occurs during that interval. Daylight saving changes can shift the
local eligibility time. File modification and arrival times do not affect age.

Only matching regular files directly in the store are selected. Subdirectories
are not scanned. Unsupported names and linked files remain in place and are
reported. The [settings](settings.md) control the filter and minimum age.

Late files for an eligible day are included on the next run. An existing ZIP
is rebuilt while retaining its previous entries. Identical name and content
count as already packed. The same name with different content is an error.

## Preservation and operating contract

File names and content bytes are preserved. There is no manifest. Original
filesystem metadata such as exact modification times, permissions, ownership,
alternate data streams, and extended attributes is outside this contract.
ZIP entry dates reflect the filename time within the basic ZIP date range and
precision. The original filename remains the authoritative timestamp.

Producers must publish complete files and leave them unchanged once visible.
Consumers must support both individual files and daily ZIPs. Only one
storepack writer may run per store. Other software must not edit or replace
the ZIPs while storepack runs. Keep the system timezone consistent between
runs.

Before deleting originals, storepack verifies the complete replacement ZIP
and checks that each source still matches the selected file and its content.
An interruption can leave duplicates. Running again completes the cleanup.
See [restoring files](restore.md) for reversal.

## When not to use

- consumers require every file to remain directly accessible in the store
- producers modify files after publication
- exact filesystem metadata must survive extraction
- the storage system does not support reliable file locks and replacement

Start with the [quickstart](quickstart.md).
