[back to overview](overview.md)
---

# Troubleshooting

Common operator problems and fast fixes.

## diagnostic order

- inspect the first warning or error in the log
- verify the MediaWiki API URL and credentials
- verify every `[pages]` key and selector
- inspect the output tree for unexpected `.wiki` files
- run one synchronization before investigating watch timing

## MediaWiki request fails

Symptoms:

- `mediawiki:HTTP: request failed`
- `mediawiki:request: timeout`
- HTTP status such as `401`, `403`, `429`, or `503`

Causes:

- incorrect API URL
- account lacks permission to read the selected area
- proxy, firewall, or server rejects the request
- MediaWiki is throttling or temporarily unavailable

Fix:

- verify that `api` points to MediaWiki `api.php`
- verify the account and its read permissions
- test network access from the wikiread host
- inspect the MediaWiki server log when the status persists

Watch mode retries failures classified as transient. Permanent failures stop
the process.

## login fails

Symptoms:

- `mediawiki:login: failed`
- `mediawiki:username: required`
- `mediawiki:password: required`

Fix:

- verify `username` and `password` in `[mediawiki]`
- use a MediaWiki bot password when required by the site
- confirm that the account is enabled and allowed to use the API
- prefer HTTPS before entering credentials

## remote selection is empty

Symptom:

- `pages: remote selection empty, local files unchanged`

Causes:

- exact titles do not exist
- namespace or title prefix is wrong
- account cannot see the selected pages
- all returned titles are unsafe for local mapping
- all selected pages are redirects, which are excluded

Fix:

- verify selectors in `[pages]`
- verify namespace spelling and account permissions
- inspect preceding unsafe-title warnings

wikiread treats an empty selection as an error and does not delete the local
data set.

## local file is not selected

Symptoms:

- file is not below a configured pages key
- managed path is invalid
- file is not selected

Cause:

- the output tree contains a manually created file
- a `[pages]` key was removed
- selectors were narrowed while old files remained

Fix:

- keep only wikiread-managed `.wiki` files in the output tree
- restore the previous selector or remove the obsolete local file explicitly
- keep consumer state outside the output path

Validation happens before the remote read, so no local file is changed when
this check fails.

## selected page is ignored

Symptoms:

- page is ignored because its title is unsafe
- page departs from the lowercase convention

Cause:

- the title contains Unicode, a slash, or another unsupported character
- the normalized title would not be safe on Windows
- uppercase spelling conflicts with the editorial convention

Fix:

- rename the Wiki page to a safe ASCII title
- use lowercase spelling apart from MediaWiki first-letter handling
- use spaces, periods, underscores, or hyphens as separators

## path collision

Symptom:

- two Wiki titles collide on one local path

Cause:

- normalization makes distinct titles identical, for example a space and an
  underscore at the same position

Fix:

- rename one Wiki page so both normalized filenames differ

The run stops before changing local files.

## watch reports no changes

Normal behavior:

- watch polls the newest global MediaWiki Recent Changes marker
- unchanged markers skip page enumeration and downloads
- `watch: no changes` is visible only at `DEBUG`
- unchanged file details appear only during the first successful watch sync

Use `wikiread -v --watch` when the log file should contain `DEBUG` details.
Any visible Wiki change advances the marker, but only selected page changes
produce local file updates.

## watch stops after config change

Symptom:

- the log reports that the config changed and wikiread shuts down

Cause:

- configuration changes intentionally request a graceful stop

Fix:

- restart wikiread manually
- or use a process manager that restarts it automatically

## local file cannot be replaced or deleted

Causes:

- another process holds the file open
- antivirus or indexing software temporarily locks the path
- output permissions do not allow the operation

Fix:

- stop the process holding the file
- verify directory and file permissions
- keep consumer reads short and close files promptly
- restart synchronization after resolving the lock

wikiread currently does not retry Windows sharing violations during local file
replacement or deletion.

## consumers observe mixed revisions

Cause:

- files are replaced atomically one at a time
- wikiread does not publish a multi-page snapshot

Fix:

- debounce file notifications
- read and validate the complete required input set
- activate derived state only after successful validation
- retain the consumer's last known good state

## git archive fails

- verify `[git] path` points to the extracted MinGit executable and all its
  supporting files are present
- verify available disk space and write access to the output directory and
  its parent (the archive lock lives beside the output directory)
- if the archive is busy, stop the other writer and retry; the persistent
  `.git-archive.lock` file itself is normal and must not be deleted
- if Git reports `index.lock` or a reference lock, ensure all Git processes
  have stopped before inspecting and removing a stale Git lock
- existing repositories without toolkit ownership are rejected; choose a
  separate output directory instead of reusing a source repository
- for `detected dubious ownership`, use `[git] trust_directory = yes` only
  when the output repository is trusted but belongs to another filesystem
  user; see [settings](settings.md#git)

Watch mode retries Git execution failures. Configuration and state validation
errors stop the process. Resolve the cause and restart. Do not disable Git or
edit pending output to bypass a failed commit.

## git archive is interrupted

The state file is `.git/wikiread-sync.json` below the configured output path.
Stop wikiread before inspecting it.

- `ready`: a successful sync awaits archiving; restart with Git enabled to
  commit it before the next sync, leaving the output files unchanged
- `running`: completion was not durably confirmed; wikiread stops rather than
  guessing whether the files form a complete snapshot
- malformed state: restore the state file from a trusted backup or inspect
  the output manually; wikiread will not ignore it

For an interrupted `running` state, first copy the entire output directory to
a separate location if the uncommitted files need preserving. Once you accept
that the next sync will replace that unconfirmed state, remove only
`output/.git/wikiread-sync.json` (adjust `output` to your configured path), then
restart. Existing committed history remains intact. Do not perform this step
for a `ready` state to bypass a commit failure.

## see also

- [overview.md](overview.md)
- [quickstart.md](quickstart.md)
- [cli.md](cli.md)
- [settings.md](settings.md)
