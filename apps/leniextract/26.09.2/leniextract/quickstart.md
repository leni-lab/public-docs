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

Without `--input`, provide the export through standard input and close the
input stream when complete. The command processes one export and exits.

```text
leniextract --field title
```

The input must be UTF-8 JSON. See [command line](cli.md) for field selection
and exit codes, and [troubleshooting](troubleshooting.md) for failures.
