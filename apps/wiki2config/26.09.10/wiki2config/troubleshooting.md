[back to overview](overview.md)
---

# Troubleshooting

Start with the phase in the report and the console diagnostics. A failed report
can describe output that is already active when only Git failed.

| diagnostic or symptom             | action                                                                        |
| --------------------------------- | ----------------------------------------------------------------------------- |
| old or misplaced include          | use `# include:` in the initial block, before comments, prose, or `__NOTOC__` |
| invalid include target            | check namespace, lowercase filename mapping, and forbidden path characters    |
| include cycle or missing page     | follow the reported source chain and correct the Wiki links or mirror         |
| processor exit code               | read the processor report and stderr, then correct input or processor setup   |
| processor executable not found    | use the installed filename, currently `wiki2user.exe` for the usermgr processor |
| processor module not found        | use `wiki2user` after `-m`, regardless of the checkout directory name          |
| processor timeout                 | check processor diagnostics and `[convert <name>] timeout`                    |
| empty processor result            | select a processor that emits its complete INI set with `--output`            |
| invalid Windows-1252 or CRLF      | fix processor serialization, including unrepresentable characters             |
| processor metadata is not allowed | let wiki2config maintain structured comments                                  |
| no source location                | correct the processor's reserved `line:<n>` report reference                  |
| invalid existing metadata         | correct the active baseline, then restart or run another one-shot import      |
| partial activation                | resolve the filesystem error, then complete a valid import                    |
| Git dubious ownership             | set `[git] trust_directory = yes` for the dedicated archive                   |
| report could not be written       | restore write access or free space, then run another attempt                  |
| no debug output with `-v`         | lower the relevant logging handler's `log_level` to `DEBUG` or `TRACE`         |

`trust_directory` only changes Git's ownership check. It does not grant write
access. Git failure leaves successfully activated files in place. A clean
restart regenerates from current input and does not restore an older Git
version. See [recovery](operation.md#failure-and-restart).
