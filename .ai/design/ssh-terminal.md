# SSH Terminal

> Status: active | Max lines: 120

## Overview

Interactive SSH terminal using the `xterm` Flutter package for rendering and
`dartssh2` shell channels through `SshService`.

## Terminal Configuration

| Setting | Default | Configurable |
|---------|---------|-------------|
| Font family | JetBrains Mono | Yes |
| Font size | 14 | Yes (8-24) |
| Foreground color | Light text | Yes (swatches + custom picker) |
| Background color | Dark navy | Yes (swatches + custom picker) |
| Scrollback lines | 1000 | Yes (500-10000) |
| Cursor style | Block | Yes (block/underline/bar) |
| Bell | Vibrate | Yes (vibrate/sound/none) |

Terminal appearance lives in Settings → Appearance & Language. The app font
always remains the platform default; only `TerminalView` uses the selected
terminal font family. Custom installed fonts are accepted by family name.
Foreground and background color rows include a custom palette option with RGB
preview and hue/saturation/value controls.

## Session Management

- `/terminal` first shows a browser-like tab strip with one new tab picker
- Selecting a server uses the last remembered direct/tmux mode for that server
  and turns the active new tab into one shell session
- Terminal keeps the tab strip visible while Files and Docker may hide it on
  upward scroll
- Closing the last server tab replaces it with a new tab; new tabs are not
  closable
- `/terminal/:id` opens the same tab shell with an initial selected server
- Server detail Terminal action opens `/terminal/:id` as an initial tab
- Shell channels come from the global `SshConnectionManager` pool
- Leaving the page closes the shell channel; the pooled SSH connection closes
  when no feature still holds a lease
- Switching to another top-level page emits a branch reset signal; Terminal
  clears tabs and disposes active shell widgets before the branch is hidden
- Initial shell connection starts from active dependencies, avoiding delayed
  context access after the terminal branch is disposed
- Long press on a new-tab server tile opens a popup menu: connect terminal,
  reuse tmux, edit, delete
- Explicit direct/tmux choices update the remembered mode for that server
- If a pooled SSH connection survives app backgrounding but fails to open a
  shell channel, the terminal drops that stale connection and retries once
- Quick reconnect is still deferred

## Key Bindings / Input

### Mobile
- Android/iOS, including tablets, show a two-row Termux-like extra key bar
- Row 1: `ESC`, `/`, `-`, `HOME`, up, `END`, `PGUP`
- Row 2: `TAB`, `CTRL`, `ALT`, left, down, right, `PGDN`
- `CTRL` and `ALT` are sticky for the next non-modifier key, then reset
- Sticky `CTRL`/`ALT` also modify the next hardware/software keyboard text
- The extra key bar sits above the IME when the software keyboard is visible
- Long press for select + copy
- Double tap to select word
- Pinch to zoom (font size)

### Tablet / Desktop
- Desktop platforms use physical keyboard passthrough and no extra key bar
- Standard terminal shortcuts (Ctrl+C, Ctrl+D, Ctrl+Z, etc.)
- Ctrl+Shift+C / V for copy/paste

## Metrics Dashboard

- Desktop terminal pages show a right-side metrics dashboard like FinalShell
- Mobile terminal pages place the dashboard behind a top-right more button
- Opening the mobile dashboard pushes a covering page; back returns to terminal
- The dashboard reuses `ServerMetricSections` with shortcuts/tools hidden
- Terminal pages keep the server status provider active in the background, so
  opening the dashboard does not start from an empty fetch
- Dashboard history is kept while the terminal page is alive and cleared when
  that terminal exits
- Monitor polling retries transient connection loss while the dashboard is
  visible; authentication failures still stop instead of looping

## Command Snippets

- A bottom-right floating button opens searchable command snippets
- Right drag collapses it to a thin edge strip; tapping the strip expands it
- Tapping a snippet closes the sheet and inserts the command into xterm

## Features

- ANSI color support (256 color + truecolor)
- Unicode / CJK character support
- URL detection and clickable links
- Search in scrollback buffer
- Share / export terminal output as text
- Optional tmux attach-or-create reuse via `tmux new-session -A -s orbita_<id>`

## Shell Channel Setup

```
1. SshService.connect(server credentials)
2. SshConnectionManager.acquire(server) → pooled SshClientSession lease
3. lease.openShell() → SshShellSession
4. optional: verify tmux exists, then send attach/create command
5. session.stdout → xterm input
6. xterm output → session.stdin
7. session.stderr → xterm input (merged)
8. Handle window resize → session.resizeTerminal(cols, rows)
```

## Changelog
- 2026-05-06: Add safe branch disposal, snippet strip, and preserved dashboard history
- 2026-05-05: Add reset-on-navigation terminal tabs with close-last recovery
- 2026-05-04: Lower terminal minimum font size to 8 and add custom color palette picker
- 2026-05-02: Add resume-safe terminal reconnect and dashboard monitoring recovery behavior
- 2026-04-30: Add pooled connection usage and tmux reuse entries on picker/detail terminal actions
