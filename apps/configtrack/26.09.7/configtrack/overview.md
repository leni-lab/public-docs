# Overview

configtrack archives application configuration files in local Git repositories.
It discovers applications through `appinfo.ini` and records changed snapshots
once or continuously. Use configview to review current files and their history.

## Getting started

Extract the Windows release ZIP and copy the
[example configuration](configtrack.example.ini) to `configtrack.ini` beside
the executable. Set `[appinfo local] patterns` to find application manifests
and `[git] path` to your Git executable. Git is installed separately.

Enable tracking in each application's `appinfo.ini`:

```ini
[app example]
config_files = config.ini, settings/access.ini
configtrack = true
```

Run `configtrack.exe` for one archive pass or `configtrack.exe --watch` to keep
watching. Only changed snapshots create commits. Archives remain local.

Use application deployment directories. Existing ordinary Git repositories are
rejected. Each archive includes `appinfo.ini` and the selected files, including
any credentials they contain, so restrict access to the archive directory.

## Documentation

- [settings reference](settings.md)
- [operation and review with configview](operation.md)
- [license](LICENSE)
