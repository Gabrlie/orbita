# Feature Overview

> Status: active | Max lines: 100

## Feature Matrix

| Feature | Priority | Phase | Status | Spec |
|---------|----------|-------|--------|------|
| UI skeleton + responsive scaffold | P0 | 1 | **done** | [../ui/](../ui/) |
| i18n (zh/en) | P1 | 1 | **done** | [i18n.md](i18n.md) |
| Appearance settings (theme/lang) | P1 | 1 | **done** | [../ui/design-system.md](../ui/design-system.md) |
| Encryption & security (3-tier) | P0 | 2 | planned | [encryption.md](encryption.md) |
| SSH connection management | P0 | 2 | planned | [../protocols/ssh-service.md](../protocols/ssh-service.md) |
| Server status monitoring | P0 | 2 | planned | [server-status.md](server-status.md) |
| SSH terminal | P0 | 3 | planned | [ssh-terminal.md](ssh-terminal.md) |
| File manager (SFTP) | P1 | 3 | planned | [file-manager.md](file-manager.md) |
| Docker management | P1 | 4 | planned | [docker-manager.md](docker-manager.md) |
| Script execution | P1 | 4 | planned | [script-executor.md](script-executor.md) |
| Command snippets | P2 | 4 | planned | [snippets.md](snippets.md) |
| Server groups / tags | P2 | 5 | planned | [server-groups.md](server-groups.md) |
| In-app notifications | P2 | 5 | planned | [server-status.md](server-status.md) |
| WebDAV sync | P2 | 5 | planned | [webdav-sync.md](webdav-sync.md) |
| SSH port forwarding / proxy | P3 | 6 | future | [networking.md](networking.md) |
| SSH agent forwarding | P3 | 6 | future | [networking.md](networking.md) |
| Cloudflared / Tailscale | P3 | 6 | future | [networking.md](networking.md) |
| App update (GitHub Release) | P2 | 7 | future | [app-update.md](app-update.md) |

## Feature Dependencies

```
encryption (3-tier) ─┬──> ssh connection ──┬──> server status ──> notifications
                     │                     ├──> ssh terminal ──> snippets
                     │                     ├──> file manager (SFTP)
                     │                     ├──> docker management
                     │                     └──> script execution
                     │
                     ├──> webdav sync (requires password mode)
                     └──> server groups (tag data in vault)

networking (future) ──> ssh connection (alternative transport)
app update ──> (independent)
i18n ──> (all UI depends on this) ✓ done
```

## MVP Scope (Phase 1-3)

- [x] i18n framework (zh default, en)
- [x] Responsive scaffold (phone/tablet/desktop)
- [x] Theme + language settings (functional, persisted)
- [x] Server card UI with OS icons + metrics rings
- [ ] 3-tier security: no password / password / password + biometric
- [ ] SSH connection + server status monitoring
- [ ] Interactive SSH terminal
- [ ] SFTP file browser

## Changelog
- 2026-04-15: Mark Phase 1 complete, update MVP checklist
- 2026-04-15: Initial creation
