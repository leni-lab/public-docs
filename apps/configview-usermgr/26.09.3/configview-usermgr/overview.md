# Overview

configview-usermgr adds an administrative usermgr view to configview. It
displays users, groups, and permission bundles for the selected current or
archived configuration.

## Browse the configuration

Users appear as compact rows with name and expiry. Disabled names are struck
through. Expanding a row shows its groups and known metadata. Expand
`effective permissions` to see the configured permission expressions. The label
includes their count.

The users section starts open. Users, groups, and permission bundles can be
collapsed as a whole. Opening a section closes the other sections. Opening an
entry closes its siblings. Nested details leave their ancestors open. Select a
group or bundle reference to open and focus its entry.

Search includes collapsed details and effective permissions. Matching sections
and entries open together. Clear the search to restore the previous state,
including nested permission lists. Following a reference clears the filter so
its target is visible. Search runs locally in the browser without rereading the
configuration.

The interface is English. Native disclosures work without JavaScript. Search,
automatic closing of siblings, and reference navigation require JavaScript.

## Interpret the display

Expiry and metadata timestamps use the renderer process's local timezone. Expiry
is displayed without comparing it to today's date. Empty expiry means no expiry.
Empty metadata means unknown. File timestamps, when shown inside the interpreted
view, come from metadata comments in the input.

Effective permissions describe configured expressions. Wildcards are not
expanded against actual resources. Disabled users retain their configured
expressions. The display does not establish account existence, deployment,
activation, or actual access.

Unknown fields and their values are omitted from this view. Diagnostics identify
their source location. configview's original INI viewers show all values,
including any sensitive fields present in the selected files.

Use configview's version navigation and original-file comparison to inspect
changes. There is no separate user detail page or effective history view.

## Documentation

- [installation and configuration](operation.md)
- [license](LICENSE)
