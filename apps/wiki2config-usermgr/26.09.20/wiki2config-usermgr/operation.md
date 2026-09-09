[back to overview](overview.md)
---

# Operation and reports

The processor requires a complete expanded input stream and an empty output
directory. It validates the input and renders all candidate bytes before opening
output files. Successful completion produces these files:

| file                   | content                    |
| ---------------------- | -------------------------- |
| `users.wiki.ini`       | memberships and user flags |
| `groups.wiki.ini`      | flattened group rights     |
| `permissions.wiki.ini` | permission bundles         |

All three files are produced even when some or all recognized areas are empty.
Input with no recognized area is an error. Output follows the [common INI
contract](submodules/configflow/docs/zoom-config/output.md): strict
Windows-1252 with CRLF, without processor-generated metadata. Repeated
processing of the same input produces identical bytes in a fresh working
directory.

## Report

stdout is a UTF-8 Markdown report containing success or failure, entry counts,
and warnings. It contains no domain comparison with a previous run. It makes no
activation or archival claim.

Source references appear as inline code such as `line:42`. They identify
physical lines in the complete stdin stream, including horizontal rules. The
caller can replace these references with original source filenames and line
numbers using the source map built during include expansion.

stderr supplies technical diagnostics. Expected validation failures have a
readable report and a nonzero exit code. Unexpected failures retain their
traceback for diagnosis. Never infer success from report text or the presence of
some files: the process must have exited successfully.

## Caller responsibilities

The caller checks the exit code and the general INI output contract, adds or
preserves metadata, and activates the complete candidate. It also owns report
publication and optional Git archival. A failure before activation leaves the
current configuration in place. Partial working output is discarded.

The separate wiki2config application implements this lifecycle. This wiki2config-usermgr
release supplies only the domain processor. See [migration](settings.md).
