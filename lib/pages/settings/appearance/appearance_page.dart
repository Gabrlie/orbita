import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/pages/settings/appearance/terminal_appearance_section.dart';
import 'package:orbita/pages/settings/appearance/theme_color_picker.dart';
import 'package:orbita/providers/settings_provider.dart';
import 'package:orbita/widgets/common.dart';
import 'package:orbita/widgets/orbita_forui.dart';
import 'package:orbita/widgets/settings_tiles.dart';

enum _LanguageOption { system, zh, en }

class AppearancePage extends ConsumerWidget {
  const AppearancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentTheme = ref.watch(themeModeProvider);
    final currentLocale = ref.watch(localeProvider);
    final useDynamicColor = ref.watch(dynamicColorProvider);
    final currentSeed = ref.watch(themeSeedProvider);

    return Scaffold(
      appBar: compactPageAppBar(
        context,
        title: l10n.appearanceTitle,
        fallbackLocation: '/settings',
      ),
      body: TonalListBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            OrbitaSettingsTileGroup(
              title: l10n.appearanceTitle,
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
              children: [
                FTile.raw(
                  child: _PreferenceBlock(
                    title: l10n.themeMode,
                    child: OrbitaSwipeableTabs<ThemeMode>(
                      value: currentTheme,
                      values: ThemeMode.values,
                      labelBuilder: (mode) => switch (mode) {
                        ThemeMode.system => l10n.themeModeSystem,
                        ThemeMode.light => l10n.themeModeLight,
                        ThemeMode.dark => l10n.themeModeDark,
                      },
                      iconBuilder: (mode) => Icon(
                        switch (mode) {
                          ThemeMode.system => Ionicons.contrast_outline,
                          ThemeMode.light => Ionicons.sunny_outline,
                          ThemeMode.dark => Ionicons.moon_outline,
                        },
                        size: 18,
                      ),
                      onChanged: (mode) =>
                          ref.read(themeModeProvider.notifier).set(mode),
                    ),
                  ),
                ),
                FTile.raw(
                  child: _PreferenceBlock(
                    title: l10n.language,
                    child: OrbitaSwipeableTabs<_LanguageOption>(
                      value: _languageOptionFor(currentLocale),
                      values: _LanguageOption.values,
                      labelBuilder: (option) => switch (option) {
                        _LanguageOption.system => l10n.languageSystem,
                        _LanguageOption.zh => l10n.languageZh,
                        _LanguageOption.en => l10n.languageEn,
                      },
                      iconBuilder: (option) => Icon(
                        switch (option) {
                          _LanguageOption.system => Ionicons.earth_outline,
                          _LanguageOption.zh => Ionicons.language_outline,
                          _LanguageOption.en => Ionicons.text_outline,
                        },
                        size: 18,
                      ),
                      onChanged: (option) => _setLanguage(ref, option),
                    ),
                  ),
                ),
              ],
            ),
            OrbitaSettingsTileGroup(
              title: l10n.themeColor,
              children: [
                FTile.raw(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: ThemeColorPicker(
                      dynamicSelected: useDynamicColor,
                      selectedSeed: currentSeed,
                      onDynamicSelected: () {
                        ref.read(dynamicColorProvider.notifier).set(true);
                      },
                      onSeedSelected: (seed) {
                        ref.read(themeSeedProvider.notifier).set(seed);
                        ref.read(dynamicColorProvider.notifier).set(false);
                      },
                    ),
                  ),
                ),
              ],
            ),
            const TerminalAppearanceSection(),
          ],
        ),
      ),
    );
  }

  _LanguageOption _languageOptionFor(Locale? locale) {
    return switch (locale?.languageCode) {
      'zh' => _LanguageOption.zh,
      'en' => _LanguageOption.en,
      _ => _LanguageOption.system,
    };
  }

  void _setLanguage(WidgetRef ref, _LanguageOption option) {
    final locale = switch (option) {
      _LanguageOption.zh => const Locale('zh'),
      _LanguageOption.en => const Locale('en'),
      _LanguageOption.system => null,
    };
    ref.read(localeProvider.notifier).set(locale);
  }
}

class _PreferenceBlock extends StatelessWidget {
  final String title;
  final Widget child;

  const _PreferenceBlock({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}
