import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbita/models/app_security.dart';
import 'package:orbita/providers/settings_provider.dart';
import 'package:orbita/services/app_security_service.dart';

const _keyBiometricEnabled = 'security_biometric_enabled';
const _keyLockMode = 'security_lock_mode';
const _keyLockAfterMinutes = 'security_lock_after_minutes';

final appSecurityServiceProvider = Provider<AppSecurityService>((ref) {
  return AppSecurityService();
});

final appSecurityProvider =
    AsyncNotifierProvider<AppSecurityNotifier, AppSecurityState>(
      AppSecurityNotifier.new,
    );

class AppSecurityNotifier extends AsyncNotifier<AppSecurityState> {
  @override
  Future<AppSecurityState> build() async {
    final prefs = ref.read(sharedPrefsProvider);
    final hasPassword = await ref
        .read(appSecurityServiceProvider)
        .hasPassword();
    final lockModeName = prefs.getString(_keyLockMode);
    final lockMode = switch (lockModeName) {
      'afterDuration' => AppLockMode.afterDuration,
      'onExit' => AppLockMode.afterDuration,
      _ => AppLockMode.never,
    };
    return AppSecurityState(
      hasPassword: hasPassword,
      biometricEnabled:
          hasPassword && (prefs.getBool(_keyBiometricEnabled) ?? false),
      isUnlocked: !hasPassword,
      lockMode: lockMode,
      lockAfterMinutes: (prefs.getInt(_keyLockAfterMinutes) ?? 5).clamp(1, 240),
    );
  }

  Future<void> setPassword(String password) async {
    await ref.read(appSecurityServiceProvider).setPassword(password);
    final current = await future;
    state = AsyncData(current.copyWith(hasPassword: true, isUnlocked: true));
  }

  Future<void> clearPassword() async {
    await ref.read(appSecurityServiceProvider).clearPassword();
    final prefs = ref.read(sharedPrefsProvider);
    await prefs.setBool(_keyBiometricEnabled, false);
    final current = await future;
    state = AsyncData(
      current.copyWith(
        hasPassword: false,
        biometricEnabled: false,
        isUnlocked: true,
      ),
    );
  }

  Future<bool> unlockWithPassword(String password) async {
    final service = ref.read(appSecurityServiceProvider);
    final key = await service.verifyPassword(password);
    if (key == null) return false;
    await service.ensureAutoBackupSecret(password);
    final current = await future;
    state = AsyncData(current.copyWith(isUnlocked: true));
    return true;
  }

  Future<bool> unlockWithBiometrics(String reason) async {
    final current = await future;
    if (!current.hasPassword || !current.biometricEnabled) return false;
    final ok = await ref
        .read(appSecurityServiceProvider)
        .authenticateBiometric(reason);
    if (!ok) return false;
    state = AsyncData(current.copyWith(isUnlocked: true));
    return true;
  }

  Future<bool> setBiometricEnabled({
    required bool enabled,
    required String reason,
  }) async {
    final current = await future;
    if (enabled) {
      if (!current.hasPassword) return false;
      final canUse = await ref
          .read(appSecurityServiceProvider)
          .canUseBiometrics();
      if (!canUse) return false;
      final ok = await ref
          .read(appSecurityServiceProvider)
          .authenticateBiometric(reason);
      if (!ok) return false;
    }
    await ref.read(sharedPrefsProvider).setBool(_keyBiometricEnabled, enabled);
    state = AsyncData(current.copyWith(biometricEnabled: enabled));
    return true;
  }

  Future<void> setLockPolicy(AppLockMode mode, int minutes) async {
    final normalizedMinutes = minutes.clamp(1, 240);
    final prefs = ref.read(sharedPrefsProvider);
    await prefs.setString(_keyLockMode, mode.name);
    await prefs.setInt(_keyLockAfterMinutes, normalizedMinutes);
    final current = await future;
    state = AsyncData(
      current.copyWith(lockMode: mode, lockAfterMinutes: normalizedMinutes),
    );
  }

  Future<void> lock() async {
    final current = await future;
    if (!current.hasPassword || current.lockMode == AppLockMode.never) return;
    state = AsyncData(current.copyWith(isUnlocked: false));
  }
}
