[back to overview](overview.md)
---

# Operation

Preview matching files and their ZIP targets:

```powershell
logarchive --dry-run -c logarchive.ini
```

`--dry-run` validates all
job configurations, scans existing input directories once, and reports each
matching source, target archive, and planned ZIP member name. A summary reports
the number of planned files and errors. Input scanning is nonrecursive, sorted,
and skips file links, directory links, and Windows junctions through Toolkit.

The preview never opens log contents or ZIP archives, creates output
directories, or modifies sources. It does not test file locks, archive contents,
or write permissions. Optional Toolkit logging can still write logarchive's
own log file. Missing input directories are errors. Other sections continue
after an input scan error, and other files continue after a target mapping
error. An existing empty input directory is successful with no planned files.

Standard Toolkit options provide help, version, verbosity, quiet mode,
configuration selection, and value overrides. Run `logarchive --help` for the
exact syntax.

| exit code | meaning                                                      |
| --------- | ------------------------------------------------------------ |
| `0`       | completed without errors, locked files may have been skipped |
| `1`       | startup, scan, mapping, or archive failure                   |
| `2`       | invalid configuration or usage                               |
| `130`     | canceled with Ctrl+C                                         |

Run without `--dry-run` to archive the selected files:

```powershell
logarchive -c logarchive.ini
```

Each source keeps its complete filename inside the ZIP, including its rotation
suffix. Bytes are preserved without parsing log contents. Empty files are
archived too. New entries use ZIP deflate compression.

Each update copies the existing ZIP into a temporary file beside the target,
adds the source, checks every member's CRC, and compares the new member with
the source byte for byte. The verified ZIP replaces the target before the
source is removed. This requires free space for a second copy of the archive.
Large monthly archives are copied and verified for each added source.

An identical existing member is a successful retry. The source is removed
without rewriting the ZIP. Different content under the same member name,
duplicate member names, and invalid or corrupt archives are errors. Sources
and existing archives are retained on these errors. Independent files and jobs
continue after an error. The final summary counts archived, skipped, and failed
files.

Locked sources and archives are skipped without waiting and do not make the
invocation fail. Schedule repeated invocations to retry them. Permission and
storage errors are failures, not lock skips.

Ctrl+C stops with exit code 130. An interruption before ZIP publication leaves
the source for a later run. An interruption after publication can leave both
the ZIP entry and source, and the next run recognizes the identical entry.
Forced termination may leave `.archive.zip.*.tmp` files beside the archive.
They are never used as inputs to recovery. Remove them only when no logarchive
process is running. Do not remove `.zip.lock` files while a process is running.

Use trusted directories and filesystems with reliable locking and atomic file
replacement. Windows excludes other source handles throughout the transaction.
POSIX locks are advisory, so producers must stop modifying rotated segments.
Concurrent archive writers must use logarchive's lock file. System power loss
and storage failure remain dependent on filesystem durability guarantees.

There is no watch mode, scheduler, or permanent worker. Task Scheduler or a
supervisor can invoke the archive command periodically. Legacy logs
remain assigned to rotate2 in separate input directories.
