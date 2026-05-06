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
const _keyTerminalFontFamily = 'terminal_font_family';
const _keyTerminalCustomFontFamily = 'terminal_custom_font_family';
const _keyTerminalFontSize = 'terminal_font_size';
const _keyTerminalForegroundColor = 'terminal_foreground_color';
const _keyTerminalBackgroundColor = 'terminal_background_color';
const _keyMetricRefreshInterval = 'metric_refresh_interval_seconds';
const _keyMetricSshConnectTimeout = 'metric_ssh_connect_timeout_seconds';
const _keyMetricKeepAliveInterval = 'metric_keep_alive_interval_seconds';
const _keyMetricAutoReconnect = 'metric_auto_reconnect';

enum TerminalFontFamily { jetbrainsMono, system, monospace, custom }

class TerminalAppearance {
  final TerminalFontFamily fontFamily;
  final String customFontFamily;
  final double fontSize;
  final Color foregroundColor;
  final Color backgroundColor;

  const TerminalAppearance({
    this.fontFamily = TerminalFontFamily.jetbrainsMono,
    this.customFontFamily = '',
    this.fontSize = 14,
    this.foregroundColor = const Color(0xFFECEFF4),
    this.backgroundColor = const Color(0xFF0B1020),
  });

  TerminalAppearance copyWith({
    TerminalFontFamily? fontFamily,
    String? customFontFamily,
    double? fontSize,
    Color? foregroundColor,
    Color? backgroundColor,
  }) {
    return TerminalAppearance(
      fontFamily: fontFamily ?? this.fontFamily,
      customFontFamily: customFontFamily ?? this.customFontFamily,
      fontSize: fontSize ?? this.fontSize,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
    );
  }

  String? get effectiveFontFamily {
    return switch (fontFamily) {
      TerminalFontFamily.jetbrainsMono => 'JetBrains Mono',
      TerminalFontFamily.system => null,
      TerminalFontFamily.monospace => 'monospace',
      TerminalFontFamily.custom =>
        customFontFamily.trim().isEmpty ? null : customFontFamily.trim(),
    };
  }

  @override
  bool operator ==(Object other) {
    return other is TerminalAppearance &&
        other.fontFamily == fontFamily &&
        other.customFontFamily == customFontFamily &&
        other.fontSize == fontSize &&
        other.foregroundColor == foregroundColor &&
        other.backgroundColor == backgroundColor;
  }

  @override
  int get hashCode => Object.hash(
    fontFamily,
    customFontFamily,
    fontSize,
    foregroundColor,
    backgroundColor,
  );
}

class MetricSettings {
  final int refreshIntervalSeconds;
  final int sshConnectTimeoutSeconds;
  final int keepAliveIntervalSeconds;
  final bool autoReconnect;

  const MetricSettings({
    this.refreshIntervalSeconds = 10,
    this.sshConnectTimeoutSeconds = 10,
    this.keepAliveIntervalSeconds = 30,
    this.autoReconnect = true,
  });

  Duration get refreshInterval => Duration(seconds: refreshIntervalSeconds);
  Duration get sshConnectTimeout =>
      Duration(seconds: sshConnectTimeoutSeconds);
  Duration get keepAliveInterval =>
      Duration(seconds: keepAliveIntervalSeconds);

  MetricSettings copyWith({
    int? refreshIntervalSeconds,
    int? sshConnectTimeoutSeconds,
    int? keepAliveIntervalSeconds,
    bool? autoReconnect,
  }) {
    return MetricSettings(
      refreshIntervalSeconds:
          refreshIntervalSeconds ?? this.refreshIntervalSeconds,
      sshConnectTimeoutSeconds:
          sshConnectTimeoutSeconds ?? this.sshConnectTimeoutSeconds,
      keepAliveIntervalSeconds:
          keepAliveIntervalSeconds ?? this.keepAliveIntervalSeconds,
      autoReconnect: autoReconnect ?? this.autoReconnect,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MetricSettings &&
        other.refreshIntervalSeconds == refreshIntervalSeconds &&
        other.sshConnectTimeoutSeconds == sshConnectTimeoutSeconds &&
        other.keepAliveIntervalSeconds == keepAliveIntervalSeconds &&
        other.autoReconnect == autoReconnect;
  }

  @override
  int get hashCode => Object.hash(
    refreshIntervalSeconds,
    sshConnectTimeoutSeconds,
    keepAliveIntervalSeconds,
    autoReconnect,
  );
}

int _clampSeconds(int value, int min, int max) {
  return value.clamp(min, max).toInt();
}

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

// -- Terminal Appearance --

final terminalAppearanceProvider =
    NotifierProvider<TerminalAppearanceNotifier, TerminalAppearance>(
      TerminalAppearanceNotifier.new,
    );

class TerminalAppearanceNotifier extends Notifier<TerminalAppearance> {
  static const _default = TerminalAppearance();

