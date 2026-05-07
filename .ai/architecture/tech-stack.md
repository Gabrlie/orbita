# Technology Stack

> Status: active | Max lines: 130

## Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| flutter_riverpod | ^3.3.x | State management (Notifier-based) |
| go_router | ^17.x | Declarative routing with StatefulShellRoute |
| dartssh2 | ^2.x | SSH/SFTP client |
| xterm | ^4.x | Terminal emulator widget |
| drift | ^2.x | SQLite ORM for local data |
| sqlite3_flutter_libs | ^0.5.x | SQLite native bindings |
| flutter_secure_storage | ^9.x | Platform keychain access |
| pointycastle | ^3.x | AES-256-GCM + Argon2id |
| webdav_client | ^2.x | WebDAV sync |
| freezed_annotation | ^2.x | Immutable model generation |
| json_annotation | ^4.x | JSON serialization |
| path_provider | ^2.x | Platform directory paths |
| shared_preferences | ^2.5.x | Non-sensitive app settings (theme, locale) |
| simple_icons | ^14.6.x | OS brand icons (Ubuntu, Debian, etc.) |
| ionicons | ^0.2.x | App navigation and settings outline/filled icons |
| dynamic_color | ^1.x | Optional MD3 dynamic color from system wallpaper |
| local_auth | ^2.x | Biometric authentication (fingerprint/face) |
| ota_update | ^7.x | Android APK install trigger |
| http | ^1.x | GitHub Release API calls |
| url_launcher | ^6.x | Open external links |
| crypto | ^3.x | SHA256 verification for update packages |
| flutter_localizations | sdk | i18n support |
| intl | ^0.20.x | Localization utilities |

## Dev Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| build_runner | ^2.x | Code generation runner |
| freezed | ^2.x | Immutable model code gen |
| json_serializable | ^6.x | JSON code gen |
| drift_dev | ^2.x | Drift code gen |
| flutter_lints | ^6.x | Lint rules |

## Selection Rationale

- **dartssh2** over ssh2: actively maintained, pure Dart, supports SFTP subsystem
- **Riverpod 3.x** over Bloc: Notifier API, less boilerplate, compile-time safety
- **drift** over Hive/Isar: SQL power, migrations, type-safe queries, well-maintained
- **simple_icons** over custom SVGs: 1500+ brand icons with official colors, zero asset management
- **go_router** over auto_route: official Flutter team recommendation, StatefulShellRoute
- **shared_preferences**: lightweight, no override hacks — init in main, direct provider access

## Minimum Platform Versions

| Platform | Minimum Version |
|----------|----------------|
| Android | API 24 (Android 7.0) |
| iOS | 15.0 |
| macOS | 12.0 |
| Windows | 10 (1903+) |
| Linux | Ubuntu 20.04+ |

## Android Build

- Application ID / namespace: `top.gabrlie.orbita`
- Local Gradle should run with JDK 21 to avoid Kotlin DSL failures on JDK 25

## Changelog
- 2026-05-02: Set Android package identity and document the JDK 21 build requirement
- 2026-04-19: Clarify dynamic_color as optional appearance setting
- 2026-04-19: Add ionicons for navigation and settings iconography
- 2026-04-15: Add simple_icons, shared_preferences, update Riverpod to 3.x Notifier API
- 2026-04-15: Initial creation
