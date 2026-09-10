[back to overview](overview.md)
---

# Operation and recovery

One attempt assembles the input, runs the processor, validates every output
file, adds stable section metadata, activates the complete set, and optionally
archives it in Git. The processor receives no previous configuration.

Each `[convert <name>]` owns an independent conversion. One-shot mode attempts
jobs sequentially in INI order and reports failure if any fails. Expected
failures do not prevent later jobs from running. Watch mode runs jobs
concurrently, each with its own observation, pending output, and retry state.
A runtime configuration error stops only the affected job. Unexpected software
errors stop all jobs and retain traceback diagnostics. Settings changes and
shutdown requests stop all jobs together.

## Output and metadata

The processor must return success with at least one regular INI file directly in
the working directory. Subdirectories, links, metadata from the processor, and
extra file types are errors. Domain completeness is the processor's
responsibility: wiki2config does not know how many files a particular domain
requires.

Output and the active comparison baseline are interpreted as Windows-1252.
Processor output must use CRLF without BOM. wiki2config writes canonical
Windows-1252 and CRLF. It compares section names and ordered literal assignment
pairs, without defaults, list interpretation, or domain case normalization.
Section occurrences with repeated names are matched in order. Output filename
matching is case-insensitive to match Windows file identity.

Section `created` and `changed` comments follow the [shared metadata
rules](submodules/configflow/docs/zoom-config/metadata.md). For example, `#
@meta: created: 2026-09-09T10:00:00Z` immediately follows a section declaration.
The [output contract](submodules/configflow/docs/zoom-config/output.md)
defines serialization and lifetime transitions. Existing unknown creation times
stay unknown. Valid unknown metadata keys are preserved. Metadata and ordinary
comments do not advance section change timestamps. Ordinary comments are omitted
from final output. Normalizing layout or removing comments can still change
bytes and cause a file replacement. File and assignment metadata scopes are not
maintained by this initial application profile. Invalid existing metadata blocks
activation.

Only changed final bytes are replaced. Missing generated files are recreated.
Previously generated files absent from the new set are removed. Therefore the
active directory must contain generated files only, apart from `.git`.

## Failure and restart

Failure before activation leaves active output unchanged. Activation replaces
individual files atomically, not the whole set. A failure during activation may
leave a mixture. Consumers must tolerate changes using their existing restart
behavior.

In watch mode, wiki2config retains a prepared candidate after an activation or
Git failure and retries transient failures before processing newer input. A
one-shot invocation reports the error and exits instead of retrying. Git failure
leaves the completed configuration active. Reports distinguish these cases.

On restart, the application removes its reserved stale workspace and regenerates
output from current input. There is no persistent importer journal. Invalid
current input cannot repair a partial activation. Metadata can be preserved only
where it remains in the current files. Git history does not serve as a
comparison baseline or restore missing metadata.

Git archival follows activation. A restart followed by newer input may leave an
earlier activated state unarchived. No guaranteed archive journal or push is
provided.

## Reports and watching

After settings are accepted, each non-check attempt writes a uniquely named
UTF-8 Markdown report, including attempts with unchanged output. Startup errors
and failures to write a report are available through the process diagnostics
instead. Processor stdout supplies its body, stderr supplies quoted diagnostics.
Reserved inline references such as `line:42` are replaced with source names and
original lines. Literal fenced and indented code blocks are preserved. Unmapped
references are errors, never guessed locations.

When a processor fails, its stdout report and stderr diagnostics also appear
in the application log at `ERROR` level, one nonempty line per message. Each
line includes the job name, `processor`, and the stream name. This also applies
in watch and check mode, and for timeouts or invalid processor text. Control
characters are replaced with `?` in log messages. Reports retain their existing
content handling.

Reports include the job name, file changes, and activation status and may name
a Git commit. Job log messages use its name as a prefix, for example
`usermgr: import: complete (2 files changed)`.
They are independent of configview and Git. Failure to publish a report is an
operational error, even if the configuration is already active.

Watch mode processes immediately and observes `.wiki` files directly in the
entry directory, including files not currently included. Domain errors, invalid
input, and invalid baseline metadata wait for input changes. Fixing only the
active baseline requires a restart to trigger another attempt. Transient
filesystem, timeout, and Git errors retry with backoff. Settings changes stop
the process. `--check` executes and validates the processor in a temporary
directory without activating, publishing reports, or opening a Git archive.

The external process manager prevents concurrent instances. A requested stop or
timeout terminates the processor and its process tree where supported. Do not
share active or reserved work directories with another writer. Jobs may share
a report directory, since each report has a unique filename and names its job.
Reports are not automatically pruned. Arrange retention separately.
