# Server Status Monitoring

> Status: active | Max lines: 150

## Metrics Collected

| Metric | Source Command | Refresh Interval |
|--------|---------------|-----------------|
| CPU usage (per-core + total) | `grep '^cpu' /proc/stat` (two samples, 0.5s apart) | user setting (default 10s) |
| Memory (total/used/free/cached) | `grep` selected fields from `/proc/meminfo` | user setting (default 10s) |
| Disk usage (root mount) | `df -B1 -T /` | 30s |
| Network I/O (per interface) | `cat /proc/net/dev` (delta between samples) | user setting (default 10s) |
| Load average (1/5/15 min) | `cat /proc/loadavg` | user setting (default 10s) |
| Uptime | `cat /proc/uptime` | 60s |
| OS info | `cat /etc/os-release` | on connect |

## Collection Strategy

Use a single inline shell script per poll cycle to minimize SSH overhead:

```bash
echo "==S1=="; grep '^cpu' /proc/stat
sleep 0.5
echo "==S2=="; grep '^cpu' /proc/stat
echo "==UP=="; cat /proc/uptime
echo "==LA=="; cat /proc/loadavg
echo "==MEM=="; grep -E '^(MemTotal|MemAvailable|Cached):' /proc/meminfo
echo "==DF=="; df -B1 -T / 2>/dev/null | tail -1
echo "==ND=="; cat /proc/net/dev 2>/dev/null
echo "==DI=="; cat /proc/diskstats 2>/dev/null
echo "==NC=="; nproc 2>/dev/null || echo 1
echo "==OS=="; (. /etc/os-release 2>/dev/null && printf '%s\n%s\n' "${ID:-unknown}" "${PRETTY_NAME:-${ID:-unknown}}") || printf 'unknown\nunknown\n'; uname -m 2>/dev/null || echo unknown
echo "==END=="
```

OS detail stores ID, `PRETTY_NAME`, and machine architecture for display.
Static info (hostname, CPU model, kernel) is collected once on connection via a separate script.

## CPU Calculation

```
usage% = 100 * (1 - (idle2 - idle1) / (total2 - total1))
```

Where total = user + nice + system + idle + iowait + irq + softirq + steal.

## UI Components

### Server Card (Home Page — implemented)
- Header: OsIcon (brand icon, 20px) + server name + uptime (power icon) + latest load average only; host/IP is hidden
- Metrics row (only when online):
  - Left 3 columns: CircularMetric rings for CPU / Mem / Disk (52px, color-coded by usage)
  - Right 2 columns: TextMetric for Network / I/O (↑↓ speed + cumulative, grey arrows)
- Offline servers: OsIcon + name + "离线" label, no metrics
- Card style: tinted item surface over page surface, 16dp rounded corners, subtle shadow for boundary
- Pull-to-refresh on Home forces all server status streams to restart polling
- Home card long-press menu: terminal, files, Docker, refresh, test, logs,
  reboot, shutdown, edit, delete; terminal uses remembered direct/tmux mode
- Home AppBar embeds search on the left and keeps an icon-only add-server
  action on the right; search filters the current list in place.

### Server Logs (implemented)
- Each server keeps the latest 200 SSH operation logs in memory
- Logs include connection events, status command output, fetch errors, and stop events
- Long-press server menu opens `/home/server/:id/logs`
- Logs are cleared when app state is reset; no persistent log storage

### Connection Test (implemented)
- Long-press server menu opens `/home/server/:id/test`
- The test resolves server/key config, measures SSH latency, and shows step logs
- Reboot, shutdown, and delete actions require confirmation before execution

### Status Detail Page (implemented)
- AppBar: smaller server name plus compact icon-only actions for Files,
  Terminal, and server editing; host/IP is hidden
- Single scroll page on tonal list background, no internal tabs
- Section order: system overview, CPU, memory, disk, network, tools
- Section headers use a left icon/title and right chevron; tapping collapses or expands the section with an animated height change
- System overview header shows full OS `PRETTY_NAME` plus architecture; the white bordered card shows 1/5/15 load, uptime, and CPU ring
- CPU shows per-state breakdown, total ring, percent usage line chart, and per-core progress bars
- Memory shows used/cache/free/total in a 2x2 grid, stacked bar, percent usage line chart, and ring
- Disk shows root mount, filesystem badge, used/total, percent, and free bytes
- Network shows upload/download rates, a two-color upload/download trend, and per-interface cards
- Trend lines draw five y-axis intervals from the origin and up to six timestamp x-axis marks that shift left as newer samples arrive; percent charts show `%`, network charts scale to the last six samples' max rate
- Tools are compact in-app rows for process list, IP address, and traffic summaries
- Terminal dashboard reuses this detail component with shortcuts/tools hidden;
  terminal pages keep the server status stream warm in the background

### Connection Config (implemented)
- `/settings/metrics` is labeled "连接配置" and controls metric refresh
  interval, SSH connect timeout, keep-alive interval, and auto reconnect
- Connection config is opened from Settings; server detail edit opens the
  selected server form and returns to detail
- SSH connection manager is recreated when timeout/keep-alive settings change

### Tablet Layout
- Left column: summary cards (CPU, memory, load)
- Right column: detailed views (disk table, network graph, process list)

## In-App Notifications (Foreground Only)

Alerts are ONLY active while the app is running. No background monitoring, no push notifications.

- Users set per-server thresholds in server settings
- Thresholds: CPU > N% for M seconds, Memory > N%, Disk > N%
- When exceeded: show in-app `SnackBar` notification + badge on server card
- Notification sound/vibration: configurable (default: vibrate)
- Alert history: store last 20 alerts per server (in memory, cleared on app close)
- No persistent storage of alerts — this is not a monitoring/probe tool

## Changelog
- 2026-05-06: Add connection test, grouped lists, add action, detail edit, and terminal dashboard reuse
- 2026-05-05: Add metric settings, dual network trend, compact in-app metric tools
- 2026-05-05: Hide metric IPs and restyle detail as collapsible icon sections with full OS names
- 2026-05-05: Replace server detail tabs with a single metrics-first detail page
- 2026-04-19: Add forced refresh behavior and in-memory server log page
