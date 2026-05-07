# Backup and Sync

> Status: active | Max lines: 120

## Overview

Backup and Sync replaces the old WebDAV-only page. It supports encrypted local folder backups and encrypted WebDAV remote backups. Remote servers only receive encrypted snapshot files.

**Prerequisite**: manual backup, restore, and first automatic-backup enablement require the app password. Biometrics cannot replace that password.

## Targets

| Target | Storage | Credentials |
|--------|---------|-------------|
| Local folder | `orbita-backup.json` in user-selected directory | None |
| WebDAV | configured remote JSON path | URL/user in prefs; password in secure storage |

## Snapshot Scope

Included:
- Servers and SSH authentication references
- SSH keys
- Server groups
- User scripts
- Command snippets

Excluded:
- App password verifier, salts, and biometric settings
- WebDAV credentials
- Update cache, skipped releases, and download tasks
- Platform-only secure-storage implementation details

## Backup Format

- Envelope is JSON with `version`, `createdAt`, `kdf`, `wrappedKey`, and `data`
- `kdf` uses Argon2id parameters from `SecurityCryptoService`
- `wrappedKey` encrypts the random data key with the app-password-derived key
- `data` encrypts the snapshot JSON with AES-256-GCM
- Associated data is `orbita-backup-v1`

## Manual Flow

1. User chooses local folder and/or WebDAV target
2. User starts backup or restore
3. App asks for the app password and verifies it
4. Backup writes the encrypted envelope to enabled targets
5. Restore decrypts the selected envelope and replaces imported collections

## Automatic Flow

- User enables automatic backup after entering the app password once
- App stores an encrypted auto-backup secret in secure storage
- Data changes are debounced for 5 seconds
- Enabled local and WebDAV targets receive the latest encrypted envelope
- Automatic backup writes last success or last error into local preferences

## WebDAV Protocol

- Connection test uses `OPTIONS`
- Upload uses `PUT`
- Restore uses `GET`
- Plain remote content is never uploaded
- WebDAV errors surface as retryable UI messages

## Changelog
- 2026-05-06: Rename feature to Backup and Sync with local/WebDAV targets and encrypted snapshots
- 2026-04-15: Initial creation
