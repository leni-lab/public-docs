# Overview

leni2store imports LENI2020 export files into a file store. It runs continuously
on Windows and watches one local directory or SMB share.

- copies matching files without changing their contents or names
- preserves the source modification time
- makes each completed copy visible under its final name in one operation
- skips files whose final name already exists in the destination
- archives successfully processed sources in the configured `done` directory
- retries temporary failures and keeps failed files for inspection

The default filter is `*.leni.json`, including names such as
`1730000000.3.leni.json`. Subdirectories are not searched.

Existing files are processed when the application starts. Files left by an
interrupted run are recovered automatically. See the
[quickstart](quickstart.md) for setup and expected results.

## When not to use

Do not use leni2store with a producer that depends on completed files remaining
in the watched directory. Sources can leave that directory as soon as they are
ready. LENI2020 must meet the [interface contract](leni2020.md).

This application does not validate JSON, synchronize edits, or propagate
deletions. A matching destination name is treated as already stored, even when
its content differs. Run one import instance for the source directory.
