import 'package:flutter/material.dart';
import 'package:orbita/models/app_theme_seed.dart';

class AppTheme {
  static const defaultSeedColor = Color(0xFF3F51B5);

  static ThemeData lightTheme({Color seedColor = defaultSeedColor}) =>
      ThemeData(colorScheme: lightScheme(seedColor), useMaterial3: true);

  static ThemeData darkTheme({Color seedColor = defaultSeedColor}) =>
      ThemeData(colorScheme: darkScheme(seedColor), useMaterial3: true);

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
      ThemeData(colorScheme: colorScheme, useMaterial3: true);
}
