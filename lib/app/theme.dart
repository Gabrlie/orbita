import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:orbita/models/app_theme_seed.dart';

class AppTheme {
  static const defaultSeedColor = Color(0xFF3F51B5);

  static ThemeData lightTheme({Color seedColor = defaultSeedColor}) =>
      _buildTheme(lightScheme(seedColor));

  static ThemeData darkTheme({Color seedColor = defaultSeedColor}) =>
      _buildTheme(darkScheme(seedColor));

  static ColorScheme lightScheme(Color seedColor) =>
      ColorScheme.fromSeed(seedColor: seedColor, brightness: Brightness.light);

  static ColorScheme darkScheme(Color seedColor) =>
      ColorScheme.fromSeed(seedColor: seedColor, brightness: Brightness.dark);

  static ColorScheme resolveLightScheme({
    required bool useDynamicColor,
    required AppThemeSeed seed,
    required ColorScheme? dynamicScheme,
  }) {
    if (useDynamicColor) {
      return dynamicScheme ?? lightScheme(defaultSeedColor);
    }
    return lightScheme(seed.color);
  }

  static ColorScheme resolveDarkScheme({
    required bool useDynamicColor,
    required AppThemeSeed seed,
    required ColorScheme? dynamicScheme,
  }) {
    if (useDynamicColor) {
      return dynamicScheme ?? darkScheme(defaultSeedColor);
    }
    return darkScheme(seed.color);
  }

  static ThemeData themeFromScheme(ColorScheme colorScheme) =>
      _buildTheme(colorScheme);

  static FThemeData resolveForuiTheme(ColorScheme colorScheme) {
    final base = colorScheme.brightness == Brightness.dark
        ? FThemes.blue.dark.touch
        : FThemes.blue.light.touch;
    final colors = base.colors.copyWith(
      brightness: colorScheme.brightness,
      systemOverlayStyle: colorScheme.brightness == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      background: colorScheme.surface,
      foreground: colorScheme.onSurface,
      primary: colorScheme.primary,
      primaryForeground: colorScheme.onPrimary,
      secondary: colorScheme.secondaryContainer,
      secondaryForeground: colorScheme.onSecondaryContainer,
      muted: colorScheme.surfaceContainerHighest,
      mutedForeground: colorScheme.onSurfaceVariant,
      destructive: colorScheme.error,
      destructiveForeground: colorScheme.onError,
      error: colorScheme.error,
      errorForeground: colorScheme.onError,
      card: colorScheme.surface,
      border: colorScheme.outlineVariant,
    );
    return FThemeData(
      debugLabel: 'Orbita ${colorScheme.brightness.name}',
      colors: colors,
      typography: base.typography,
      touch: true,
    );
  }

  static ThemeData _buildTheme(ColorScheme colorScheme) {
    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      fontFamilyFallback: const [
        'Microsoft YaHei UI',
        'Microsoft YaHei',
        'PingFang SC',
        'Noto Sans CJK SC',
        'Segoe UI',
        'Arial Unicode MS',
      ],
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      popupMenuTheme: PopupMenuThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: colorScheme.surface,
        elevation: 4,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleSize: const Size(32, 4),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 2,
      ),
    );
  }
}
