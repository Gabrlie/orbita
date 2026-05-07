# Security Model

> Status: active | Max lines: 120

## Trust Boundaries

```
┌─────────────────────────────────┐
│      User Device (Trusted)      │
│                                 │
│  ┌───────────────────────────┐  │
│  │  Orbita App               │  │
│  │  - Encrypted vault (AES)  │  │
│  │  - Derived key (in-mem)   │  │
│  │  - Platform keychain      │  │
│  └──────────┬────────────────┘  │
└─────────────┼───────────────────┘
              │ SSH (encrypted channel)
              ▼
┌─────────────────────────────────┐
│      Remote Server              │
│  (Trusted for its own data)     │
└─────────────────────────────────┘
              │ HTTPS
              ▼
┌─────────────────────────────────┐
│      WebDAV Server              │
│  (Untrusted — sees only         │
│   encrypted blobs)              │
└─────────────────────────────────┘
```

## Threat Mitigations

| Threat | Mitigation |
|--------|-----------|
| Device theft | Master password + auto-lock + encrypted vault |
| Credential leak | AES-256-GCM encryption at rest; zero plaintext on disk |
| MITM on SSH | Host key fingerprint verification (TOFU) |
| MITM on WebDAV | HTTPS required; data encrypted before upload |
| WebDAV server breach | Server only has encrypted blobs; useless without master password |
| Brute force master password | Argon2id (memory-hard); rate limiting on unlock attempts |
| Memory dump | Clear derived key on lock; minimize secret lifetime in memory |
| Malicious script injection | Scripts stored in encrypted vault; user must explicitly create/run |
| Biometric misuse | Biometrics unlock only the app lock, never backup encryption |

## Credential Storage Rules

1. **NEVER** store plaintext passwords or keys on disk
2. **NEVER** log sensitive data (passwords, keys, tokens)
3. Tier 1/2: master-derived key exists ONLY in memory, ONLY while vault is unlocked
4. Tier 0: device key in platform keychain, vault auto-decrypted (no user prompt)
5. Salt stored in platform-secure storage (`flutter_secure_storage`)
6. Private keys encrypted in vault same as passwords
7. App-password verifier and auto-backup secret stay in secure storage
8. Biometric unlock MUST NOT grant backup/restore authorization
9. WebDAV password stays in secure storage and is excluded from backups

## Host Key Verification

- **TOFU** (Trust On First Use): accept host key on first connection, store fingerprint
- On subsequent connections: compare fingerprint, reject if changed
- If changed: warn user with prominent dialog, offer to update (user must confirm)
- Store fingerprints in encrypted vault (synced across devices)

## SSH Key Management

- Support importing existing keys (OpenSSH, PEM format)
- Support generating new key pairs (Ed25519 recommended, RSA 4096 as fallback)
- Private keys always encrypted in vault
- Public keys can be viewed/copied for adding to `authorized_keys`

## Network Security

- All SSH connections use standard SSH protocol encryption
- WebDAV sync requires HTTPS (reject plain HTTP, unless user explicitly overrides for LAN)
- No telemetry, no analytics, no external API calls beyond user-configured services

## App Lock Policy

- Default lock mode is never lock
- User can lock when leaving the app
- User can lock after a configured inactivity duration
- Lock state is in memory only; app relaunch starts locked if a password exists

## Backup Boundary

- Manual backup and restore always verify the app password
- Automatic backup may run only after password verification stores its secret
- Backup snapshots include servers, keys, groups, user scripts, and snippets
- Backup snapshots exclude passwords for the app lock, biometrics, WebDAV, and updates

## Changelog
- 2026-05-06: Add app lock policy and backup authorization boundaries
- 2026-04-15: Update for 3-tier security model, add biometric rules
- 2026-04-15: Initial creation
