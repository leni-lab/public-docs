[back to overview](../overview.md)
---

# sftp settings

all keys belong to a single INI section passed to `SftpClient()`.

## connection

| key | default | notes |
| --- | --- | --- |
| `host` | *(required)* | sftp server hostname or ip address |
| `port` | `22` | ssh port |
| `username` | *(required)* | ssh username |
| `password` | empty | ssh password; prefer key auth |
| `key_file` | empty | path to private key file; empty uses ssh agent or password |
| `known_hosts` | `~/.ssh/known_hosts` | path to known_hosts file; empty disables host key check |
| `connect_timeout` | `30s` | max time to establish the ssh connection |
| `keep_alive` | `30s` | ssh keepalive interval; empty disables; see note below |

`key_file` and `known_hosts` may be relative paths — they are resolved against
`base_dir` if provided to `SftpClient()`.

`known_hosts =` (empty) disables host key verification entirely. this is
insecure and should only be used in isolated environments. to add or update a
known host key use `sftpbeam --check`.

### keep_alive

`keep_alive` sends ssh keepalive packets to prevent the connection from being
silently dropped by idle timeouts on the server or intermediate firewalls.
recommended if files arrive less frequently than the server's idle timeout.

if the server has no idle timeout and bandwidth is constrained, set
`keep_alive =` to disable.

## duration syntax

durations use compact notation: `500ms`, `30s`, `5min`, `2h`.

for key-file and path syntax see toolkit fields documentation.
