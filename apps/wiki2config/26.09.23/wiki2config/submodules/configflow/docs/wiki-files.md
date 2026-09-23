[back to overview](../../../overview.md)
---

# Wiki file input

`configflow.wiki_files` assembles local Wiki pages using the include rules in
[Wiki format](wiki-format.md#includes). It is an explicit filesystem adapter.
`configflow.wiki` remains a pure parser with no file access.

```python
import configflow.wiki as wiki
import configflow.wiki_files as wiki_files

source = wiki_files.assemble(entry, "Config")
document = wiki.parse_json(source.text)
```

`entry` is a `pathlib.Path`. The namespace argument identifies the accepted
Wiki link namespace, not a parser page namespace. Included files must resolve
inside the entry directory. Includes are traversed in order and deduplicated,
with included pages before their parents. Cycles are errors.

`Source.pages` contains `Page` objects with their resolved local `path`,
processed `text`, and original `lines`. Consumed includes become blank lines.
`Source.files` lists the paths. `Source.text` serializes the named-page JSON
envelope for process boundaries. File decoding is UTF-8 with an optional BOM,
and line endings are normalized to LF.

`Error` reports invalid or missing input, including source coordinates and
include chains. Its subclass `ReadError` reports other filesystem read
failures, which an application may retry. Applications map these exceptions
to their own runtime error categories.

The adapter does not observe directories, schedule work, download Wiki pages,
or publish output. Files are read individually, without a collection-wide
revision or snapshot guarantee.
