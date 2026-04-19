import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
        fontWeight: states.contains(WidgetState.selected)
            ? FontWeight.w600
            : FontWeight.w400,
      ),
    );

    final destinations = [
      _Dest(
        Icons.space_dashboard_outlined,
        Icons.space_dashboard,
        l10n.navHome,
      ),
      _Dest(Icons.folder_open_outlined, Icons.folder_open, l10n.navFiles),
      _Dest(Icons.terminal_outlined, Icons.terminal, l10n.navTerminal),
      _Dest(Icons.inventory_2_outlined, Icons.inventory_2, l10n.navDocker),
      _Dest(Icons.tune_outlined, Icons.tune, l10n.navSettings),
    ];

    if (width < 600) {
      return Scaffold(
        body: navigationShell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _onNavigate,
          indicatorColor: Colors.transparent,
          labelTextStyle: navLabelStyle,
          destinations: [
            for (final d in destinations)
              NavigationDestination(
                icon: Icon(d.icon, color: unselectedColor),
                selectedIcon: Icon(d.selectedIcon, color: selectedColor),
                label: d.label,
              ),
          ],
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
            const VerticalDivider(thickness: 1, width: 1),
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
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelTextStyle: TextStyle(color: unselectedColor),
              destinations: [
                for (final d in destinations)
                  NavigationRailDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: Text(d.label),
                  ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
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
                  padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
                  child: Text(
                    l10n.appName,
                    style: Theme.of(context).textTheme.titleSmall,
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
          const VerticalDivider(thickness: 1, width: 1),
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
