import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/providers/settings_provider.dart';

class AppearancePage extends ConsumerWidget {
  const AppearancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final currentTheme = ref.watch(themeModeProvider);
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appearanceTitle)),
      body: ListView(
        children: [
          // -- Theme Section --
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              l10n.themeMode,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          _buildOption(
            context,
            label: l10n.themeModeSystem,
            icon: Icons.brightness_auto_outlined,
            selected: currentTheme == ThemeMode.system,
            onTap: () =>
                ref.read(themeModeProvider.notifier).set(ThemeMode.system),
          ),
          _buildOption(
            context,
            label: l10n.themeModeLight,
            icon: Icons.light_mode_outlined,
            selected: currentTheme == ThemeMode.light,
            onTap: () =>
                ref.read(themeModeProvider.notifier).set(ThemeMode.light),
          ),
          _buildOption(
            context,
            label: l10n.themeModeDark,
            icon: Icons.dark_mode_outlined,
            selected: currentTheme == ThemeMode.dark,
            onTap: () =>
                ref.read(themeModeProvider.notifier).set(ThemeMode.dark),
          ),

          const Divider(height: 32),

          // -- Language Section --
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              l10n.language,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          _buildOption(
            context,
            label: l10n.languageSystem,
            selected: currentLocale == null,
            onTap: () => ref.read(localeProvider.notifier).set(null),
          ),
          _buildOption(
            context,
            label: l10n.languageZh,
            selected: currentLocale?.languageCode == 'zh',
            onTap: () =>
                ref.read(localeProvider.notifier).set(const Locale('zh')),
          ),
          _buildOption(
            context,
            label: l10n.languageEn,
            selected: currentLocale?.languageCode == 'en',
            onTap: () =>
                ref.read(localeProvider.notifier).set(const Locale('en')),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required String label,
    IconData? icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: icon != null ? Icon(icon) : null,
      title: Text(label),
      trailing: selected
          ? Icon(
              Icons.check_circle_outline,
              color: Theme.of(context).colorScheme.primary,
            )
          : null,
      onTap: onTap,
    );
  }
}