  @override
  TerminalAppearance build() {
    final prefs = ref.read(sharedPrefsProvider);
    return TerminalAppearance(
      fontFamily: TerminalFontFamily.values.firstWhere(
        (family) => family.name == prefs.getString(_keyTerminalFontFamily),
        orElse: () => _default.fontFamily,
      ),
      customFontFamily:
          prefs.getString(_keyTerminalCustomFontFamily) ??
          _default.customFontFamily,
      fontSize: (prefs.getDouble(_keyTerminalFontSize) ?? _default.fontSize)
          .clamp(8, 24)
          .toDouble(),
      foregroundColor: Color(
        prefs.getInt(_keyTerminalForegroundColor) ??
            _default.foregroundColor.toARGB32(),
      ),
      backgroundColor: Color(
        prefs.getInt(_keyTerminalBackgroundColor) ??
            _default.backgroundColor.toARGB32(),
      ),
    );
  }

  Future<void> set(TerminalAppearance appearance) async {
    state = appearance;
    final prefs = ref.read(sharedPrefsProvider);
    await prefs.setString(_keyTerminalFontFamily, appearance.fontFamily.name);
    await prefs.setString(
      _keyTerminalCustomFontFamily,
      appearance.customFontFamily,
    );
    await prefs.setDouble(_keyTerminalFontSize, appearance.fontSize);
    await prefs.setInt(
      _keyTerminalForegroundColor,
      appearance.foregroundColor.toARGB32(),
    );
    await prefs.setInt(
      _keyTerminalBackgroundColor,
      appearance.backgroundColor.toARGB32(),
    );
  }
}

// -- Metric Settings --

final metricSettingsProvider =
    NotifierProvider<MetricSettingsNotifier, MetricSettings>(
      MetricSettingsNotifier.new,
    );

class MetricSettingsNotifier extends Notifier<MetricSettings> {
  static const _default = MetricSettings();

  @override
  MetricSettings build() {
    final prefs = ref.read(sharedPrefsProvider);
    return MetricSettings(
      refreshIntervalSeconds: _clampSeconds(
        prefs.getInt(_keyMetricRefreshInterval) ??
            _default.refreshIntervalSeconds,
        3,
        120,
      ),
      sshConnectTimeoutSeconds: _clampSeconds(
        prefs.getInt(_keyMetricSshConnectTimeout) ??
            _default.sshConnectTimeoutSeconds,
        3,
        60,
      ),
      keepAliveIntervalSeconds: _clampSeconds(
        prefs.getInt(_keyMetricKeepAliveInterval) ??
            _default.keepAliveIntervalSeconds,
        5,
        120,
      ),
      autoReconnect:
          prefs.getBool(_keyMetricAutoReconnect) ?? _default.autoReconnect,
    );
  }

  Future<void> set(MetricSettings settings) async {
    final normalized = MetricSettings(
      refreshIntervalSeconds: _clampSeconds(
        settings.refreshIntervalSeconds,
        3,
        120,
      ),
      sshConnectTimeoutSeconds: _clampSeconds(
        settings.sshConnectTimeoutSeconds,
        3,
        60,
      ),
      keepAliveIntervalSeconds: _clampSeconds(
        settings.keepAliveIntervalSeconds,
        5,
        120,
      ),
      autoReconnect: settings.autoReconnect,
    );
    state = normalized;
    final prefs = ref.read(sharedPrefsProvider);
    await prefs.setInt(
      _keyMetricRefreshInterval,
      normalized.refreshIntervalSeconds,
    );
    await prefs.setInt(
      _keyMetricSshConnectTimeout,
      normalized.sshConnectTimeoutSeconds,
    );
    await prefs.setInt(
      _keyMetricKeepAliveInterval,
      normalized.keepAliveIntervalSeconds,
    );
    await prefs.setBool(_keyMetricAutoReconnect, normalized.autoReconnect);
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
