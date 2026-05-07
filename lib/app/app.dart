import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/models/app_security.dart';
import 'package:orbita/pages/lock/lock_page.dart';
import 'package:orbita/providers/backup_sync_provider.dart';
import 'package:orbita/providers/security_provider.dart';
import 'package:orbita/providers/settings_provider.dart';
import 'package:orbita/providers/update_provider.dart';

import 'theme.dart';
import 'router.dart';

class OrbitaApp extends ConsumerStatefulWidget {
  const OrbitaApp({super.key});

  @override
  ConsumerState<OrbitaApp> createState() => _OrbitaAppState();
}

class _OrbitaAppState extends ConsumerState<OrbitaApp>
    with WidgetsBindingObserver {
  Timer? _lockTimer;
  DateTime _lastActivityAt = DateTime.now();
  DateTime? _backgroundedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _lockTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _lockIfIdle(),
    );
  }

  @override
  void dispose() {
    _lockTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _backgroundedAt = DateTime.now();
      final security = ref.read(appSecurityProvider).value;
      if (security?.lockMode == AppLockMode.onExit) {
        unawaited(ref.read(appSecurityProvider.notifier).lock());
      }
    }
    if (state == AppLifecycleState.resumed) {
      final backgroundedAt = _backgroundedAt;
      _backgroundedAt = null;
      if (backgroundedAt == null) return;
      final security = ref.read(appSecurityProvider).value;
      if (security?.lockMode != AppLockMode.afterDuration) return;
      final elapsed = DateTime.now().difference(backgroundedAt);
      if (elapsed.inMinutes >= security!.lockAfterMinutes) {
        unawaited(ref.read(appSecurityProvider.notifier).lock());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final useDynamicColor = ref.watch(dynamicColorProvider);
    final themeSeed = ref.watch(themeSeedProvider);
    ref.watch(backupSyncProvider);
    ref.watch(appUpdateProvider);

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        final lightScheme = AppTheme.resolveLightScheme(
          useDynamicColor: useDynamicColor,
          seed: themeSeed,
          dynamicScheme: lightDynamic?.harmonized(),
        );
        final darkScheme = AppTheme.resolveDarkScheme(
          useDynamicColor: useDynamicColor,
          seed: themeSeed,
          dynamicScheme: darkDynamic?.harmonized(),
        );

        return MaterialApp.router(
          title: 'Orbita',
          theme: AppTheme.themeFromScheme(lightScheme),
          darkTheme: AppTheme.themeFromScheme(darkScheme),
          themeMode: themeMode,
          locale: locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('zh'), Locale('en')],
          routerConfig: router,
          builder: (context, child) {
            final security = ref.watch(appSecurityProvider).value;
            final locked =
                security != null &&
                security.hasPassword &&
                !security.isUnlocked;
            if (locked) return const LockPage();
            return Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: (_) => _markActivity(),
              onPointerMove: (_) => _markActivity(),
              child: child ?? const SizedBox.shrink(),
            );
          },
        );
      },
    );
  }

  void _markActivity() {
    _lastActivityAt = DateTime.now();
  }

  void _lockIfIdle() {
    final security = ref.read(appSecurityProvider).value;
    if (security == null ||
        !security.hasPassword ||
        !security.isUnlocked ||
        security.lockMode != AppLockMode.afterDuration) {
      return;
    }
    final idle = DateTime.now().difference(_lastActivityAt);
    if (idle.inMinutes >= security.lockAfterMinutes) {
      unawaited(ref.read(appSecurityProvider.notifier).lock());
    }
  }
}
