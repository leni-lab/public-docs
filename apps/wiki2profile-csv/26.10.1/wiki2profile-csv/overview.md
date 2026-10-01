# wiki2profile-csv

Export profile subscriptions from local Wiki pages to monthly CSV files.

Copy [the example configuration](wiki2profile-csv.example.ini) to
`wiki2profile-csv.ini` and adjust the input and output paths.

```powershell
wiki2profile-csv --check
wiki2profile-csv
```

Use an external scheduler for recurring execution. Existing monthly archives
are retained.

- [command line and lifecycle](cli.md)
- [application settings](settings.md)
- [input fields, CSV format, and file retention](wiki-format.md)
- [license](LICENSE)
