import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/providers/settings_provider.dart';

import 'theme.dart';
import 'router.dart';

class OrbitaApp extends ConsumerWidget {
  const OrbitaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        final lightScheme =
            lightDynamic?.harmonized() ?? AppTheme.lightTheme.colorScheme;
        final darkScheme =
            darkDynamic?.harmonized() ?? AppTheme.darkTheme.colorScheme;

        return MaterialApp.router(
          title: 'Orbita',
          theme: AppTheme.lightTheme.copyWith(colorScheme: lightScheme),
          darkTheme: AppTheme.darkTheme.copyWith(colorScheme: darkScheme),
          themeMode: themeMode,
          locale: locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('zh'),
            Locale('en'),
          ],
          routerConfig: router,
        );
      },
    );
  }
}
