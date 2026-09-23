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

For a newsstore, filenames must follow the [newsstore contract](https://github.com/leni-lab/newsstore/blob/main/docs/store-contract.md),
for example `1789306733_001.leni.json`. Storepack reads only the leading
ASCII digits as Unix seconds. Its parser also accepts other suffixes, but
that broader acceptance does not make those names valid newsstore items.
Storepack does not validate source names or publication identity.

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

The [newsstore contract](https://github.com/leni-lab/newsstore/blob/main/docs/store-contract.md)
defines preservation, immutable publication, daily ZIPs, duplicates, and the
shared store lock. Keep the system timezone consistent with all store readers.
Storepack holds the lock for selection, packing, and cleanup. Storeindex and
cooperating recovery tools use the same lock. An active holder prevents a
storepack run.

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
