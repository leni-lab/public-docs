[back to overview](overview.md)
---

# Operation

Run `configtrack` for a single archive pass, or `configtrack --watch` for a
continuous process. Use `-c` to select a configuration file and `-h` to inspect
all standard toolkit options.

Every watch pass discovers manifests again and reads their current activation
and file selections. New manifests, newly created selected files, changed
contents, and deletions are picked up on the next pass. Identical snapshots do
not create commits. Commit messages are `Update configuration`.

Ctrl+C requests a graceful shutdown. A running archive pass finishes before
exit. Changes to the central `configtrack.ini` stop the managed runtime so a
supervisor can restart the process with the new settings, as in wikiread.
Changes to application manifests take effect on subsequent passes without a
restart.

Transient Git and filesystem failures are retried with increasing delays in
watch mode. Invalid settings, unsupported paths, and ordinary Git repositories
stop the process with an error. A one-shot failure returns a nonzero exit code.
Archives already committed before a failure remain valid; a later pass skips
their unchanged snapshots.

The toolkit locks each archive during a commit. Run one archive writer for each
application directory. Repositories store complete snapshots of the selected
files and should not also be managed as source repositories.

Polling does not create a transaction across files written by another program.
For a coherent configuration release, finish writing the set before invoking
the one-shot command. Watch mode records states observed during its passes and
may capture an intermediate state during a multi-file update.

## Review with configview

Point configview at the same `appinfo.ini` manifests and enable its `[git]`
settings. It discovers the repository beside the manifest, including when the
selected files are in subdirectories. No renderer is required for original
files and history.

Configview only offers complete selected file sets as readable historical
versions. A commit recording a missing selected file remains in Git but is
marked incomplete by configview. Its existing file-size and path restrictions
also apply when viewing an archive.

Application archives are local. Configtrack does not configure remotes or push
their contents. The project's GitHub remote is for configtrack's own source.
