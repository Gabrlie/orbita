# Encryption and Security

> Status: active | Max lines: 200

## Overview

Three-tier security model. Users choose app-lock protection. Server passwords, SSH keys, and connection profiles stay in platform secure storage or encrypted snapshots; backup/restore always requires the app password.

## Security Tiers

| Tier | Name | Unlock Method | Key Source | Backup/Restore |
|------|------|--------------|-----------|----------------|
| 0 | No password | Automatic (no prompt) | Device keychain / secure storage | Manual restore NOT available |
| 1 | Password only | App password prompt | Argon2id(password, salt) | Available |
| 2 | Password + Biometric | Biometric or password | Same as Tier 1 | Password still required |

**Rule**: Biometric requires password enabled first (same as phone lock screen pattern).
**Rule**: Biometric can replace app-lock unlock only. It MUST NOT replace the app password for backup encryption, backup restore, or import authorization.

## Cryptographic Primitives

| Purpose | Algorithm | Parameters |
|---------|-----------|------------|
| Key derivation (Tier 1/2) | Argon2id | memory: 19MB, iterations: 2, parallelism: 1, output: 32 bytes |
| Data encryption | AES-256-GCM | 96-bit nonce, 128-bit auth tag |
| Key verification (Tier 1/2) | HMAC-SHA256 | Verify master password correctness |
| Device key (Tier 0) | Random 256-bit | Generated once, stored in platform keychain |

## Tier 0: No Password

### Setup
1. Generate random 256-bit key
2. Store key in `flutter_secure_storage` (Android Keystore / iOS Keychain)
3. Encrypt vault with this key
4. App launches → auto-decrypt, no prompt

### Characteristics
- Data encrypted at rest (protected by device security)
- No user interaction needed to unlock
- Key is device-bound — lost device = lost key
- Backup restore disabled until an app password exists
- If user later enables password → re-encrypt vault with password-derived key

## Tier 1: Password Only

### First Setup
1. User creates app password (minimum 6 chars)
2. Generate random 16-byte salt
3. Store salt in `flutter_secure_storage`
4. Derive key: `Argon2id(password, salt) → 32-byte key`
5. Compute verification: `HMAC-SHA256(key, "orbita-app-password-v1")` → store hash
6. Encrypt vault with derived key

### Unlock
1. User enters master password
2. Read salt from `flutter_secure_storage`
3. Derive key → verify HMAC → if match, decrypt vault
4. Hold key in memory until lock

### Auto-lock
- Lock mode: never (default), on leaving app, or after N minutes of inactivity
- On lock: zero-fill key in memory, clear decrypted cache

## Tier 2: Password + Biometric

### Setup (requires Tier 1 already active)
1. User enables biometric in settings
2. Authenticate with biometric to confirm availability
3. On unlock: biometric sets in-memory app-lock state to unlocked
4. Backup/restore still prompts for the app password

### Fallback
- Biometric fails 3 times → fall back to password input
- Biometric unavailable (hardware) → password only
- User can always choose password entry instead

## Tier Switching

| From | To | Action |
|------|-----|--------|
| 0 → 1 | Set password | Generate salt, derive new key, re-encrypt vault, delete device key |
| 1 → 2 | Enable biometric | Store derived key with biometric protection |
| 2 → 1 | Disable biometric | Remove biometric-protected key from keychain |
| 1 → 0 | Remove password | Generate device key, re-encrypt vault, delete salt/verification |
| 2 → 0 | Remove all | Disable biometric first, then remove password |

## Vault Structure

```json
{
  "version": 1,
  "tier": 0,
  "salt": "base64... (null for tier 0)",
  "verification": "base64... (null for tier 0)",
  "nonce": "base64...",
  "tag": "base64...",
  "data": "base64(AES-256-GCM encrypted JSON)...",
  "updated_at": "ISO8601"
}
```

Decrypted `data`:
```json
{
  "servers": [
    {
      "id": "uuid",
      "name": "My Server",
      "host": "192.168.1.1",
      "port": 22,
      "username": "root",
      "auth_type": "password|key",
      "password": "...",
      "private_key": "...",
      "passphrase": "...",
      "group_id": "uuid|null",
      "tags": ["web", "prod"]
    }
  ],
  "groups": [...],
  "scripts": [...],
  "snippets": [...],
  "webdav_config": {...},
  "host_keys": {...}
}
```

## Change Master Password (Tier 1/2)

1. Verify current password
2. Decrypt vault with old key
3. Generate new salt, derive new key from new password
4. Re-encrypt vault with new key
5. If biometric enabled: no biometric backup key is created

## Backup Encryption

- Manual backup/restore verifies the app password before encrypting/decrypting
- Automatic backup stores a random backup data key in secure storage after first password verification
- Backup envelope wraps the data key with an app-password-derived Argon2id key
- Snapshot data is encrypted with AES-256-GCM and associated data `orbita-backup-v1`
- Biometric unlock never exposes or substitutes the backup encryption password

## Implementation Notes

- Lock screen (`lock_page.dart`) checks `appSecurityProvider`
- If no app password exists → redirect to `/home` via `addPostFrameCallback`
- Auth state managed by `AppSecurityNotifier` in `security_provider.dart`
- Theme/locale preferences use `shared_preferences` (non-sensitive, separate from vault)
- SSH key deletion is guarded in `KeyListNotifier.deleteKey()`
- A key used by any key-auth server cannot be deleted until those servers change
  authentication method or select another key
- Key management shows how many servers currently reference each SSH key
- Windows and macOS key management can scan `~/.ssh` / `%USERPROFILE%\.ssh`
  and import local `id_ed25519` / `id_rsa` keys while skipping duplicates

## Changelog
- 2026-05-06: Align app password, biometric unlock, lock policy, and backup encryption rules
- 2026-05-06: Show SSH key server usage counts in key management
- 2026-05-04: Add desktop local SSH key import behavior
- 2026-04-30: Add SSH key deletion guard for servers that still reference a key
- 2026-04-15: Add implementation notes for conditional lock screen
