import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

late final SharedPreferences _prefs;

/// Call once before runApp.
Future<void> initSharedPrefs() async {
  _prefs = await SharedPreferences.getInstance();
}

final sharedPrefsProvider = Provider<SharedPreferences>((ref) => _prefs);

const _keyThemeMode = 'theme_mode';
const _keyLocale = 'locale';

// -- Theme Mode --

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final prefs = ref.read(sharedPrefsProvider);
    final stored = prefs.getString(_keyThemeMode);
    return switch (stored) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    final prefs = ref.read(sharedPrefsProvider);
    await prefs.setString(_keyThemeMode, mode.name);
  }
}

// -- Locale --

final localeProvider =
    NotifierProvider<LocaleNotifier, Locale?>(LocaleNotifier.new);

class LocaleNotifier extends Notifier<Locale?> {
  @override
  Locale? build() {
    final prefs = ref.read(sharedPrefsProvider);
    final stored = prefs.getString(_keyLocale);
    if (stored == null) return null;
    return Locale(stored);
  }

  Future<void> set(Locale? locale) async {
    state = locale;
    final prefs = ref.read(sharedPrefsProvider);
    if (locale == null) {
      await prefs.remove(_keyLocale);
    } else {
      await prefs.setString(_keyLocale, locale.languageCode);
    }
  }
}

// -- Auth / Lock state --

final hasPasswordProvider = Provider<bool>((ref) => false);

final isUnlockedProvider =
    NotifierProvider<IsUnlockedNotifier, bool>(IsUnlockedNotifier.new);

class IsUnlockedNotifier extends Notifier<bool> {
  @override
  bool build() => !ref.watch(hasPasswordProvider);

  void unlock() => state = true;
  void lock() => state = false;
}
