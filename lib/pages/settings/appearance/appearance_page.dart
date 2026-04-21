import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/models/app_theme_seed.dart';
import 'package:orbita/providers/settings_provider.dart';
import 'package:orbita/widgets/common.dart';

enum _LanguageOption { system, zh, en }

class AppearancePage extends ConsumerWidget {
  const AppearancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
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
            padding: const EdgeInsets.fromLTRB(0, 24, 0, 8),
          ),
          _ThemeModePicker(
            selected: currentTheme,
            onChanged: (mode) => ref.read(themeModeProvider.notifier).set(mode),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: Icon(
              Ionicons.color_wand_outline,
              color: theme.colorScheme.primary,
            ),
            title: Text(l10n.dynamicColor),
            subtitle: Text(l10n.dynamicColorDesc),
            value: useDynamicColor,
            onChanged: (enabled) =>
                ref.read(dynamicColorProvider.notifier).set(enabled),
          ),
          SectionHeader(
            title: l10n.themeColor,
            padding: const EdgeInsets.fromLTRB(0, 24, 0, 4),
          ),
          Text(
            l10n.themeColorDesc,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          _ThemeSeedPicker(
            selected: currentSeed,
            onChanged: (seed) => ref.read(themeSeedProvider.notifier).set(seed),
          ),
          const Divider(height: 40),
          SectionHeader(
            title: l10n.language,
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
          ),
          _LanguagePicker(
            selected: _languageOptionFor(currentLocale),
            onChanged: (option) => _setLanguage(ref, option),
          ),
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
          icon: const Icon(Ionicons.contrast_outline),
          label: Text(l10n.themeModeSystem),
        ),
        ButtonSegment(
          value: ThemeMode.light,
          icon: const Icon(Ionicons.sunny_outline),
          label: Text(l10n.themeModeLight),
        ),
        ButtonSegment(
          value: ThemeMode.dark,
          icon: const Icon(Ionicons.moon_outline),
          label: Text(l10n.themeModeDark),
        ),
      ],
      selected: {selected},
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}

class _ThemeSeedPicker extends StatelessWidget {
  final AppThemeSeed selected;
  final ValueChanged<AppThemeSeed> onChanged;

  const _ThemeSeedPicker({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final seed in AppThemeSeed.values)
          _ThemeSeedSwatch(
            label: _themeSeedLabel(l10n, seed),
            seed: seed,
            selected: selected == seed,
            onTap: () => onChanged(seed),
          ),
      ],
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

class _ThemeSeedSwatch extends StatelessWidget {
  final String label;
  final AppThemeSeed seed;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeSeedSwatch({
    required this.label,
    required this.seed,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: InkResponse(
          onTap: onTap,
          radius: 26,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: seed.color,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.outlineVariant,
                width: selected ? 3 : 1,
              ),
            ),
            child: selected
                ? Icon(
                    Ionicons.checkmark_outline,
                    color: theme.colorScheme.surface,
                  )
                : null,
          ),
        ),
      ),
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
          icon: const Icon(Ionicons.earth_outline),
          label: Text(l10n.languageSystem),
        ),
        ButtonSegment(
          value: _LanguageOption.zh,
          icon: const Icon(Ionicons.language_outline),
          label: Text(l10n.languageZh),
        ),
        ButtonSegment(
          value: _LanguageOption.en,
          icon: const Icon(Ionicons.text_outline),
          label: Text(l10n.languageEn),
        ),
      ],
      selected: {selected},
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}
