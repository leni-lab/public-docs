[back to overview](overview.md)
---

# Includes

```text
# include: [[Config:User Groups|Groups]]
# include: [[config:Permissions]]

__NOTOC__

== users ==
...
```

Includes are allowed only in the initial block of each file. Blank lines before
and between directives are allowed. The first other nonblank line ends the
block. Comments, prose, and `__NOTOC__` are ordinary content for wiki2config and
must follow the includes. The old `* include:` spelling fails with a migration
message.

The configured namespace is required in every link and is compared without case
sensitivity. Display labels are allowed and ignored. Section fragments and
trailing text are not allowed.

`Config:User Groups` maps to `user_groups.wiki`: remove the namespace, lowercase
the title, replace spaces with underscores, and append `.wiki`. Slash,
backslash, any `..` sequence, and invalid local filenames are rejected. All
pages resolve inside the entry file's directory.

Includes are recursive and processed in listed order, before the including
page's own body. Each resolved file is emitted once. A later completed-file
reference is skipped. An active include cycle fails with its source chain.

A Wikitext horizontal rule separates emitted page bodies. Its dash count is not
part of the interface. User-written rules remain unchanged. The processor
defines what a rule means, for example starting a new root without inherited
defaults. wiki2config does not parse headings or other Wiki syntax.

Files are read as strict UTF-8 with an optional leading BOM. Each file is
opened, read, and closed. Files supplied by atomic replacement are complete
individually, but the assembled input need not represent one common Wiki
revision. Domain validation belongs to the processor.
