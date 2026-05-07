# System Architecture

> Status: active | Max lines: 150

## Overview

```
┌─────────────────────────────────────────────────┐
│                 Presentation Layer               │
│  Pages / Widgets / Responsive Layouts            │
├─────────────────────────────────────────────────┤
│                 Provider Layer                   │
│  Riverpod Providers / State Notifiers            │
├──────────┬──────────┬──────────┬────────────────┤
│ SSH      │ SFTP     │ Crypto   │ WebDAV         │
│ Service  │ Service  │ Service  │ Service        │
├──────────┴──────────┴──────────┴────────────────┤
│                 Data Layer                       │
│  Models / Repositories / Local DB (drift)        │
├─────────────────────────────────────────────────┤
│                 Platform Layer                   │
│  flutter_secure_storage / path_provider / etc.   │
└─────────────────────────────────────────────────┘
```

## Layer Responsibilities

- **Presentation**: UI rendering, responsive layout switching, user interaction handling
- **Provider**: State management, business logic, data transformation
- **Service**: SSH connection management, SFTP operations, encryption/decryption, WebDAV sync
- **Data**: Model definitions, local persistence, repository abstractions
- **Platform**: Platform-specific storage, file system access, secure keychain

## Key Design Decisions

- **No server agent**: App sends shell commands via SSH and parses stdout. Uses marker-based output delimiters for reliable parsing. See [../protocols/command-parser.md](../protocols/command-parser.md)
- **Single SSH connection per server**: One persistent connection with multiplexed channels for monitoring, terminal, SFTP, and command execution
- **Encrypted vault**: All credentials stored in AES-256-GCM encrypted SQLite database. Master password derived key never persisted — only held in memory during session
- **Sync via encrypted blob**: WebDAV receives only encrypted payloads. Server operator cannot read contents

## Data Flow: Server Monitoring

```
App                          Remote Server
 │                                │
 ├── SSH connect ────────────────>│
 │<──────────────── session ready ┤
 │                                │
 ├── exec(monitor_script) ───────>│
 │<──────── marker-delimited text ┤
 │                                │
 ├── parse markers ──> Provider ──> UI update
 │                                │
 ├── (5s interval) repeat ───────>│
 └────────────────────────────────┘
```

## Data Flow: WebDAV Sync

```
App                     WebDAV Server
 │                           │
 ├── encrypt(vault) ─────>   │
 ├── PUT /orbita.vault ─────>│
 │<───────── 200 OK ─────────┤
 │                           │
 ├── GET /orbita.vault ─────>│
 │<───── encrypted blob ─────┤
 ├── decrypt(blob) ──> merge local
 └───────────────────────────┘
```

## Changelog
- 2026-04-15: Initial creation
