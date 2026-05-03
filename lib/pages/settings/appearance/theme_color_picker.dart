import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/app/theme.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/models/app_theme_seed.dart';

class ThemeColorPicker extends StatelessWidget {
  final bool dynamicSelected;
  final AppThemeSeed selectedSeed;
  final VoidCallback onDynamicSelected;
  final ValueChanged<AppThemeSeed> onSeedSelected;

  const ThemeColorPicker({
    super.key,
    required this.dynamicSelected,
    required this.selectedSeed,
    required this.onDynamicSelected,
    required this.onSeedSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final dynamicScheme = dynamicSelected
        ? theme.colorScheme
        : ColorScheme.fromSeed(
            seedColor: AppTheme.defaultSeedColor,
            brightness: theme.brightness,
          );

    final options = [
      _ThemeColorOption(
        label: l10n.dynamicColor,
        scheme: dynamicScheme,
        selected: dynamicSelected,
        icon: Ionicons.sparkles,
        onTap: onDynamicSelected,
      ),
      for (final seed in AppThemeSeed.values)
        _ThemeColorOption(
          label: _themeSeedLabel(l10n, seed),
          scheme: ColorScheme.fromSeed(
            seedColor: seed.color,
            brightness: theme.brightness,
          ),
          selected: !dynamicSelected && selectedSeed == seed,
          onTap: () => onSeedSelected(seed),
        ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final minWidth = options.length * 64 + (options.length - 1) * 12;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: constraints.maxWidth > minWidth
                  ? constraints.maxWidth
                  : minWidth.toDouble(),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: options,
            ),
          ),
        );
      },
    );
  }

  String _themeSeedLabel(AppLocalizations l10n, AppThemeSeed seed) {
    return switch (seed) {
      AppThemeSeed.indigo => l10n.themeColorIndigo,
      AppThemeSeed.blue => l10n.themeColorBlue,
      AppThemeSeed.violet => l10n.themeColorViolet,
      AppThemeSeed.teal => l10n.themeColorTeal,
      AppThemeSeed.emerald => l10n.themeColorEmerald,
      AppThemeSeed.orange => l10n.themeColorOrange,
      AppThemeSeed.rose => l10n.themeColorRose,
    };
  }
}

class _ThemeColorOption extends StatelessWidget {
  final String label;
  final ColorScheme scheme;
  final bool selected;
  final IconData? icon;
  final VoidCallback onTap;

  const _ThemeColorOption({
    required this.label,
    required this.scheme,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(16);

    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 64,
              height: 64,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: scheme.primary,
                borderRadius: radius,
              ),
              child: Stack(
                children: [
                  if (selected)
                    Positioned(
                      top: 7,
                      left: 7,
                      child: Icon(
                        Ionicons.checkmark,
                        size: 15,
                        color: _readableOn(scheme.primary),
                      ),
                    ),
                  if (icon != null)
                    Positioned(
                      top: 7,
                      right: 7,
                      child: Icon(
                        icon,
                        size: 15,
                        color: _readableOn(scheme.primary),
                      ),
                    ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 22,
                    child: ColoredBox(
                      color: theme.colorScheme.surface.withAlpha(224),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _DerivedColorDot(color: scheme.primary),
                          const SizedBox(width: 5),
                          _DerivedColorDot(color: scheme.secondary),
                          const SizedBox(width: 5),
                          _DerivedColorDot(color: scheme.tertiary),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _readableOn(Color color) {
    final brightness = ThemeData.estimateBrightnessForColor(color);
    return brightness == Brightness.dark ? Colors.white : Colors.black;
  }
}

class _DerivedColorDot extends StatelessWidget {
  final Color color;

  const _DerivedColorDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
