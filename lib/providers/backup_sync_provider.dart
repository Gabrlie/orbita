import 'dart:async';
import 'dart:convert';
import 'dart:io';

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
import 'package:orbita/services/backup_snapshot_service.dart';
import 'package:orbita/services/webdav_backup_service.dart';

const _keyLocalEnabled = 'backup_local_enabled';
const _keyLocalFolder = 'backup_local_folder';
const _keyWebDavEnabled = 'backup_webdav_enabled';
const _keyWebDavUrl = 'backup_webdav_url';
const _keyWebDavUsername = 'backup_webdav_username';
const _keyWebDavRemotePath = 'backup_webdav_remote_path';
const _keyAutoBackup = 'backup_auto_enabled';
const _keyLastBackupAt = 'backup_last_backup_at';
const _keyLastError = 'backup_last_error';
const _secureWebDavPassword = 'backup_webdav_password';

final backupEncryptionServiceProvider = Provider<BackupEncryptionService>(
  (ref) => const BackupEncryptionService(),
);

final webDavBackupServiceProvider = Provider<WebDavBackupService>(
  (ref) => WebDavBackupService(),
);

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
    _watchDataChanges();
    final prefs = ref.read(sharedPrefsProvider);
    return BackupSettings(
      localEnabled: prefs.getBool(_keyLocalEnabled) ?? false,
      localFolder: prefs.getString(_keyLocalFolder) ?? '',
      webdavEnabled: prefs.getBool(_keyWebDavEnabled) ?? false,
      webdavUrl: prefs.getString(_keyWebDavUrl) ?? '',
      webdavUsername: prefs.getString(_keyWebDavUsername) ?? '',
      webdavRemotePath:
          prefs.getString(_keyWebDavRemotePath) ?? '/orbita-backup.json',
      autoBackupEnabled: prefs.getBool(_keyAutoBackup) ?? false,
      lastBackupAt: DateTime.tryParse(prefs.getString(_keyLastBackupAt) ?? ''),
      lastError: prefs.getString(_keyLastError),
    );
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
    required String remotePath,
  }) async {
    await ref
        .read(secureStorageProvider)
        .write(key: _secureWebDavPassword, value: password);
    await _save((settings) {
      return settings.copyWith(
        webdavEnabled: true,
        webdavUrl: url.trim(),
        webdavUsername: username.trim(),
        webdavRemotePath: remotePath.trim().isEmpty
            ? '/orbita-backup.json'
            : remotePath.trim(),
      );
    });
  }

  Future<void> setWebDavEnabled(bool enabled) async {
    await _save((settings) => settings.copyWith(webdavEnabled: enabled));
  }

  Future<void> testWebDav() async {
    final settings = await future;
    final password = await _webDavPassword();
    await ref
        .read(webDavBackupServiceProvider)
        .test(
          baseUrl: settings.webdavUrl,
          username: settings.webdavUsername,
          password: password,
        );
  }

  Future<void> setAutoBackup(bool enabled, String? password) async {
    if (!enabled) {
      await ref.read(appSecurityServiceProvider).clearAutoBackupKey();
      await _save((settings) => settings.copyWith(autoBackupEnabled: false));
      return;
    }
    if (password == null) throw const BackupException('password required');
    final snapshot = await buildBackupSnapshot(ref);
    final result = await ref
        .read(backupEncryptionServiceProvider)
        .encryptWithPassword(snapshot, password);
    await ref
        .read(appSecurityServiceProvider)
        .storeAutoBackupSecret(jsonEncode(result.secret.toJson()));
    await _save((settings) => settings.copyWith(autoBackupEnabled: true));
    await _writeTargets(result.envelope);
  }

  Future<void> manualBackup(String password) async {
    final appKey = await ref
        .read(appSecurityServiceProvider)
        .verifyPassword(password);
    if (appKey == null) throw const BackupException('invalid password');
    final snapshot = await buildBackupSnapshot(ref);
    final result = await ref
        .read(backupEncryptionServiceProvider)
        .encryptWithPassword(snapshot, password);
    await _writeTargets(result.envelope);
  }

  Future<void> restoreFromLocalFile(String password) async {
    final path = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['json'],
    );
    final filePath = path?.files.single.path;
    if (filePath == null) return;
    final envelope = await File(filePath).readAsString();
    await _restoreEnvelope(envelope, password);
  }

  Future<void> restoreFromWebDav(String password) async {
    final settings = await future;
    final envelope = await ref
        .read(webDavBackupServiceProvider)
        .download(
          baseUrl: settings.webdavUrl,
          remotePath: settings.webdavRemotePath,
          username: settings.webdavUsername,
          password: await _webDavPassword(),
        );
    await _restoreEnvelope(envelope, password);
  }

  void _watchDataChanges() {
    ref.listen(serverListProvider, (_, _) => _scheduleAutoBackup());
    ref.listen(keyListProvider, (_, _) => _scheduleAutoBackup());
    ref.listen(serverGroupProvider, (_, _) => _scheduleAutoBackup());
    ref.listen(userScriptsProvider, (_, _) => _scheduleAutoBackup());
    ref.listen(commandSnippetProvider, (_, _) => _scheduleAutoBackup());
  }

  void _scheduleAutoBackup() {
    final settings = state.value;
    if (settings == null || !settings.autoBackupEnabled) return;
    _autoTimer?.cancel();
    _autoTimer = Timer(const Duration(seconds: 5), () {
      unawaited(_runAutoBackup());
    });
  }

  Future<void> _runAutoBackup() async {
    final rawSecret = await ref
        .read(appSecurityServiceProvider)
        .readAutoBackupSecret();
    if (rawSecret == null) return;
    final secret = BackupAutoSecret.fromJson(
      Map<String, Object?>.from(jsonDecode(rawSecret) as Map),
    );
    final envelope = ref
        .read(backupEncryptionServiceProvider)
        .encryptWithSecret(await buildBackupSnapshot(ref), secret);
    await _writeTargets(envelope, silent: true);
  }

  Future<void> _restoreEnvelope(String envelope, String password) async {
    final snapshot = await ref
        .read(backupEncryptionServiceProvider)
        .decryptWithPassword(envelope, password);
    await restoreBackupSnapshot(ref, snapshot);
  }

  Future<void> _writeTargets(String envelope, {bool silent = false}) async {
    final settings = await future;
    try {
      if (settings.localEnabled) await _writeLocal(settings, envelope);
      if (settings.webdavEnabled) await _writeWebDav(settings, envelope);
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

  Future<void> _writeLocal(BackupSettings settings, String envelope) async {
    if (settings.localFolder.isEmpty) return;
    final directory = Directory(settings.localFolder);
    await directory.create(recursive: true);
    final file = File(
      '${directory.path}${Platform.pathSeparator}orbita-backup.json',
    );
    await file.writeAsString(envelope);
  }

  Future<void> _writeWebDav(BackupSettings settings, String envelope) async {
    await ref
        .read(webDavBackupServiceProvider)
        .upload(
          baseUrl: settings.webdavUrl,
          remotePath: settings.webdavRemotePath,
          username: settings.webdavUsername,
          password: await _webDavPassword(),
          content: envelope,
        );
  }

  Future<String> _webDavPassword() async {
    return await ref
            .read(secureStorageProvider)
            .read(key: _secureWebDavPassword) ??
        '';
  }

  Future<void> _save(BackupSettings Function(BackupSettings) update) async {
    final current = await future;
    final next = update(current);
    state = AsyncData(next);
    final prefs = ref.read(sharedPrefsProvider);
    await prefs.setBool(_keyLocalEnabled, next.localEnabled);
    await prefs.setString(_keyLocalFolder, next.localFolder);
    await prefs.setBool(_keyWebDavEnabled, next.webdavEnabled);
    await prefs.setString(_keyWebDavUrl, next.webdavUrl);
    await prefs.setString(_keyWebDavUsername, next.webdavUsername);
    await prefs.setString(_keyWebDavRemotePath, next.webdavRemotePath);
    await prefs.setBool(_keyAutoBackup, next.autoBackupEnabled);
    if (next.lastBackupAt == null) {
      await prefs.remove(_keyLastBackupAt);
    } else {
      await prefs.setString(
        _keyLastBackupAt,
        next.lastBackupAt!.toIso8601String(),
      );
    }
    if (next.lastError == null) {
      await prefs.remove(_keyLastError);
    } else {
      await prefs.setString(_keyLastError, next.lastError!);
    }
  }
}

class BackupException implements Exception {
  final String message;

  const BackupException(this.message);

  @override
  String toString() => message;
}
