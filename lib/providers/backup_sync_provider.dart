import 'dart:async';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbita/models/backup_models.dart';
import 'package:orbita/providers/backup_sync_dependencies.dart';
import 'package:orbita/providers/command_snippet_provider.dart';
import 'package:orbita/providers/key_provider.dart';
import 'package:orbita/providers/remote_script_provider.dart';
import 'package:orbita/providers/security_provider.dart';
import 'package:orbita/providers/server_group_provider.dart';
import 'package:orbita/providers/server_provider.dart';
import 'package:orbita/providers/settings_provider.dart';
import 'package:orbita/services/backup_settings_store.dart';
import 'package:orbita/services/backup_snapshot_service.dart';

final backupSyncProvider = AsyncNotifierProvider<BackupSyncNotifier, BackupSettings>(BackupSyncNotifier.new);

class BackupSyncNotifier extends AsyncNotifier<BackupSettings> {
  Timer? _autoTimer;

  @override
  Future<BackupSettings> build() async {
    ref.onDispose(() => _autoTimer?.cancel());
    _listenForBackupDataChanges();
    return BackupSettingsStore(ref.read(sharedPrefsProvider)).read();
  }

  Future<void> pickLocalFolder() async {
    final path = await FilePicker.getDirectoryPath();
    if (path == null) return;
    await _save((settings) => settings.copyWith(localEnabled: true, localFolder: path));
  }

  Future<void> setLocalEnabled(bool enabled) =>
      _save((settings) => settings.copyWith(localEnabled: enabled));

  Future<void> setWebDavConfig({
    required String url,
    required String username,
    required String password,
    required String remoteFolder,
  }) async {
    if (password.isNotEmpty) {
      await ref
          .read(secureStorageProvider)
          .write(key: backupSecureWebDavPasswordKey, value: password);
    }
    await _save((settings) {
      return settings.copyWith(
        webdavEnabled: true,
        webdavUrl: url.trim(),
        webdavUsername: username.trim(),
        webdavRemoteFolder: BackupSettingsStore.normalizeRemoteFolder(
          remoteFolder,
        ),
      );
    });
  }

  Future<void> setWebDavEnabled(bool enabled) =>
      _save((settings) => settings.copyWith(webdavEnabled: enabled));

  Future<void> setAutoBackupTime(int minutes) async {
    await _save(
      (settings) => settings.copyWith(
        autoBackupTimeMinutes:
            BackupSettingsStore.normalizeAutoBackupTimeMinutes(minutes),
      ),
    );
  }

  Future<void> testWebDav() async {
    final settings = await future;
    await ref
        .read(webDavBackupServiceProvider)
        .testFolder(
          baseUrl: settings.webdavUrl,
          remoteFolder: settings.webdavRemoteFolder,
          username: settings.webdavUsername,
          password: await _webDavPassword(),
        );
  }

  Future<void> setAutoBackup(bool enabled) async {
    if (!enabled) {
      await _save((settings) => settings.copyWith(autoBackupEnabled: false));
      return;
    }
    await _requireTarget();
    await _storedAutoSecret();
    await _save((settings) => settings.copyWith(autoBackupEnabled: true));
    _scheduleAutoBackupSoon();
  }

  Future<void> manualBackup() async {
    await _requireTarget();
    final deviceName = await _backupDeviceName();
    final envelope = ref
        .read(backupEncryptionServiceProvider)
        .encryptWithSecret(
          await buildBackupSnapshot(ref, deviceName: deviceName),
          await _storedAutoSecret(),
        );
    await _writeTargets(envelope, deviceName: deviceName);
  }

  Future<List<BackupEntry>> listLocalBackups() async {
    final settings = await future;
    return ref.read(backupTargetServiceProvider).listLocal(settings);
  }

  Future<List<BackupEntry>> listWebDavBackups() async {
    final settings = await future;
    return ref
        .read(backupTargetServiceProvider)
        .listWebDav(settings, await _webDavPassword());
  }

  Future<void> restoreBackup(BackupEntry entry, String password) async {
    final envelope = await ref
        .read(backupTargetServiceProvider)
        .read(entry, await future, await _webDavPassword());
    await ref
        .read(backupRestoreServiceProvider)
        .restoreWithPassword(ref, envelope, password);
    await ref.read(appSecurityServiceProvider).verifyPassword(password);
  }

