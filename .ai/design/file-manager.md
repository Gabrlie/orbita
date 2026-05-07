# File Manager (SFTP)

> Status: active | Max lines: 150

## Overview

Full file management via SFTP subsystem of dartssh2. The first active version
opens inside browser-like server tabs and supports server picking, directory
browsing, pull-to-refresh, create file/folder, rename, delete, copy/move,
archive actions, downloads, and built-in text editing for files under 1 MB.

## Operations

| Operation | SFTP Method | Fallback SSH Command |
|-----------|-------------|---------------------|
| List directory | `sftp.listdir()` | `ls -la --time-style=+%s` |
| Read file | `sftp.open() + read()` | — |
| Write file | `sftp.open() + write()` | — |
| Create directory | `sftp.mkdir()` | `mkdir -p` |
| Delete file | `sftp.remove()` | — |
| Delete directory | recursive `sftp.rmdir()` | — |
| Rename / Move | `sftp.rename()` | SFTP copy + delete |
| Copy | SFTP read/write recursion | — |
| Compress / Extract / Preview | — | `zip`, `tar`, `unzip`, `7z` |
| Download | `sftp.open() + read(offset:)` | — |
| Get metadata | `sftp.stat()` | `stat` |
| Change permissions | SSH: `chmod` | — |
| Change owner | SSH: `chown` | — |
| Symlink info | `sftp.readlink()` | `readlink` |

## File Browser UI

### Phone Layout
- Top bar: browser-like server tabs with right-side new-tab button
- New tab: shared server picker; selecting a server renames the active tab
- File toolbar: breadcrumbs on the left with horizontal overflow, then
  download center, refresh, and anchored more menu
- File list: icon + name + size + date, swipe actions (delete, rename)
- System back returns to the parent directory; top-bar back returns to picker
- Long press opens a centered two-column action dialog
- Copy/move show a bottom pending action bar with cancel and paste/move

### Tablet Layout
- Left panel: directory tree (collapsible)
- Right panel: file list with columns (name, size, date, permissions)
- Toolbar: breadcrumbs, sort, filter, view toggle (list/grid)

## Text Editor

- Built-in editor for plain text files (< 1MB)
- Syntax highlighting for supported common formats, with plain text fallback
- Read-only mode for binary detection
- Save = SFTP write back
- Initial editor uses JetBrains Mono, binary-byte detection, unsaved-change
  confirmation, and full-file overwrite via SFTP write/create/truncate.

## Upload / Download

- Upload: pick local file → SFTP write with progress callback
- Download: SFTP read → save to `Downloads/Orbite/<server-name>`, falling back
  to app documents only when a system downloads directory is unavailable
- Download center persists task records in SharedPreferences
- Active transfers support pause, resume, and cancel
- Cancel removes the transfer record and clears partial local data
- Duplicate local downloads are renamed with the same keep-both suffix style
- Completed transfers can be opened through the system app picker or deleted
- Copy and delete use SFTP recursive operations instead of opening extra exec
  channels
- Copy/move conflicts can overwrite or keep both; keep-both names use
  `name(1).ext`, incrementing without stacking duplicate suffixes
- SFTP channel-open failures mark the pooled SSH connection unhealthy and retry
  channel creation once on a fresh connection

## Path Navigation

- Breadcrumb bar: tap any segment to jump; narrow widths scroll horizontally
- Directory changes show a loading overlay even when the previous list remains visible
- Manual path input: tap breadcrumb bar to type
- Bookmarks: user-defined quick-access paths per server
- Default start path: user home (`~`) or custom per server

## Archive Tools

- Compression formats: zip, tar.gz, tar.xz
- Extraction formats: zip, tar, tar.gz, tgz, tar.xz, tar.bz2, 7z, rar
- Archive previews list remote archive contents with file-list styling and a
  breadcrumb rooted at `<archive-name>/`
- Missing remote tools prompt the user before auto-installing, then show a
  centered live output dialog with final success/failure state
- Archive passwords are never logged, but remote process arguments may expose
  them briefly on the server

## Changelog
- 2026-05-05: Add scroll-hiding tabs and merge breadcrumbs into the toolbar
- 2026-05-03: Add archive file-list preview, live tool install output, server-scoped downloads, and keep-both naming
- 2026-05-03: Use SFTP-native copy and show loading overlay during directory changes
- 2026-05-03: Fix file-name dialog cancellation by binding input controller lifecycle to the dialog widget
- 2026-05-02: Add single top bar, breadcrumb jumps, centered actions, archive operations, and persistent downloads
