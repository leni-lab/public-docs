[back to overview](overview.md)
---

# Settings

Settings are read from an INI file. Relative paths are resolved beside that
file. See the [example configuration](leni2news.example.ini) and
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
[input processing settings](filefeed/settings.md). These
application defaults and directory rules apply:

| key                  | application default |
| -------------------- | ------------------- |
| `match`              | `*.leni.json`       |
| `claim_stable`       | `1s`                |
| `claim_first_stable` | `2s`                |

All other defaults and option meanings are defined by the linked Filefeed
settings. An empty `done_expire` also disables cleanup in this application. The
importer adds destination checks: output must not overlap any processing
directory or contain the input directory. Use consistent path spelling for
network locations rather than mixing drive letters and share aliases.

Source modification times are retained. If `done_expire` is enabled, old source
times can therefore cause immediate cleanup. Leave it disabled when retention
must be measured from import time.

## Output

| key           | default  | meaning                                         |
| ------------- | -------- | ----------------------------------------------- |
| `path`        | `output` | destination directory                           |
| `temp_suffix` | `.tmp`   | nonempty suffix for temporary destination files |

Temporary filenames start with `.leni2news-` and include a unique component.
Downstream file selection must exclude them. Store naming and publication follow
the [store contract](https://github.com/leni-lab/store-contracts/blob/main/docs/news-store.md#regular-input-ordering).
There is no allocation-mode setting.

Modification times are copied without clock adjustment, to the precision
supported by the destination filesystem.

## Runtime and logging

`[app] max_runtime` optionally limits the run, for example `30min`. Empty means
no limit. `--max-runtime` takes precedence. Configuration changes request a stop
rather than applying settings to an active run.

Use `[logging]` for logger-level overrides. Position corrections are logged
at warning level with original and assigned filenames.
Successful copy messages identify the assigned filenames. Future-clock warnings
are throttled to once per minute. See the
[logging settings](logs/settings.md) for details and the
[value syntax](fields/syntax.md) for durations and
filters.