  Future<bool> restoreBackupSilently(BackupEntry entry) async {
    final envelope = await ref
        .read(backupTargetServiceProvider)
        .read(entry, await future, await _webDavPassword());
    final secret = await _storedAutoSecretOrNull();
    if (secret != null) {
      final restored = await ref
          .read(backupRestoreServiceProvider)
          .tryRestoreWithSecret(ref, envelope, secret);
      if (restored) return true;
    }
    final password = ref.read(appSecurityServiceProvider).sessionPassword;
    if (password != null && password.isNotEmpty) {
      final restored = await ref
          .read(backupRestoreServiceProvider)
          .tryRestoreWithPassword(ref, envelope, password);
      if (restored) return true;
    }
    return false;
  }

  Future<void> _runAutoBackup() async {
    final settings = await future;
    if (!settings.autoBackupEnabled || !_hasTarget(settings)) return;
    final secret = await _storedAutoSecretOrNull();
    if (secret == null) return;
    final deviceName = await _backupDeviceName();
    final envelope = ref
        .read(backupEncryptionServiceProvider)
        .encryptWithSecret(
          await buildBackupSnapshot(ref, deviceName: deviceName),
          secret,
        );
    await _writeTargets(envelope, silent: true, deviceName: deviceName);
  }

  Future<void> _writeTargets(
    String envelope, {
    bool silent = false,
    required String deviceName,
  }) async {
    final settings = await future;
    if (!_hasTarget(settings)) {
      if (silent) return;
      throw const BackupException(BackupException.noTarget);
    }
    final fileName = ref
        .read(backupFileServiceProvider)
        .createFileName(deviceName: deviceName);
    try {
      await ref
          .read(backupTargetServiceProvider)
          .write(
            settings,
            envelope,
            fileName,
            await _webDavPassword(),
            deviceName: deviceName,
          );
      await _save(
        (settings) => settings.copyWith(
          lastBackupAt: () => DateTime.now(),
          lastError: () => null,
        ),
      );
    } catch (error) {
      await _save((settings) => settings.copyWith(lastError: () => '$error'));
      if (!silent) rethrow;
    }
  }

  Future<String> _backupDeviceName() =>
      ref.read(deviceNameServiceProvider).backupDeviceName();

  Future<String> _webDavPassword() async {
    final password = await ref.read(secureStorageProvider).read(key: backupSecureWebDavPasswordKey);
    return password ?? '';
  }

  Future<BackupAutoSecret> _storedAutoSecret() async {
    final secret = await _storedAutoSecretOrNull();
    if (secret == null) {
      throw const BackupException(BackupException.passwordRequired);
    }
    return secret;
  }

  Future<BackupAutoSecret?> _storedAutoSecretOrNull() async {
    final rawSecret = await ref
        .read(appSecurityServiceProvider)
        .readAutoBackupSecret();
    if (rawSecret == null || rawSecret.isEmpty) return null;
    return BackupAutoSecret.fromJson(
      Map<String, Object?>.from(jsonDecode(rawSecret) as Map),
    );
  }

  Future<void> _requireTarget() async {
    if (!_hasTarget(await future)) throw const BackupException(BackupException.noTarget);
  }

  bool _hasTarget(BackupSettings settings) =>
      (settings.localEnabled && settings.localFolder.isNotEmpty) ||
      (settings.webdavEnabled && settings.webdavUrl.isNotEmpty);

  Future<void> _save(BackupSettings Function(BackupSettings) update) async {
    final current = await future;
    final next = update(current);
    state = AsyncData(next);
    await BackupSettingsStore(ref.read(sharedPrefsProvider)).save(next);
  }

  void _listenForBackupDataChanges() {
    ref.listen(serverListProvider, (previous, next) {
      if (previous?.hasValue == true && next.hasValue) {
        _scheduleAutoBackupSoon();
      }
    });
    ref.listen(keyListProvider, (previous, next) {
      if (previous?.hasValue == true && next.hasValue) {
        _scheduleAutoBackupSoon();
      }
    });
    ref.listen(serverGroupProvider, (_, _) => _scheduleAutoBackupSoon());
    ref.listen(userScriptsProvider, (_, _) => _scheduleAutoBackupSoon());
    ref.listen(commandSnippetProvider, (_, _) => _scheduleAutoBackupSoon());
  }

  void _scheduleAutoBackupSoon() {
    _autoTimer?.cancel();
    _autoTimer = Timer(const Duration(seconds: 3), () => unawaited(_runAutoBackup()));
  }
}
