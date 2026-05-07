# Command Snippets

> Status: active | Max lines: 100

## Overview

A lightweight library of frequently used commands for quick access and
insertion. Simpler than full scripts: typically single-line or short commands.

## Data Model

```dart
class CommandSnippet {
  final String id;
  final String name;       // e.g., "查看磁盘占用前10"
  final String command;    // e.g., "du -sh /* 2>/dev/null | sort -rh | head -10"
  final DateTime createdAt;
}
```

Stored in `SharedPreferences` as JSON through `commandSnippetProvider`.

## Built-in Snippets

| Name | Command |
|------|---------|
| 查看磁盘占用 TOP 10 | `du -sh /* 2>/dev/null \| sort -rh \| head -10` |
| 查看监听端口 | `ss -tlnp` |
| 查看当前连接数 | `ss -s` |
| 查看登录失败记录 | `lastb \| head -20` |
| 查看系统日志最近50行 | `journalctl -n 50 --no-pager` |
| 清理APT缓存 | `apt clean && apt autoclean` |
| 清理YUM缓存 | `yum clean all` |
| 查看Docker占用空间 | `docker system df` |
| 重启所有停止的容器 | `docker start $(docker ps -aq --filter status=exited)` |
| 检查内存占用 TOP 10 | `ps aux --sort=-%mem \| head -11` |

Built-in snippets are planned but not implemented yet. Current snippets are
user-created and fully editable/deletable.

## Access Points

- **Snippet library page**: Settings → snippets, search, add, edit, delete
- **Terminal quick-insert**: edge-collapsible button → searchable sheet → insert into terminal
- **Server detail**: deferred; tools remain process/IP/traffic only

## UI

### Phone
- List with search bar at top
- Tap → edit
- Delete icon → confirmation, then remove
- FAB: add new snippet
- Terminal button collapses to a thin edge strip; tapping expands it

### Tablet
- Two-column: snippet list (left) + preview/edit (right)

## Changelog
- 2026-05-06: Implement user snippet CRUD and edge-collapsible terminal quick insert
- 2026-04-15: Initial creation
