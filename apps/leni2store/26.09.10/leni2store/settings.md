[back to overview](overview.md)
---

# Settings

Settings are read from an INI file. Relative paths are resolved beside that
file. See the [example configuration](leni2store.example.ini) and
[configuration syntax](config/syntax.md).

## Minimal configuration

```ini
[input]
inbox = //server/share/exports

[output]
path = D:/store
```

The input directory must exist. The output directory is created when the import
starts. The source and output must refer to different locations.

## Input

The application uses the standard
[input processing settings](filemill/settings.md). These
application defaults and directory rules apply:

| key                | default         | meaning                                                                      |
| ------------------ | --------------- | ---------------------------------------------------------------------------- |
| `inbox`            | required        | one existing source directory, searched without recursion                    |
| `match`            | `*.leni.json`   | select LENI export files                                                     |
| `pre_claim_stable` | `1s`            | require unchanged size and modification time over a short observation window |
| `pre_claim_lock`   | `true`          | leave files with active access in the source until a later scan              |
| `poll`             | `1s`            | interval between scans                                                       |
| `work`             | `${inbox}/work` | active files, also recovered after an interrupted run                        |
| `done`             | `${inbox}/done` | successfully processed sources, configurable                                 |
| `done_max_age`     | `0s`            | archive cleanup disabled; an empty value also disables it                    |

`work` cannot be empty. Keep `inbox`, `work`, and `retry` on the same filesystem
because file claiming uses rename. Keeping all processing directories on the
same share is recommended.

Processing directories must be distinct and must not contain each other or the
input directory. The destination must not overlap any processing directory or
contain the input directory. Use consistent path spelling for network locations
rather than mixing drive letters and share aliases.

The remaining queue, worker, retry, failure, and cleanup settings are described
in the linked input reference. There is no `keep` or `in_place` option.

If archive cleanup is enabled, age is based on the file modification time, not
on its arrival in `done`. Source clock differences and old backlog files
therefore affect cleanup. Leave it disabled when retention must be measured from
import time.

## Output

| key           | default  | meaning                                         |
| ------------- | -------- | ----------------------------------------------- |
| `path`        | `output` | destination directory                           |
| `temp_suffix` | `.tmp`   | nonempty suffix for temporary destination files |

Temporary filenames start with `.leni2store-` and include a unique component.
Only the final filename signals a completed copy. Do not process temporary files
downstream. Existing final files are skipped without content comparison or
metadata updates.

Modification times are copied without clock adjustment, to the precision
supported by the destination filesystem.

## Runtime and logging

`[app] max_runtime` optionally limits the run, for example `30min`. Empty means
no limit. `--max-runtime` takes precedence. Configuration changes request a stop
rather than applying settings to an active run.

Use `[logging]` for logger-level overrides. For example, `processor = debug`
shows skipped destination files. See the
[logging settings](logs/settings.md) for details and the
[value syntax](fields/syntax.md) for durations and
filters.
