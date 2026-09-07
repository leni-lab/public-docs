[back to overview](overview.md)
---

# quickstart

first working setup path for sftpbeam operators.

## prerequisites

- deployed `sftpbeam` executable
- network access to the target sftp server

## package contents

- `sftpbeam` executable
- `sftpbeam.example.ini` template

## setup local config

- create `sftpbeam.ini` from `sftpbeam.example.ini`
- edit `sftpbeam.ini` for your environment
- set at least one `[input <name>]`, one `[sftp <name>]`, and one
  `[transfer <name>]`
- keep section names aligned, for example `[input orders]` and
  `[transfer orders]`

see [settings.md](settings.md) for all keys and defaults.

## verify host key

before the first upload, register the server's host key:

```bash
sftpbeam --check <name> --accept-new-key
```

- this connects to the server, shows the fingerprint, and adds it to `known_hosts`
- the `known_hosts` file is created automatically if it does not exist yet
- without this step, uploads will fail with a "known_hosts file not found" error

to check all configured sftp entries interactively (with confirmation prompt):

```bash
sftpbeam --check
```

## run one pipeline

- start one configured pipeline:

```bash
sftpbeam <name>
```

- optional runtime limit for test runs:

```bash
sftpbeam <name> --max-runtime 10min
```

## validate result

- success path: files move from `inbox` to `done`
- retry path: transient failures move files to `retry`
- fail path: exhausted retries move files to `fail` or `review`

## see also

- [settings.md](settings.md)
- [sftpbeam.example.ini](sftpbeam.example.ini)
- [config/syntax.md](config/syntax.md)
