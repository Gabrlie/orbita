import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';

class ResponsiveScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ResponsiveScaffold({super.key, required this.navigationShell});

  void _onNavigate(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final selectedColor = colorScheme.primary;
    final unselectedColor = colorScheme.onSurfaceVariant;
    final navLabelStyle = WidgetStateProperty.resolveWith<TextStyle?>(
      (states) => TextStyle(
        color: states.contains(WidgetState.selected)
            ? selectedColor
            : unselectedColor,
        fontSize: 11,
        fontWeight: states.contains(WidgetState.selected)
            ? FontWeight.w600
            : FontWeight.w400,
      ),
    );

    final destinations = [
      _Dest(Ionicons.server_outline, Ionicons.server, l10n.navHome),
      _Dest(Ionicons.folder_outline, Ionicons.folder, l10n.navFiles),
      _Dest(Ionicons.terminal_outline, Ionicons.terminal, l10n.navTerminal),
      _Dest(Ionicons.cube_outline, Ionicons.cube, l10n.navDocker),
      _Dest(Ionicons.settings_outline, Ionicons.settings, l10n.navSettings),
    ];

    if (width < 600) {
      return Scaffold(
        body: navigationShell,
        bottomNavigationBar: DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withAlpha(28),
                blurRadius: 18,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _onNavigate,
            height: 62,
            elevation: 0,
            backgroundColor: colorScheme.surface,
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.transparent,
            indicatorColor: Colors.transparent,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            labelTextStyle: navLabelStyle,
            destinations: [
              for (final d in destinations)
                NavigationDestination(
                  icon: _BottomNavIcon(icon: d.icon, color: unselectedColor),
                  selectedIcon: _BottomNavIcon(
                    icon: d.selectedIcon,
                    color: selectedColor,
                  ),
                  label: d.label,
                ),
            ],
          ),
        ),
      );
    }

    if (width < 840) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _onNavigate,
              labelType: NavigationRailLabelType.none,
              useIndicator: false,
              selectedIconTheme: IconThemeData(color: selectedColor),
              unselectedIconTheme: IconThemeData(color: unselectedColor),
              destinations: [
                for (final d in destinations)
                  NavigationRailDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: Text(d.label),
                  ),
              ],
            ),
            const SizedBox(width: 8),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    if (width < 1200) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _onNavigate,
              labelType: NavigationRailLabelType.all,
              useIndicator: false,
              selectedIconTheme: IconThemeData(color: selectedColor),
              unselectedIconTheme: IconThemeData(color: unselectedColor),
              selectedLabelTextStyle: TextStyle(
                color: selectedColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelTextStyle: TextStyle(
                color: unselectedColor,
                fontSize: 12,
              ),
              destinations: [
                for (final d in destinations)
                  NavigationRailDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: Text(d.label),
                  ),
              ],
            ),
            const SizedBox(width: 8),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    // Desktop
    return Scaffold(
      body: Row(
        children: [
          NavigationDrawerTheme(
            data: NavigationDrawerThemeData(
              indicatorColor: Colors.transparent,
              iconTheme: WidgetStateProperty.resolveWith(
                (states) => IconThemeData(
                  color: states.contains(WidgetState.selected)
                      ? selectedColor
                      : unselectedColor,
                ),
              ),
              labelTextStyle: navLabelStyle,
            ),
            child: NavigationDrawer(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _onNavigate,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 24, 16, 24),
                  child: Text(
                    l10n.appName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: selectedColor,
                    ),
                  ),
                ),
                for (final d in destinations)
                  NavigationDrawerDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: Text(d.label),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: navigationShell),
        ],
      ),
    );
  }
}

class _Dest {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  const _Dest(this.icon, this.selectedIcon, this.label);
}

class _BottomNavIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _BottomNavIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, 1),
      child: Icon(icon, color: color, size: 22),
    );
  }
}
