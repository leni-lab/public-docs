[back to overview](overview.md)
---

# Troubleshooting

## Input does not advance

The first unavailable file blocks all later files. Inspect locks, continuing
writes, and `claim_stable` / `claim_first_stable`. A warning after
`claim_warn_after` does not discard the input. Current or future source times
also wait. Verify both clocks when future-time warnings appear.

`work` holds an active or waiting input. A retry does not move it elsewhere.
After restart this file is resumed first. More than one work file is an error,
requiring operator reconciliation without deleting source bytes.

## Store clock and names

Check the source and importer clocks when future-time warnings appear. Logs
identify original and assigned filenames when allocation corrects a name.
Clock skew, delayed exports, idle, and restarts can require corrections without
data errors. The exact rules are in
[regular input ordering](https://github.com/leni-lab/store-contracts/blob/main/docs/news-store.md#regular-input-ordering).

## Store lock and anchor

The importer, indexer, and packer share `.news.lock`. Do not remove an
active lock file. Startup contention fails the invocation, while processing
contention defers the head file. Only one importer may own each input directory.

ZIP history without a loose item prevents startup. Follow the shared
[anchor and recovery procedure](https://github.com/leni-lab/store-contracts/blob/main/docs/news-store.md#operating-prerequisites-and-recovery)
before retrying.

## Failures and stop

Transient failures use bounded in-memory retries. Check storage access, space,
and network availability. Restart resets retry counters and delays. `fail`
contains permanent failures or exhausted retries. `review` contains inputs from
unexpected processor errors, which stop the run with full context.

The active file finishes before regular shutdown. Blocking filesystem work can
outlast the configured runtime or timeout. The store section is closed before
exit. After hard termination, verify temporary file ownership before removing
orphan `.leni2news-*` files. Reprocessing can duplicate published source bytes
if interruption occurred before moving the source to `done`.

See [settings](settings.md) and the [LENI2020 interface](leni2020.md).
