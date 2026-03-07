[back to overview](../overview.md)
---

# app settings

runtime keys used by `toolkit.app.run_with_timeout()`.

## `[app]`

| key | default | values | notes |
| --- | --- | --- | --- |
| `max_runtime` | *(none)* | duration, e.g. `8h`, `30min` | optional global runtime limit for app shutdown |

`--max-runtime` overrides the config value.

for duration syntax see [../fields/syntax.md](../fields/syntax.md).
