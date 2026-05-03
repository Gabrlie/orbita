import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';

class ResponsiveScaffold extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  final bool hideNavigation;

  const ResponsiveScaffold({
    super.key,
    required this.navigationShell,
    this.hideNavigation = false,
  });

  @override
  State<ResponsiveScaffold> createState() => _ResponsiveScaffoldState();
}

class _ResponsiveScaffoldState extends State<ResponsiveScaffold> {
  var _railExpanded = true;

  void _onNavigate(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
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

    if (widget.hideNavigation) {
      return Scaffold(body: widget.navigationShell);
    }

    if (width < 600) {
      return Scaffold(
        body: widget.navigationShell,
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
            selectedIndex: widget.navigationShell.currentIndex,
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

    final expanded = width >= 840 && _railExpanded;
    return Scaffold(
      body: _RailLayout(
        expanded: expanded,
        currentIndex: widget.navigationShell.currentIndex,
        destinations: destinations,
        selectedColor: selectedColor,
        unselectedColor: unselectedColor,
        onNavigate: _onNavigate,
        onToggle: () => setState(() => _railExpanded = !_railExpanded),
        child: widget.navigationShell,
      ),
    );
  }
}

class _RailLayout extends StatelessWidget {
  final bool expanded;
  final int currentIndex;
  final List<_Dest> destinations;
  final Color selectedColor;
  final Color unselectedColor;
  final ValueChanged<int> onNavigate;
  final VoidCallback onToggle;
  final Widget child;

  const _RailLayout({
    required this.expanded,
    required this.currentIndex,
    required this.destinations,
    required this.selectedColor,
    required this.unselectedColor,
    required this.onNavigate,
    required this.onToggle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        NavigationRail(
          selectedIndex: currentIndex,
          onDestinationSelected: onNavigate,
          extended: expanded,
          minWidth: 58,
          minExtendedWidth: 156,
          labelType: NavigationRailLabelType.none,
          useIndicator: false,
          selectedIconTheme: IconThemeData(color: selectedColor, size: 22),
          unselectedIconTheme: IconThemeData(color: unselectedColor, size: 22),
          selectedLabelTextStyle: TextStyle(
            color: selectedColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelTextStyle: TextStyle(
            color: unselectedColor,
            fontSize: 12,
          ),
          leading: Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 12),
            child: IconButton(
              icon: Icon(
                expanded
                    ? Ionicons.chevron_back_outline
                    : Ionicons.chevron_forward_outline,
              ),
              onPressed: onToggle,
            ),
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
        const SizedBox(width: 4),
        Expanded(child: child),
      ],
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
