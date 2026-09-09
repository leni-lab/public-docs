# overview

Short product overview for wikiread users.

## what wikiread is

- reads selected pages from MediaWiki
- stores their raw Wikitext in predictable local files
- runs once by default or continuously with `--watch`

## target audience

- operators who provide Wiki content to local applications
- teams that need one reusable MediaWiki reader for multiple consumers
- application owners whose consumers validate and activate their own data

## why wikiread

- separates MediaWiki access from application-specific interpretation
- uses simple title selectors grouped by local output directory
- replaces each local file atomically
- preserves the MediaWiki revision time as the local file modification time
- removes local files when selected Wiki pages disappear
- avoids unnecessary MediaWiki page reads while watching

## key features

- exact-title and trailing-prefix page selection
- selection across the main namespace and named namespaces
- deterministic, Windows-safe title-to-file mapping
- one-time synchronization and continuous watch mode
- automatic retry with capped backoff for transient MediaWiki failures
- concise per-file logging with revision IDs
- optional local Git history of successful synchronization results

## local data contract

- each `[pages]` key defines one direct output directory, created when needed
- each selected page becomes one `.wiki` file in every matching directory
- files change independently and do not form a multi-page snapshot
- consumers must tolerate files changing or disappearing between reads
- consumers retain their own cache or last known good state when required
- page renames appear as deletion of the old file and creation of the new file

## requirements

- installed `wikiread` command
- reachable MediaWiki API
- MediaWiki credentials with read access to the selected pages
- dedicated local output directory owned by `wikiread`

## when not to use

- consumers require an atomic snapshot across multiple Wiki pages
- every intermediate MediaWiki revision must be retained between polls
- Wiki content must be interpreted or validated before it reaches local files
- page identity must be tracked across renames

## licensing

- see [LICENSE](LICENSE)

## next steps

- first setup path: [quickstart.md](quickstart.md)
- full config reference: [settings.md](settings.md)
- command reference: [cli.md](cli.md)
- common problems: [troubleshooting.md](troubleshooting.md)
- config template: [wikiread.example.ini](wikiread.example.ini)
