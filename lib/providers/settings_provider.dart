import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbita/models/app_theme_seed.dart';
import 'package:shared_preferences/shared_preferences.dart';

late final SharedPreferences _prefs;

/// Call once before runApp.
Future<void> initSharedPrefs() async {
  _prefs = await SharedPreferences.getInstance();
}

final sharedPrefsProvider = Provider<SharedPreferences>((ref) => _prefs);

const _keyThemeMode = 'theme_mode';
const _keyLocale = 'locale';
const _keyDynamicColor = 'dynamic_color';
const _keyThemeSeed = 'theme_seed';

// -- Theme Mode --

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

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

// -- Dynamic Color --

final dynamicColorProvider = NotifierProvider<DynamicColorNotifier, bool>(
  DynamicColorNotifier.new,
);

class DynamicColorNotifier extends Notifier<bool> {
  @override
  bool build() {
    final prefs = ref.read(sharedPrefsProvider);
    return prefs.getBool(_keyDynamicColor) ?? true;
  }

  Future<void> set(bool enabled) async {
    state = enabled;
    final prefs = ref.read(sharedPrefsProvider);
    await prefs.setBool(_keyDynamicColor, enabled);
  }
}

// -- Theme Seed --

final themeSeedProvider = NotifierProvider<ThemeSeedNotifier, AppThemeSeed>(
  ThemeSeedNotifier.new,
);

class ThemeSeedNotifier extends Notifier<AppThemeSeed> {
  @override
  AppThemeSeed build() {
    final prefs = ref.read(sharedPrefsProvider);
    return AppThemeSeed.fromStorageKey(prefs.getString(_keyThemeSeed));
  }

  Future<void> set(AppThemeSeed seed) async {
    state = seed;
    final prefs = ref.read(sharedPrefsProvider);
    await prefs.setString(_keyThemeSeed, seed.storageKey);
  }
}

// -- Locale --

final localeProvider = NotifierProvider<LocaleNotifier, Locale?>(
  LocaleNotifier.new,
);

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

final isUnlockedProvider = NotifierProvider<IsUnlockedNotifier, bool>(
  IsUnlockedNotifier.new,
);

class IsUnlockedNotifier extends Notifier<bool> {
  @override
  bool build() => !ref.watch(hasPasswordProvider);

  void unlock() => state = true;
  void lock() => state = false;
}
