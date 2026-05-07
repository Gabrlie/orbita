# Networking & Advanced SSH (Future)

> Status: draft | Max lines: 150

## Overview

Phase 6 features: SSH port forwarding, proxy support, agent forwarding, pre-connect commands, and optional integration with Cloudflared and Tailscale.

## SSH Port Forwarding

### Local Forwarding
- Forward a local port to a remote host via SSH tunnel
- Use case: access remote database/web service through SSH
- dartssh2 API: `client.forwardLocal(localPort, remoteHost, remotePort)`
- Per-server configuration: list of forwarding rules

### Remote Forwarding
- Forward a remote port back to local machine
- dartssh2 API: `client.forwardRemote(remotePort, localHost, localPort)`

### Dynamic Forwarding (SOCKS5)
- SSH as SOCKS5 proxy
- dartssh2: open a local SOCKS5 listener that tunnels through SSH

### UI
- Per-server "Port Forwarding" tab in settings
- Add/edit/delete forwarding rules: `localPort:remoteHost:remotePort`
- Toggle: auto-start on connect
- Status indicator: active/inactive per rule

## Proxy Support

Connect SSH through a proxy when direct connection is not available.

| Proxy Type | Implementation |
|-----------|---------------|
| SOCKS5 | Connect via SOCKS5 socket, pass to dartssh2 |
| HTTP CONNECT | HTTP CONNECT tunnel, pass to dartssh2 |
| SSH Jump Host (ProxyJump) | Chain: connect to jump host → forward to target |

Per-server config: proxy type, host, port, credentials (optional).

## SSH Agent Forwarding

- Forward local SSH agent to remote server
- Use case: jump between servers without copying keys
- dartssh2 support: requires agent forwarding channel
- Per-server toggle: enable/disable agent forwarding

## Pre-Connect / Post-Connect Commands

- **Pre-connect**: local shell commands run before SSH connection (e.g., start VPN, tunnel)
- **Post-connect**: remote commands run immediately after SSH session established (e.g., `cd /app`, `source .env`)
- Per-server configuration: ordered list of commands
- Timeout per command: configurable (default 10s)

## Cloudflared Integration

### Design Principles
- NOT bundled — user installs binary separately
- App detects binary: `command -v cloudflared && cloudflared --version`
- If not found: show download instructions with platform-specific links

### Connection Flow
1. Start `cloudflared access tcp --hostname <host> --url localhost:<port>` as local process
2. SSH connect to `localhost:<local_port>`
3. On disconnect → stop cloudflared process

### Per-Server Config
- Enable/disable Cloudflared
- Tunnel hostname
- Auth token (stored encrypted in vault)

## Tailscale Integration

### Detection
- `command -v tailscale && tailscale status --json`
- On mobile: detect Tailscale VPN via system API

### Connection Flow
1. Check Tailscale status
2. Resolve server's Tailscale IP (100.x.x.x)
3. SSH connect to Tailscale IP directly

### Per-Server Config
- Enable/disable Tailscale connection
- Tailscale hostname or IP

## Connection Method Priority

Per-server, user configures preferred method. App tries in order:
1. User-selected method (Direct / Proxy / Cloudflared / Tailscale)
2. If fails, offer fallback selection (no silent fallback)

## Changelog
- 2026-04-15: Add port forwarding, proxy, agent forwarding, pre/post-connect commands
- 2026-04-15: Initial creation
