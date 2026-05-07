# Server Groups and Tags

> Status: active | Max lines: 100

## Overview

Organize servers with flat groups that affect every server picker/list order.
Assignments and explicit display order are stored as JSON through
`serverGroupProvider`.

## Groups

- A server belongs to at most one group
- Groups are flat (no nesting) to keep UX simple
- Default group: "未命名分组" / "Unnamed Group" (implicit, not stored)
- Group has: `id`, `name`, `createdAt`

- Stored groups display first in user-defined order, followed by ungrouped servers
- Empty custom groups still show on the group management page as drop targets
- List/picker pages hide headers when the only bucket is the unnamed group
- Home, Files, Terminal, Docker, Scripts, and Settings server lists reuse this
  grouping order
- Group icons can be long-pressed to reorder groups
- Server rows can be dragged across groups or before another server in the same
  group to update the shared display order

## Tags

- A server can have 0-N tags
- Tags are free-form strings, auto-suggested from existing tags
- Used for filtering, not for visual grouping
- Max 10 tags per server
- Tags are planned; current implementation only ships groups

### Filter Bar
- Horizontal scrollable `FilterChip` row above server list
- Tap chip to toggle filter (AND logic for multiple tags)
- "All" chip to clear filters

## UI Components

### Phone
- Server list with group sections
- Settings → Server Groups: add/edit/delete groups and drag servers into them

### Tablet
- Same as phone but with more horizontal space for chips
- Group management as dialog/side sheet

## Data Model

```dart
class ServerGroup {
  final String id;
  final String name;
  final DateTime createdAt;
}
```

Assignments are stored separately as `Map<serverId, groupId>` and order as
`Map<groupId, List<serverId>>`, so the server model remains unchanged.

## Changelog
- 2026-05-06: Implement flat groups, shared ordering, group reorder, and server drag assignment
- 2026-04-15: Initial creation
