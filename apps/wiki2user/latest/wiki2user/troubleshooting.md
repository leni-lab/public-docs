[back to overview](overview.md)
---

# Troubleshooting

Inspect the first error in the ordinary log and the newest available conversion
report. Run `wiki2user --check` after correcting the cause.

## Configuration is rejected

- use `[input] file`, the former `path` and `entry` keys are unsupported
- specify an entry ending in `.wiki` whose parent directory exists
- resolve relative input and output paths from the selected config directory
- compare section names and keys with [settings](settings.md)

Startup errors do not create conversion reports.

## Entry or included page is missing

- check the configured entry path
- verify that wikiread selects and has downloaded the needed pages
- check the include mapping, `Config:Groups` requires `groups.wiki`
- keep included pages beside the entry file

Watch mode waits for input changes instead of retrying a missing page on a
timer. Creating the page triggers another attempt.

## Unknown user group warning

The membership is omitted and that group's rights are unavailable to the user.
Check spelling and case, define the group, or remove the assignment in the Wiki.
Conversion can succeed with this warning, including on an unchanged import.
If no current file requires repair, that unchanged import writes the warning
only to the ordinary log and creates no report.

An unknown parent group is an error and stops conversion.

## Invalid data or inheritance cycle

- use the page and line shown in the error to locate the affected definition
- remove duplicate entries and repeated fields
- correct unknown keys and malformed values
- remove circular group or permission-bundle references
- use `YYYY-MM-DD`, empty, or `0` for expiry

See [Wiki format](wiki-format.md). Invalid input preserves the existing targets.

## Target or archive cannot be written

- check directory permissions and available disk space
- close applications holding generated files open
- inspect antivirus or other temporary locks
- ensure no second producer writes to the same output or archive

Watch mode retries temporary I/O failures. An archive publication failure
prevents target replacement. A target write failure can leave a partial set,
watch mode retries the pending writes. The failed attempt receives an error
report referencing the archived version.
Also inspect the ordinary log when report publication itself failed.

After a restart, correct any current input errors before expecting repair of
partial targets. See [operation](operation.md).

## Baseline or archive is incomplete

Before the first archive version, provide all three generated files or an
empty baseline directory. Use `output.previous` to select a separate initial
baseline when targets are incomplete.

Once versions exist, the archive supplies the baseline. Restore damaged archive
data from backup. Do not delete a referenced version merely to hide an error.
Legacy archive layouts are unsupported; select a new empty archive root.

## No new version, report, or output log line

An unchanged configuration reuses the existing version. Formatting, list order,
explicit defaults, and ignored fields do not create a version. An unchanged
output file produces no `INFO` update line.

Successful unchanged imports that write no current file create no report.
Warnings remain in the ordinary log. Use `-v` for the unchanged summary, with
an appropriate destination threshold. No-change watch polls also create no
report.

## Wiki changed but output is stale

wiki2user only sees local files. Check wikiread's log and local mirror first.
A successful conversion does not prove that MediaWiki was reachable or that
all pages came from the same revision. Then check the watch polling interval
and confirm that the changed file is in the entry directory.

## Watch stops after config change

This is intentional. Restart wiki2user to apply the new configuration, or use a
process manager to restart it automatically.
