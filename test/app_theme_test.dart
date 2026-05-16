import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:orbita/app/theme.dart';
import 'package:orbita/models/app_theme_seed.dart';

void main() {
  test(
    'dynamic color ignores manual seed when dynamic scheme is unavailable',
    () {
      final indigo = AppTheme.resolveLightScheme(
        useDynamicColor: true,
        seed: AppThemeSeed.indigo,
        dynamicScheme: null,
      );
      final rose = AppTheme.resolveLightScheme(
        useDynamicColor: true,
        seed: AppThemeSeed.rose,
        dynamicScheme: null,
      );

      expect(rose, indigo);
    },
  );

  test('dynamic color uses dynamic scheme instead of manual seed', () {
    final dynamicScheme = ColorScheme.fromSeed(
      seedColor: Colors.purple,
      brightness: Brightness.light,
    );

    final indigo = AppTheme.resolveLightScheme(
      useDynamicColor: true,
      seed: AppThemeSeed.indigo,
      dynamicScheme: dynamicScheme,
    );
    final orange = AppTheme.resolveLightScheme(
      useDynamicColor: true,
      seed: AppThemeSeed.orange,
      dynamicScheme: dynamicScheme,
    );

    expect(indigo, dynamicScheme);
    expect(orange, dynamicScheme);
  });

  test('manual seed applies only when dynamic color is disabled', () {
    final indigo = AppTheme.resolveLightScheme(
      useDynamicColor: false,
      seed: AppThemeSeed.indigo,
      dynamicScheme: null,
    );
    final teal = AppTheme.resolveLightScheme(
      useDynamicColor: false,
      seed: AppThemeSeed.teal,
      dynamicScheme: null,
    );

    expect(teal.primary, isNot(indigo.primary));
  });

  test('app theme does not force filled input backgrounds', () {
    final theme = AppTheme.themeFromScheme(
      AppTheme.lightScheme(AppThemeSeed.indigo.color),
    );

    expect(theme.inputDecorationTheme.filled, isNot(isTrue));
  });

  test('forui popup surfaces inherit opaque app surface colors', () {
    final scheme = AppTheme.lightScheme(AppThemeSeed.indigo.color);
    final theme = AppTheme.resolveForuiTheme(scheme);

    expect(theme.colors.card, scheme.surface);
    expect(theme.dialogStyle.decoration.color, scheme.surface);
    expect(theme.popoverStyle.decoration.color, scheme.surface);
    expect(theme.selectStyle.contentStyle.decoration.color, scheme.surface);
  });

  test('material dialogs use opaque app surfaces without surface tint', () {
    final scheme = AppTheme.lightScheme(AppThemeSeed.indigo.color);
    final theme = AppTheme.themeFromScheme(scheme);

    expect(theme.dialogTheme.backgroundColor, scheme.surface);
    expect(theme.dialogTheme.surfaceTintColor, Colors.transparent);
  });
}
