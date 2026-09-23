[back to overview](overview.md)
---

# Quickstart

Run the installed `leniextract` command or use the full path to its executable.
To extract the title from a LENI export:

```text
leniextract --field title --input 1789203039_001.leni.json
```

A successful call prints one JSON object:

```json
{"title": "Example headline"}
```

Use `--input -` to read the export from stdin until EOF. Without `--input`,
the command validates its arguments, returns information text and exits.

```text
leniextract --field title --input -
```

The input must be UTF-8 JSON. See [command line](cli.md) for field selection
and exit codes, and [troubleshooting](troubleshooting.md) for failures.

## Windows executable

If you received `leniextract.zip`, extract it to a local application folder.
Python is not required. Open PowerShell in that folder and run:

```powershell
./leniextract.exe --help
./leniextract.exe --version
```

If the archive includes an `_internal` folder, keep it beside the EXE.
This folder variant avoids unpacking the program at every start.

Extract a title from a UTF-8 file:

```powershell
./leniextract.exe --field title --input ./message.leni.json
```

For frequent invocations or large rebuilds, the folder variant can reduce
startup overhead. The stdin and JSON output contract is the same in both
variants.
