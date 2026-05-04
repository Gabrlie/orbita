import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbita/models/app_theme_seed.dart';
import 'package:orbita/providers/remote_script_provider.dart';
import 'package:orbita/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('theme seed defaults to indigo and persists changes', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    expect(container.read(themeSeedProvider), AppThemeSeed.indigo);

    await container.read(themeSeedProvider.notifier).set(AppThemeSeed.teal);

    expect(container.read(themeSeedProvider), AppThemeSeed.teal);
    expect(prefs.getString('theme_seed'), 'teal');
  });

  test('theme seed falls back to indigo for unknown stored values', () async {
    SharedPreferences.setMockInitialValues({'theme_seed': 'unknown'});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    expect(container.read(themeSeedProvider), AppThemeSeed.indigo);
  });

  test('dynamic color defaults to enabled and persists changes', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    expect(container.read(dynamicColorProvider), isTrue);

    await container.read(dynamicColorProvider.notifier).set(false);

    expect(container.read(dynamicColorProvider), isFalse);
    expect(prefs.getBool('dynamic_color'), isFalse);
  });

  test('stored theme mode and locale still load from preferences', () async {
    SharedPreferences.setMockInitialValues({
      'theme_mode': 'dark',
      'locale': 'en',
    });
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    expect(container.read(themeModeProvider), ThemeMode.dark);
    expect(container.read(localeProvider)?.languageCode, 'en');
  });

  test('terminal appearance defaults and persists changes', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    expect(
      container.read(terminalAppearanceProvider),
      const TerminalAppearance(
        fontFamily: TerminalFontFamily.jetbrainsMono,
        customFontFamily: '',
        fontSize: 14,
        foregroundColor: Color(0xFFECEFF4),
        backgroundColor: Color(0xFF0B1020),
      ),
    );

    const appearance = TerminalAppearance(
      fontFamily: TerminalFontFamily.custom,
      customFontFamily: 'Cascadia Mono',
      fontSize: 16,
      foregroundColor: Color(0xFFFFFFFF),
      backgroundColor: Color(0xFF111111),
    );

    await container.read(terminalAppearanceProvider.notifier).set(appearance);

    expect(container.read(terminalAppearanceProvider), appearance);
    expect(prefs.getString('terminal_font_family'), 'custom');
    expect(prefs.getString('terminal_custom_font_family'), 'Cascadia Mono');
    expect(prefs.getDouble('terminal_font_size'), 16);
    expect(prefs.getInt('terminal_foreground_color'), 0xFFFFFFFF);
    expect(prefs.getInt('terminal_background_color'), 0xFF111111);
  });

  test('user scripts persist through shared preferences', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    final script = await container
        .read(userScriptsProvider.notifier)
        .add(
          name: 'Update app',
          description: 'Run updater',
          command: 'echo ok',
        );

    expect(container.read(userScriptsProvider), hasLength(1));
    expect(prefs.getString('remote_user_scripts'), contains('Update app'));

    await container
        .read(userScriptsProvider.notifier)
        .update(script.copyWith(name: 'Updated app'));

    expect(container.read(userScriptsProvider).single.name, 'Updated app');

    await container.read(userScriptsProvider.notifier).delete(script.id);

    expect(container.read(userScriptsProvider), isEmpty);
  });
}
