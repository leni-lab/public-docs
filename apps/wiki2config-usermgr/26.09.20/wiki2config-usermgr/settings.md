[back to overview](overview.md)
---

# Migration from the previous application

The project and executable were renamed from `wiki2user` to
`wiki2config-usermgr`. Update scripts and wiki2config's processor setting to use
`wiki2config-usermgr` or `wiki2config-usermgr.exe`. Python callers use
`python -m wiki2config_usermgr`. The former command is not installed as an alias.

wiki2config-usermgr no longer reads the legacy `wiki2user.ini`. There are no
application settings for input paths, reports, watching, metadata, or Git.
Existing local configuration files are not modified and are not read.

Replace the old invocation with the [process interface](cli.md): expanded
Wikitext on stdin and an empty directory through `--output`. The three filenames
and usermgr field semantics remain the same. Generated files now contain no
metadata, and stdout is the Markdown processing report.

For unattended import, install
[wiki2config](https://github.com/leni-lab/wiki2config) and configure its input,
processor, output, reports, and optional Git archive. Point its processor
setting at this executable. Convert `* include:` to `# include:` and move all
includes before other page content, apart from blank lines. Preserve the
existing active INI directory as wiki2config's comparison baseline. Move reports
and legacy archive directories outside that directory. See the [controller
quickstart](https://github.com/leni-lab/wiki2config/blob/main/user-docs/quickstart.md).

Do not point `--output` at the current active configuration. The processor
requires an empty working directory and does not implement activation or
recovery. See [operation](operation.md).
