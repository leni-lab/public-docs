[back to overview](overview.md)
---

# Operation and recovery

One attempt collects named pages as JSON input, runs the processor, validates
every output file, adds stable section metadata, activates the complete set,
and optionally archives it in Git. The processor receives no previous
configuration.

Each `[convert <name>]` owns an independent conversion. One-shot mode attempts
jobs sequentially in INI order and reports failure if any fails. Expected
failures do not prevent later jobs from running. Watch mode runs jobs
concurrently, each with its own observation, pending output, and retry state.
A runtime configuration error stops only the affected job. Unexpected software
errors stop all jobs and retain traceback diagnostics. Settings changes and
shutdown requests stop all jobs together.

## Output and metadata

The processor returns one complete INI document. The configured `output_file`
must be a regular INI filename without directories or Windows device names.
Domain completeness belongs to the processor. Empty configuration is valid.
The host rejects processor-generated metadata and invalid INI syntax.

Candidate and baseline use `output_encoding`, either `cp1252` (default) or
`utf-8`. The writer uses that same encoding, CRLF, and no BOM. The transport
passes bytes unchanged. The host compares literal section names and ordered
assignments, without domain normalization. Repeated names match by occurrence.

When consolidating earlier files into an absent new destination, unique literal
section names retain their metadata across filenames. Ambiguous matches fail.
Once the destination exists, it supplies the comparison baseline. For Usermgr,
select `usermgr.wiki.ini` and `cp1252`. Configview support for this single-file
output is deferred to the next step.

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
instead. The separate processor report supplies its body, stderr supplies quoted diagnostics.
Reserved inline references identify a source page and its original line, for
example `source:users.wiki:42`. They are replaced with readable source labels.
Literal fenced and indented code blocks are preserved. Unmapped references
are errors, never guessed locations. The
[processor contract](submodules/configflow/docs/wiki-processor.md#reports-and-source-references)
defines encoding and optional column coordinates.

When a processor fails, its Markdown report and stderr diagnostics also appear
in the application log at `ERROR` level, one nonempty line per message. Each
line includes the job name, `processor`, and `report` or `stderr`. This also applies
in watch and check mode, and for timeouts or invalid processor text. Control
characters are replaced with `?` in log messages. Reports retain their existing
content handling.

Reports include the job name, file changes, and activation status and may name
a Git commit. Job log messages use its name as a prefix, for example
`usermgr: import: complete (2 files changed)`.
After successful activation, each changed file is logged at `INFO` level with
its filename followed by `created`, `updated`, or `deleted`, for example
`usermgr: import: usermgr.wiki.ini updated`. Unchanged files are omitted.
These messages remain visible if later Git archival or report publication
fails and are not repeated when Git archival is retried.
They are independent of configview and Git. Failure to publish a report is an
operational error, even if the configuration is already active.

Watch mode processes immediately and observes `.wiki` files directly in the
entry directory, including files not currently included. Domain errors, invalid
input, invalid output, and invalid baseline metadata wait for input changes. Fixing only the
active baseline requires a restart to trigger another attempt. Transient
filesystem, process, protocol, timeout, and Git errors retry with backoff. Settings changes stop
the process. `--check` executes and validates the processor in a temporary
directory without activating, publishing reports, or opening a Git archive.

The external process manager prevents concurrent instances. A requested stop or
timeout terminates the processor and its process tree where supported. Do not
share active or reserved work directories with another writer. Jobs may share
a report directory, since each report has a unique filename and names its job.
Reports are not automatically pruned. Arrange retention separately.
