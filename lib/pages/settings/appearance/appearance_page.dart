import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/pages/settings/appearance/terminal_appearance_section.dart';
import 'package:orbita/pages/settings/appearance/theme_color_picker.dart';
import 'package:orbita/providers/settings_provider.dart';
import 'package:orbita/widgets/common.dart';

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
      appBar: AppBar(title: Text(l10n.appearanceTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          SectionHeader(
            title: l10n.themeMode,
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _ThemeModePicker(
              selected: currentTheme,
              onChanged: (mode) =>
                  ref.read(themeModeProvider.notifier).set(mode),
            ),
          ),
          SectionHeader(
            title: l10n.themeColor,
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
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
          SectionHeader(
            title: l10n.language,
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _LanguagePicker(
              selected: _languageOptionFor(currentLocale),
              onChanged: (option) => _setLanguage(ref, option),
            ),
          ),
          const TerminalAppearanceSection(),
        ],
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

class _ThemeModePicker extends StatelessWidget {
  final ThemeMode selected;
  final ValueChanged<ThemeMode> onChanged;

  const _ThemeModePicker({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SegmentedButton<ThemeMode>(
      showSelectedIcon: false,
      segments: [
        ButtonSegment(
          value: ThemeMode.system,
          icon: const Icon(Ionicons.contrast_outline, size: 18),
          label: Text(l10n.themeModeSystem),
        ),
        ButtonSegment(
          value: ThemeMode.light,
          icon: const Icon(Ionicons.sunny_outline, size: 18),
          label: Text(l10n.themeModeLight),
        ),
        ButtonSegment(
          value: ThemeMode.dark,
          icon: const Icon(Ionicons.moon_outline, size: 18),
          label: Text(l10n.themeModeDark),
        ),
      ],
      selected: {selected},
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}

class _LanguagePicker extends StatelessWidget {
  final _LanguageOption selected;
  final ValueChanged<_LanguageOption> onChanged;

  const _LanguagePicker({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SegmentedButton<_LanguageOption>(
      showSelectedIcon: false,
      segments: [
        ButtonSegment(
          value: _LanguageOption.system,
          icon: const Icon(Ionicons.earth_outline, size: 18),
          label: Text(l10n.languageSystem),
        ),
        ButtonSegment(
          value: _LanguageOption.zh,
          icon: const Icon(Ionicons.language_outline, size: 18),
          label: Text(l10n.languageZh),
        ),
        ButtonSegment(
          value: _LanguageOption.en,
          icon: const Icon(Ionicons.text_outline, size: 18),
          label: Text(l10n.languageEn),
        ),
      ],
      selected: {selected},
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}
