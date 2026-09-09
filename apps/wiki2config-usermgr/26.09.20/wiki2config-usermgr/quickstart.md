[back to overview](overview.md)
---

# Quickstart

Prepare one UTF-8 Wikitext file without a BOM, containing all required data. The
[Wiki format](wiki-format.md) includes a complete standalone example. For
automated import, install [wiki2config](https://github.com/leni-lab/wiki2config)
separately. It expands includes and invokes this processor. The standalone
examples below require input whose includes have already been expanded.

Create a new empty working directory. From Windows Command Prompt:

```bat
mkdir work
wiki2config-usermgr --output work < expanded.wiki > report.md
```

Use byte-preserving redirection. A Python caller can pass UTF-8 explicitly:

```python
from pathlib import Path
import subprocess

output = Path("work").resolve()
output.mkdir()
result = subprocess.run(
    ["wiki2config-usermgr", "--output", str(output)],
    input=Path("expanded.wiki").read_bytes(),
    capture_output=True,
)
Path("report.md").write_bytes(result.stdout)
print(result.stderr.decode("utf-8"))
result.check_returncode()
```

After success, `work` contains `users.wiki.ini`, `groups.wiki.ini`, and
`permissions.wiki.ini`. The report describes processing and warnings. These
files are candidates, not an activated or archived configuration. A new
invocation requires another empty working directory.

See [CLI](cli.md) for exit codes and [operation](operation.md) for ownership of
output, metadata, and reports.
