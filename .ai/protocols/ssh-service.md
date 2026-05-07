# SSH Service Protocol

> Status: active | Max lines: 150

## Overview

Manages SSH connection lifecycle for all server interactions. Uses one pooled
SSH connection per server, multiplexed channels for monitoring, terminal, and
future SFTP / Docker features.

## Connection Lifecycle

```
[Disconnected]
     │
     ▼ connect(server)
[Connecting] ──── auth fail ───> [Error]
     │
     ▼ authenticated
[Connected]
     │
     ├── openShell()    → terminal session
     ├── exec(cmd)      → one-shot command
     ├── openSftp()     → file operations
     │
     ▼ network error / timeout
[Reconnecting] ──── max retries ───> [Disconnected]
     │
     ▼ success
[Connected]
```

## Authentication Methods

| Method | dartssh2 API | Notes |
|--------|-------------|-------|
| Password | `SSHClient(password:)` | Simplest, least secure |
| Private key | `SSHClient(identities:)` | Ed25519, RSA, ECDSA |
| Key + passphrase | `SSHClient(identities:)` | Decrypt key with passphrase |

Key formats supported: OpenSSH, PEM, PKCS#8.

Key-based monitoring MUST await the async key list before connecting. If the
selected key is not loaded or missing, stop with a log entry instead of falling
back to empty password authentication.

## Keepalive Strategy

```dart
// Send keepalive every 30 seconds
client.setOption(SSHOption.keepAlive, interval: 30);
```

If 3 consecutive keepalives fail → trigger reconnection.

## Channel Management

| Channel Type | Purpose | Lifecycle |
|-------------|---------|-----------|
| Shell | Terminal sessions via `SshShellSession` | Open while a terminal page lease is active |
| Exec | One-shot commands (monitoring, docker, scripts) | Open per command, close on completion |
| SFTP subsystem | File operations and downloads | Open while user is on file/download page |

`SshService.openShell()` wraps `dartssh2`'s `SSHSession` and exposes stdout,
stderr, write, resize, done, and close without leaking `dartssh2` types into UI
code.

File copy, delete, download, and move operations should stay on one SFTP
channel when possible. Archive compression, extraction, and preview may use
short exec commands because those operations rely on remote system tools.
Tool installation uses streaming exec output so the UI can show progress and
the final success/failure state.

Docker management uses short exec commands for snapshot loading and mutations.
`docker logs --tail 200 -f` uses streaming exec with a UI stop signal; stopping
closes the remote exec channel but keeps the pooled SSH connection eligible for
reuse unless the transport itself reports unhealthy.

## Reconnection Logic

1. Connection lost detected (keepalive failure or write error)
2. Set state to `Reconnecting`
3. Attempt reconnect with exponential backoff: 1s, 2s, 4s, 8s, 16s (max)
4. Max 5 attempts
5. If all fail → set state to `Disconnected`, notify user
6. Active shell sessions: show "reconnecting..." overlay
7. On reconnect success: shell sessions need manual re-open; monitoring auto-resumes

## Connection Pool

```dart
class SshConnectionManager {
  // serverId → pooled connection entry
  final Map<String, _ManagedSshConnection> _connections;

  Future<SshClientSession> getOrConnect(Server server);
  Future<SshConnectionLease> acquire(Server server);
  Future<void> disconnect(String serverId);
  Future<void> disconnectAll();
  Stream<SshConnectionLifecycleState> watchState(String serverId);
}
```

- Pool entries are keyed by `server.id`
- A connection fingerprint includes host, port, username, auth mode, password,
  and selected key identity so credential changes force reconnect
- `acquire()` returns a lease; the connection enters idle retention when the last
  lease releases
- Released pooled connections stay open for a short idle window so rapid SFTP
  navigation does not pay a full SSH handshake on every directory change
- Reused connections allow concurrent `execute()` polling and `openShell()` use
- Callers must mark a reused connection unhealthy when channel creation or exec
  reports a closed transport; the manager closes that stale entry so the next
  acquire performs a fresh SSH handshake
- SFTP channel-open failures are retried once after dropping the stale pooled
  connection; mutation bodies are not retried after a channel has opened

## Timeout Configuration

| Operation | Timeout | Configurable |
|-----------|---------|-------------|
| TCP connect | 10s | Yes |
| Authentication | 15s | No |
| Exec command | 30s (default, per-command override) | Yes |
| SFTP operation | 60s | Yes |
| Keepalive interval | 30s | Yes |

## Security Notes

- Never log passwords or private keys
- Never log archive passwords; remote archive tools may still expose them in
  process arguments while the command is running
- Clear SSH credentials from memory when connection closes
- Verify host key on first connect (TOFU model); store fingerprint for future verification

## Changelog
- 2026-05-04: Document Docker snapshot/action exec and stoppable streaming logs
- 2026-05-03: Clarify SFTP-only file mutations and streaming exec output for tools
- 2026-05-03: Add SFTP channel-open recovery guidance
- 2026-05-03: Keep released pooled connections alive briefly for rapid SFTP reuse
- 2026-05-02: Clarify SFTP download usage and archive password logging boundary
- 2026-05-02: Document stale pooled connection invalidation after resume/channel-open failures
