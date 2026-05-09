import 'dart:async';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:orbita/models/backup_models.dart';
import 'package:orbita/providers/command_snippet_provider.dart';
import 'package:orbita/providers/key_provider.dart';
import 'package:orbita/providers/remote_script_provider.dart';
import 'package:orbita/providers/security_provider.dart';
import 'package:orbita/providers/server_group_provider.dart';
import 'package:orbita/providers/server_provider.dart';
import 'package:orbita/providers/settings_provider.dart';
import 'package:orbita/services/backup_encryption_service.dart';
import 'package:orbita/services/backup_file_service.dart';
import 'package:orbita/services/backup_settings_store.dart';
import 'package:orbita/services/backup_snapshot_service.dart';
import 'package:orbita/services/backup_target_service.dart';
import 'package:orbita/services/webdav_backup_service.dart';

const _secureWebDavPassword = 'backup_webdav_password';

final backupEncryptionServiceProvider = Provider<BackupEncryptionService>(
  (ref) => const BackupEncryptionService(),
);

final backupFileServiceProvider = Provider<BackupFileService>(
  (ref) => const BackupFileService(),
);

final webDavBackupServiceProvider = Provider<WebDavBackupService>(
  (ref) => WebDavBackupService(),
);

final backupTargetServiceProvider = Provider<BackupTargetService>((ref) {
  return BackupTargetService(
    fileService: ref.read(backupFileServiceProvider),
    webDavService: ref.read(webDavBackupServiceProvider),
  );
});

final secureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(),
);

final backupSyncProvider =
    AsyncNotifierProvider<BackupSyncNotifier, BackupSettings>(
      BackupSyncNotifier.new,
    );

class BackupSyncNotifier extends AsyncNotifier<BackupSettings> {
  Timer? _autoTimer;

  @override
  Future<BackupSettings> build() async {
    ref.onDispose(() => _autoTimer?.cancel());
    _listenForBackupDataChanges();
    final settings = BackupSettingsStore(ref.read(sharedPrefsProvider)).read();
    return settings;
  }

  Future<void> pickLocalFolder() async {
    final path = await FilePicker.platform.getDirectoryPath();
    if (path == null) return;
    await _save((settings) {
      return settings.copyWith(localEnabled: true, localFolder: path);
    });
  }

  Future<void> setLocalEnabled(bool enabled) async {
    await _save((settings) => settings.copyWith(localEnabled: enabled));
  }

  Future<void> setWebDavConfig({
    required String url,
    required String username,
    required String password,
    required String remoteFolder,
  }) async {
    if (password.isNotEmpty) {
      await ref
          .read(secureStorageProvider)
          .write(key: _secureWebDavPassword, value: password);
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

  Future<void> setWebDavEnabled(bool enabled) async {
    await _save((settings) => settings.copyWith(webdavEnabled: enabled));
  }

  Future<void> setRetentionCount(int count) async {
    await _save(
      (settings) => settings.copyWith(
        retentionCount: BackupSettingsStore.normalizeRetention(count),
      ),
    );
  }

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
    final envelope = ref
        .read(backupEncryptionServiceProvider)
        .encryptWithSecret(
          await buildBackupSnapshot(ref),
          await _storedAutoSecret(),
        );
    await _writeTargets(envelope);
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
    await _restoreEnvelope(envelope, password);
  }

  Future<void> _runAutoBackup() async {
    final settings = await future;
    if (!settings.autoBackupEnabled || !_hasTarget(settings)) return;
    final secret = await _storedAutoSecretOrNull();
    if (secret == null) return;
    final envelope = ref
        .read(backupEncryptionServiceProvider)
        .encryptWithSecret(await buildBackupSnapshot(ref), secret);
    await _writeTargets(envelope, silent: true);
  }

  Future<void> _restoreEnvelope(String envelope, String password) async {
    late final Map<String, Object?> snapshot;
    try {
      snapshot = await ref
          .read(backupEncryptionServiceProvider)
          .decryptWithPassword(envelope, password);
    } on FormatException {
      throw const BackupException(BackupException.invalidSnapshot);
    } catch (_) {
      throw const BackupException(BackupException.invalidPassword);
    }
    try {
      await restoreBackupSnapshot(ref, snapshot);
    } on BackupException {
      rethrow;
    } catch (_) {
      throw const BackupException(BackupException.invalidSnapshot);
    }
  }

  Future<void> _writeTargets(String envelope, {bool silent = false}) async {
    final settings = await future;
    if (!_hasTarget(settings)) {
      if (silent) return;
      throw const BackupException(BackupException.noTarget);
    }
    final fileName = ref.read(backupFileServiceProvider).createFileName();
    try {
      await ref
          .read(backupTargetServiceProvider)
          .write(settings, envelope, fileName, await _webDavPassword());
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

  Future<String> _webDavPassword() async {
    return await ref
            .read(secureStorageProvider)
            .read(key: _secureWebDavPassword) ??
        '';
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
    if (!_hasTarget(await future)) {
      throw const BackupException(BackupException.noTarget);
    }
  }

  bool _hasTarget(BackupSettings settings) {
    return (settings.localEnabled && settings.localFolder.isNotEmpty) ||
        (settings.webdavEnabled && settings.webdavUrl.isNotEmpty);
  }

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
    _autoTimer = Timer(const Duration(seconds: 3), () {
      unawaited(_runAutoBackup());
    });
  }
}
