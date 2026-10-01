# Overview

leni2news imports LENI2020 export files into a file store on Windows. It
processes the initial batch from one local directory or SMB share and exits. Use
`--watch` to watch continuously for new files and retries.

- imports completed exports under the shared store contract
- preserves source bytes and modification times
- archives successfully processed sources in `done`
- retries temporary failures and retains failed inputs for inspection

The default filter is `*.leni.json`, including names such as
`1730000000_003.leni.json`. Subdirectories are not searched.

Existing files are processed when the application starts. Files left by an
interrupted run are recovered automatically. See the [quickstart](quickstart.md)
for setup and expected results.

## When not to use

Do not use leni2news with a producer that depends on completed files remaining
in the watched directory. Sources can leave that directory as soon as they are
ready. LENI2020 must meet the [interface contract](leni2020.md).

The importer validates canonical filenames but does not parse JSON, synchronize
edits, or propagate deletions. Existing destination files are never overwritten.
Run one importer per source directory. Recovery can duplicate source bytes at a
newer store position if publication succeeded before source archiving failed.

Before connecting an existing store, check the shared
[operating prerequisites](https://github.com/leni-lab/store-contracts/blob/main/docs/news-store.md#operating-prerequisites-and-recovery).
Historical ingestion uses the contract's separate import procedure.
