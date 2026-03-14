# overview

short product overview for sftpbeam users.

## what sftpbeam is

- uploads files to sftp targets from local hotfolders
- processes files continuously in named pipelines
- supports retries with backoff for transient failures

## target audience

- operators who run configured file delivery pipelines
- teams that need reliable unattended sftp transfer jobs

## why sftpbeam

- designed for reliable unattended sftp delivery from hotfolders
- predictable outcome model with explicit success, retry, fail, and review paths
- operator-focused safety model with host-key check workflow and guarded claim
- multi-pipeline setup through named input, sftp, and transfer sections
- graceful shutdown model to protect in-flight processing

## key features

- multi-pipeline setup via `[input <name>]`, `[sftp <name>]`, `[transfer <name>]`
- atomic upload flow with optional temporary suffix and rename
- retry control with configurable `retries`, `backoff`, and `backoff_max`
- host key verification workflow via `--check`
- graceful shutdown on signals, runtime limit, and config changes
- packaged executable delivery for operator use

## requirements

- deployed `sftpbeam` executable in `PATH` or local app directory
- reachable sftp target and valid credentials

## when not to use

- ad-hoc interactive file transfers with manual operator decisions per file
- scenarios that require non-sftp protocols as primary transfer channel
- workflows without stable inbox semantics or without clear producer contract

## licensing

- see [LICENSE](LICENSE)

## next steps

- first setup path: [quickstart.md](quickstart.md)
- full config reference: [settings.md](settings.md)
- config template: [sftpbeam.example.ini](sftpbeam.example.ini)
- field value syntax: [config/syntax.md](config/syntax.md)
