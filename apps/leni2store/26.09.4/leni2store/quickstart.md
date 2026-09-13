[back to overview](overview.md)
---

# Quickstart

## Prepare

1. Extract `leni2store.zip` into an application directory. The package contains
   `leni2store.exe` and `leni2store.example.ini`.
2. Save the example as `leni2store.ini` beside the executable.
3. Set `[input] inbox` to the existing LENI2020 export directory and
   `[output] path` to the destination store.
4. Confirm that LENI2020 meets the [interface contract](leni2020.md).

For a network share, prefer a UNC path such as `//server/share/exports`.
The account running leni2store needs permission to read and move source files,
create the processing directories, and create and rename destination files.
Mapped drives are available only in the Windows session that created them.

Relative paths are resolved beside the selected INI file. Processing
directories and the output directory are created automatically. The input
directory must already exist.

## Start

```text
leni2store.exe
```

This imports the initial batch and exits. For continuous operation:

```text
leni2store.exe --watch
```

Both modes perform real imports. Use a dedicated test directory when
validating a new installation. Add `--max-runtime 30s` to request a stop
after 30 seconds. A stopped one-time import can leave files for the next run
and exits with `1`.

## Check the result

- each imported file exists under its original name in the destination
- its bytes and modification time match the source
- the source is archived in `done`, by default below the input directory
- existing destination files retain their content and modification time
- temporary failures appear in `retry`, final failures in `fail`, and
  unexpected failures in `review`

With `--watch`, the application continues watching until stopped. Press Ctrl+C
to request a graceful stop. After editing the configuration, the application
stops so that it can be restarted with the new settings. See [CLI](cli.md) for
batch behavior and exit codes, and [troubleshooting](troubleshooting.md) for
failures.
