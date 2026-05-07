# Responsive Layout

> Status: active | Max lines: 120

## Breakpoints

| Name | Width | Device Examples |
|------|-------|----------------|
| compact | < 600dp | Phone portrait |
| medium | 600–839dp | Phone landscape, small tablet |
| expanded | 840–1199dp | Tablet, foldable |
| large | >= 1200dp | Desktop, large tablet landscape |

Use `MediaQuery.sizeOf(context).width` or `LayoutBuilder` for breakpoint detection.

## Navigation Pattern per Breakpoint

| Breakpoint | Navigation | Content |
|------------|-----------|---------|
| compact | `NavigationBar` (bottom) | Single column, full width |
| medium | `NavigationRail` (left, collapsed) | Single column with more padding |
| expanded | `NavigationRail` (left, extended) | Two-column (list + detail) |
| large | `NavigationDrawer` (permanent) | Two or three columns |

## Adaptive Scaffold

Build a `ResponsiveScaffold` widget that:
1. Reads current breakpoint from `MediaQuery`
2. Renders appropriate navigation component
3. Passes content builder for the body area
4. Handles navigation state via `go_router`

```dart
// Pseudocode — actual implementation may vary
class ResponsiveScaffold extends StatelessWidget {
  final Widget child;
  final int selectedIndex;
  final Function(int) onDestinationSelected;
}
```

## Page Layout Patterns

### List-Detail Pattern (Servers, Containers, Files)
- **compact**: list page → navigate to detail page (push route)
- **expanded+**: list panel (left) + detail panel (right), no route push

### Dashboard Pattern (Server Status)
- **compact**: vertical scrolling card list
- **expanded+**: grid of cards (2-3 columns)

### Editor Pattern (Terminal, Script Editor)
- **compact/mobile OS**: full-screen editor with a bottom extra key bar
- **desktop OS**: editor with a right-side terminal metrics dashboard
- Terminal session routes may hide global shell navigation to maximize space

## Spacing and Sizing

- Page padding: 16dp (compact), 24dp (expanded+)
- Card gap: 12dp
- Min touch target: 48dp × 48dp
- Max content width on large screens: 1200dp (centered)

## Changelog
- 2026-04-21: Clarify terminal extra key bar and desktop dashboard behavior
- 2026-04-15: Confirm implemented breakpoints match spec (ResponsiveScaffold)
- 2026-04-15: Initial creation
