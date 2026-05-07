# Material Design 3 Design System

> Status: active | Max lines: 130

## Color Scheme

- Primary seed default: **Indigo** (`Color(0xFF3F51B5)`)
- Dynamic color via `dynamic_color` package (Android wallpaper), enabled by default
- Manual seed colors only affect the app after dynamic color is disabled
- Seed choices: indigo, blue, violet, teal, emerald, orange, rose
- Dynamic color unavailable fallback: default indigo, not the selected seed
- Manual mode: selected seed via `ColorScheme.fromSeed()` for light and dark
- Dark/Light mode: follows system by default, user can override in settings

## App Identity

- Android launcher icon: black background with white Ionicons terminal-outline
- Android package name: `top.gabrlie.orbita`

## Typography

Material 3 default type scale. App UI uses the platform default font. The
interactive terminal can use JetBrains Mono, system/default, monospace, or a
custom installed font family name.
Windows builds include common CJK font fallbacks to avoid missing-glyph squares
when the system default stack is incomplete.

## Reusable Widgets

### OsIcon (`widgets/os_icon.dart`)
- Displays OS brand icon using `simple_icons` package
- Official brand colors (Ubuntu orange, Debian red, Arch blue, etc.)
- `OsType` enum: 17 OS types with brand icon + color
- `OsIcon(type: OsType.ubuntu, size: 20)` — sized to match text
- `OsListTile` — for OS selection in forms/pickers
- `osTypeFromString()` — fuzzy match from `/etc/os-release` ID

### CircularMetric (`widgets/circular_metric.dart`)
- Ring progress with percentage center text + subtitle below
- Color gradient by usage: ≤20% tertiary, ≤40% primary, ≤60% amber, ≤75% orange, ≤90% deepOrange, >90% error
- Custom `_RingPainter` via `CustomPainter`
- Default size 52px

### ServerCard (`widgets/server_card.dart`)
- Header: OsIcon (20px) + server name + uptime (power icon) + latest load
- Metrics row (only when online): 3 CircularMetric rings (CPU/Mem/Disk) + 2 TextMetric columns (Network/IO)
- TextMetric: ↑↓ arrows in grey (`onSurfaceVariant`), speed + cumulative total
- Metric labels are localized through `l10n`
- Offline: shows OsIcon + name + "离线" label, no metrics
- Card: tinted item surface, 16dp radius, subtle elevation/shadow, no grey fill

### Home More Menu
- Home AppBar uses an icon-only Ionicons more button with no filled background
- The menu contains disabled placeholders for future layout and group controls

### App Bars
- All top app bars use the app surface background and no surface tint
- Page titles use the default app bar title weight unless a feature requires emphasis

### Common (`widgets/common.dart`)
- `SectionHeader` — colored title for grouped lists (settings page)
- `EmptyState` — icon + title + subtitle centered placeholder
- `TonalListBackground` — `surface` page/list backing
- `tonalItemColor()` — dynamic-color-safe tinted item surface
- `showConfirmDialog()` — returns bool, supports destructive style
- `showInfoDialog()` — single OK button

### ServerTabsScaffold (`widgets/server_tabs_scaffold.dart`)
- Safe-area browser-like top strip used by Files, Terminal, and Docker
- Default new tab shows a server picker; selecting a server renames the tab
- Tabs fit their labels with a capped max width
- Active tabs use a primary-tinted filled surface; inactive tabs stay quieter
- Right-side add button opens another new tab; only a sole new tab cannot close
- Files and Docker can hide the strip on upward scroll

### ResponsiveScaffold (`widgets/responsive_scaffold.dart`)
- Wraps `StatefulNavigationShell` from go_router
- Switches NavigationBar / NavigationRail / NavigationDrawer by width
- 5 destinations: Home, Files, Terminal, Docker, Settings
- Navigation uses Ionicons outline icons when inactive and filled primary icons when active
- Selected navigation labels/icons use primary color; indicator backgrounds are disabled
- Phone bottom navigation uses compact icons/text and a subtle top shadow

### Settings Icons
- Settings list and subpage actions use Ionicons outline icons
- Setting item leading icons use theme primary color and no background container
- SettingsPage dividers start under the icon area and extend under the chevron area
- Disabled settings keep outline icons with disabled text/icon color

### ThemeColorPicker (`pages/settings/appearance/theme_color_picker.dart`)
- Dynamic color is the first option in the same picker as manual seed colors
- Each option is a rounded square dominated by the primary color
- The lower third uses a mask with primary, secondary, and tertiary swatches
- Dynamic color option adds an Ionicons sparkle mark in the top-right corner
- Options have no outer stroke; selected options only show a check mark
- Options use a horizontally distributed row: first and last sit near the
  container edges, with equal spacing between remaining items

### Terminal UI
- Terminal rendering uses `xterm` with configurable foreground, background,
  font family, and font size
- Terminal font size range is 8-24
- Terminal foreground/background pickers include a final custom color palette
  option with RGB preview
- Mobile/tablet terminal pages show a compact two-row extra key bar
- Desktop terminal pages show a fixed right-side metrics dashboard
- Mobile terminal dashboard opens as a covering page from the top-right more button

## Component Patterns

| Component | Usage |
|-----------|-------|
| NavigationBar | Phone bottom navigation (5 tabs) |
| NavigationRail | Tablet and desktop side navigation, with collapsible labels |
| Card (filled + border) | Server cards |
| ListTile | Settings items, file entries |
| PopupMenuButton | Home overflow actions |
| SnackBar | Operation feedback |
| ServerTabsScaffold | Files, Terminal, Docker server workspaces |
| SegmentedButton | Appearance theme mode and language pickers |
| ThemeColorPicker | Dynamic color + popular theme color picker |
| TerminalExtraKeysBar | Mobile/tablet terminal helper keys |
| TerminalDashboard | Terminal metrics dashboard |

## Changelog
- 2026-05-05: Add tonal list backgrounds and server workspace tab scaffold
- 2026-05-04: Add collapsible desktop rail, Windows font fallback, distributed theme colors, and terminal color palette
- 2026-05-02: Add Android package identity and terminal-outline launcher icon rule
- 2026-04-21: Add terminal appearance settings, extra key bar, and dashboard patterns
- 2026-04-21: Refine nav shadows, settings icons, ServerCard shadow, and theme color picker
