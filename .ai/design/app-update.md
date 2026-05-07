# App Update (GitHub Release)

> Status: draft | Max lines: 120

## Overview

Check `Gabrlie/Orbita` GitHub Releases for app updates. Android downloads the matching APK, verifies SHA256, and triggers the system installer. Other platforms download/open the matching package when available.

## Version Rules

- App version uses `MAJOR.MINOR.PATCH+BUILD`; current first release is `1.0.1+2`
- GitHub tag uses `vMAJOR.MINOR.PATCH`; first release tag is `v1.0.1`
- Compare only `MAJOR.MINOR.PATCH`; Android `BUILD` maps to `versionCode`
- Android `BUILD` MUST increment for every uploaded release build
- GitHub API: `GET https://api.github.com/repos/Gabrlie/Orbita/releases/latest`
- Cache `ETag` and latest response in `shared_preferences`; manual checks bypass expiry

## Update Flow

1. Fetch latest release metadata (tag, assets list, release notes)
2. If `remote_version > local_version`:
   - Show update dialog with release notes (body markdown)
   - User taps "Update" or "Skip"
3. Find matching asset by platform + architecture naming convention
4. Download asset + corresponding `.sha256` file
5. Verify: `SHA256(downloaded_file) == content_of(.sha256)`
6. If mismatch → abort, show error
7. Trigger platform-specific install

## Asset Naming Convention

```
orbita-{version}-{platform}-{arch}.{ext}
orbita-{version}-{platform}-{arch}.{ext}.sha256
```

| Platform | Arch | Extension | Example |
|----------|------|-----------|---------|
| android | arm64-v8a | .apk | `orbita-1.0.1-android-arm64-v8a.apk` |
| android | armeabi-v7a | .apk | `orbita-1.0.1-android-armeabi-v7a.apk` |
| android | x86_64 | .apk | `orbita-1.0.1-android-x86_64.apk` |
| windows | x64 | .msix | `orbita-1.2.0-windows-x64.msix` |
| linux | x64 | .AppImage | `orbita-1.2.0-linux-x64.AppImage` |
| linux | arm64 | .AppImage | `orbita-1.2.0-linux-arm64.AppImage` |
| macos | universal | .dmg | `orbita-1.2.0-macos-universal.dmg` |

## Platform-Specific Install

| Platform | Method | Notes |
|----------|--------|-------|
| Android | `ota_update` plugin → trigger APK install intent | Works directly, user confirms system dialog |
| Windows | Download .msix → prompt user to open | Or launch `Add-AppPackage` via PowerShell |
| Linux | Download AppImage → mark executable, prompt | User runs manually |
| macOS | Download .dmg → prompt user to open | Gatekeeper may require signing |
| iOS | NOT supported | App Store only — show "check App Store" message |

## Android Release Build

- Release signing reads ignored `android/key.properties`
- `ota_update` requires core library desugaring in the Android app module
- Kotlin incremental compilation is disabled to avoid cross-drive cache paths on Windows

## UI

### Update Available Dialog
- Title: "新版本可用 v{version}"
- Body: release notes (markdown rendered)
- Actions: "立即更新" / "稍后提醒" / "跳过此版本"

### Settings → About
- Current version display
- "检查更新" button
- Last checked time

### Download Progress
- Show progress bar during download
- "Cancel" button
- SHA256 verification status indicator

## Skipped Versions

- User can skip a specific version → stored in `shared_preferences`
- Skipped version won't trigger auto-prompt
- Manual check respects the skip flag until a newer tag appears

## Changelog
- 2026-05-07: Add Android release signing and desugaring build notes
- 2026-05-06: Pin repository, version rules, ETag cache, and Android ABI asset names
- 2026-04-15: Initial creation
