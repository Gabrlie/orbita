# Navigation Structure

> Status: active | Max lines: 130

## Bottom Navigation (5 Tabs)

| Index | Label (zh) | Label (en) | Icon | Route |
|-------|-----------|-----------|------|-------|
| 0 | 指标 | Metrics | `Ionicons.server_outline` / `Ionicons.server` | `/home` |
| 1 | 文件 | Files | `Ionicons.folder_outline` / `Ionicons.folder` | `/files` |
| 2 | 终端 | Terminal | `Ionicons.terminal_outline` / `Ionicons.terminal` | `/terminal` |
| 3 | Docker | Docker | `Ionicons.cube_outline` / `Ionicons.cube` | `/docker` |
| 4 | 设置 | Settings | `Ionicons.settings_outline` / `Ionicons.settings` | `/settings` |

Files, Terminal, and Docker use browser-like server tabs. The default tab is a
new tab with the shared server picker; choosing a server renames that tab to
the server name and loads the feature content in place.
Files and Docker hide the tab strip on upward scroll; Terminal keeps it fixed.

Selected navigation items use the filled Ionicons icon and primary label/icon
color. The default Material indicator/background is disabled. Phone bottom
navigation uses compact icon/text sizing, reduced icon-label gap, and a subtle
top shadow. Home / Terminal / Docker empty placeholders reuse the same filled
Ionicons as the selected bottom navigation item.
Metrics keeps inline search plus an icon-only add-server button. Files,
Terminal, and Docker use a tab strip with a right-side new-tab button.
Settings has no top app bar; settings subpages hide the shell navigation.

## Route Tree

```
/                               → redirect to /home
/lock                           → LockPage (conditional, full screen, no shell)
/home                           → HomePage (server list with rich cards)
/home/server/:id                → ServerDetailPage (metrics detail, no tabs)
/home/server/:id/logs           → ServerLogPage (in-memory SSH operation logs)
/home/server/:id/test           → ServerConnectionTestPage (latency + logs)
/files                          → Files tabs (default new tab picker)
/files/:id                      → Files tabs with an initial server tab
/terminal                       → Terminal tabs (default new tab picker)
/terminal/:id                   → Terminal tabs with an initial server tab
/docker                         → Docker tabs (default new tab picker)
/docker/:id                     → Docker tabs with an initial server tab
/settings                       → SettingsPage (grouped sections)
/settings/servers               → ServerListPage (settings child style)
/settings/groups                → ServerGroupsPage (drag servers into groups)
/settings/appearance            → AppearancePage (theme + language, functional)
/settings/metrics               → MetricSettingsPage (refresh/SSH timing)
/settings/security              → SecurityPage
/settings/backup-sync           → BackupSyncPage (local/WebDAV backups)
/settings/keys                  → KeyListPage
/settings/scripts               → ScriptsLibraryPage
/settings/snippets              → SnippetsPage
/settings/about                 → AboutPage
```
## Settings Page Sections (order)

1. **服务器管理**: server groups
2. **工具**: scripts, snippets, network/tunnels (disabled)
3. **安全与同步**: security, backup and sync
4. **应用**: appearance, connection config, about

## Server Detail Navigation

Server detail is a single metrics page, not an internal tab container.
The AppBar exposes icon-only jumps to Files, Terminal, and server editing.
The page renders overview, CPU, memory, disk, network, scripts, and tools in
that order. Tool rows open in-app process, IP, and traffic summaries.

## Server Context Menu

- Home top bar shows search and an add-server action
- Search filters the current Metrics list directly without a child page
- Home server card menu uses terminal, files, Docker, refresh, test, logs, reboot, shutdown, edit, delete
- Refresh forces the selected server status stream to restart polling
- Test opens a child page for connection latency and SSH logs
- Logs opens the per-server in-memory SSH operation log page
- Reboot, shutdown, and delete always require confirmation
- Settings server list long-press opens delete confirmation directly

## Server Search

- Metrics AppBar embeds the rounded search field before the add button
- Results update in the current list while typing
- Matching checks server name, host/IP, port, username, OS name, and tags

## Terminal Navigation

- `/terminal` opens a tab strip with a selected new tab and server picker
- Selecting a server uses its remembered direct/tmux mode and opens that terminal
- Server picker long-press menu: connect terminal, reuse tmux, edit, delete
- Server tabs can close even when only one remains; closing the last server tab
  replaces it with a new tab. Only a sole new tab cannot be closed.
- Server detail and Docker exec jumps open `/terminal/:id` as an initial tab
- Mobile terminal dashboard reuses metric detail sections without shortcuts/tools
- Desktop terminal dashboard is always visible on the right
- A bottom-right snippet button collapses into a thin strip and opens searchable command snippets
- Top-level branches stay in an `IndexedStack`; navigation emits a branch
  reset signal so Files, Terminal, Docker, and Metrics clear transient state.
- Leaving Terminal resets tabs and disposes active shells before hiding.

## Docker Navigation

- `/docker` opens the same tabbed server workspace used by Files and Terminal
- Selecting a server turns the active new tab into Docker manager sections:
  overview, containers, compose, images, volumes
- Server detail tool launchers jump to `/docker/:id` as an initial Docker tab
- Container exec routes into `/terminal/:id` with a base64url initial command

## Auth Guard

- `/lock` shows only when `hasPasswordProvider == true`
- Tier 0 (no password): skip lock, go straight to `/home`
- Tier 1/2: show lock page, redirect after unlock

## Responsive Navigation

| Width | Component |
|-------|-----------|
| < 600dp | `NavigationBar` (bottom) |
| 600-839dp | `NavigationRail` (collapsed) |
| 840-1199dp | Narrow `NavigationRail` (collapsible labels) |
| >= 1200dp | Narrow permanent `NavigationRail` (collapsible labels) |

Settings child pages use the same compact top bar and pale list background.
Server lists follow group/server order; if only unnamed exists, headers hide.

## Changelog
- 2026-05-06: Add BackupSyncPage and stabilize branch resets, grouped ordering, snippets, and connection test
- 2026-05-05: Inline Metrics search, reset branches on switch, and refine tabs
