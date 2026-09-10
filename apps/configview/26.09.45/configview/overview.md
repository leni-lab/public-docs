# Overview

configview provides read-only review of current configurations and optional Git
history. Optional renderers add domain views. The configview-usermgr renderer
displays administrative users, groups, and permission bundles.

## Capabilities

- direct app selection with optional group headings
- application discovery through `appinfo.ini`, with display titles and profiles
- current files with modification times and encoding details
- historical configurations read directly from Git commits
- original INI viewers and comparisons between archived versions and Current
- optional domain views, including compact usermgr lists and local search
- file metadata and diagnostics for incomplete or invalid configurations

The interface is English. Timestamps use the server's local timezone. Git
history is optional. Reports are separate and are not shown in configview.

## Getting started

Extract the Windows release ZIP and copy the
[example configuration](configview.example.ini) to `configview.ini` beside
the executable. Set `[appinfo] patterns` to find your `appinfo.ini` files. Each
manifest declares `[app <name>]` sections with `config_files` and an optional
`config_profile`. Add `title`, `description`, and `group` to organize the start
page independently of renderer profiles. Install and
configure the desired renderer, or remove the example's `renderer` setting for
original-file review. Start `configview.exe` and open <http://127.0.0.1:8080>.
See [settings](settings.md) for details.

Enable `[git]` to inspect existing history in each configured directory. This
requires a Git executable and read access to the repository. configview does not
create commits or change the displayed configuration. A missing repository does
not prevent current-file review.

The default listener is local. Shared access requires an access-controlled
deployment. Changes to `configview.ini` stop the application so a supervisor can
restart it. Restart manually after changing application manifests. Effective
permissions describe configuration, not proof of deployment or
actual access. Missing or invalid commits can leave visible gaps in history.

## Documentation

- [settings reference](settings.md)
- [operation](operation.md)
- [logging](settings.md#logging)
- [shutdown and restart](operation.md#shutdown-and-restart)
- [usermgr view](operation.md#usermgr-view)
- [license](LICENSE)
