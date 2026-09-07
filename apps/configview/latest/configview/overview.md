# overview

configview helps operators review current configurations, archived versions,
and import reports in a browser. It provides a read-only view of generated
administrative settings and their observed history.

## key capabilities

- navigation by configuration format and named instance
- current configuration and immutable archived versions
- import reports with status and links to related versions
- user groups, permission bundles, and effective permission expressions
- per-user history, including indirect permission changes
- visible disabled state, expiry, timestamps, and data diagnostics

The supported format is `usermgr`. The interface is English. Displayed
timestamps use the server's local timezone.

## practical use

Use configview to inspect the administrative state produced by an import,
compare a user's observed states across archived versions, or investigate
warnings and failures in import reports.

The viewer does not modify configurations or reports. Effective permissions
describe configured expressions, not proof of deployment or actual account
access. Unreadable or missing archive versions can leave gaps in history.

## getting started

You need configview and read access to the configuration and archive
directories. A report directory is optional.

For the standalone Windows application, extract the release ZIP and prepare
the [example configuration](configview.example.ini) as `configview.ini`
beside the executable. Set the current, archive, and report paths, then start
`configview.exe` and open <http://127.0.0.1:8080>.

The default listener is local. Shared access requires an access-controlled
deployment. Settings changes stop the application; a configured supervisor
can restart it.

## documentation

- [operation and settings](operation.md)
- [logging and noisy parser output](operation.md#logging)
- [shutdown and restart](operation.md#shutdown-and-restart)
- [effective user history](operation.md#effective-history)
- [example configuration](configview.example.ini)
- [license](LICENSE)
