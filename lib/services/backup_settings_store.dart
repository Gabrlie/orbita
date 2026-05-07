import 'package:orbita/models/backup_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _keyLocalEnabled = 'backup_local_enabled';
const _keyLocalFolder = 'backup_local_folder';
const _keyWebDavEnabled = 'backup_webdav_enabled';
const _keyWebDavUrl = 'backup_webdav_url';
const _keyWebDavUsername = 'backup_webdav_username';
const _keyWebDavRemoteFolder = 'backup_webdav_remote_folder';
const _keyWebDavRemotePath = 'backup_webdav_remote_path';
const _keyAutoBackup = 'backup_auto_enabled';
const _keyAutoBackupTimeMinutes = 'backup_auto_time_minutes';
const _keyRetentionCount = 'backup_retention_count';
const _keyLastBackupAt = 'backup_last_backup_at';
const _keyLastError = 'backup_last_error';

class BackupSettingsStore {
  final SharedPreferences _prefs;

  const BackupSettingsStore(this._prefs);

  BackupSettings read() {
    return BackupSettings(
      localEnabled: _prefs.getBool(_keyLocalEnabled) ?? false,
      localFolder: _prefs.getString(_keyLocalFolder) ?? '',
      webdavEnabled: _prefs.getBool(_keyWebDavEnabled) ?? false,
      webdavUrl: _prefs.getString(_keyWebDavUrl) ?? '',
      webdavUsername: _prefs.getString(_keyWebDavUsername) ?? '',
      webdavRemoteFolder:
          _prefs.getString(_keyWebDavRemoteFolder) ??
          _legacyFolder(_prefs.getString(_keyWebDavRemotePath)) ??
          '/orbita',
      autoBackupEnabled: _prefs.getBool(_keyAutoBackup) ?? false,
      autoBackupTimeMinutes: normalizeAutoBackupTimeMinutes(
        _prefs.getInt(_keyAutoBackupTimeMinutes) ?? 180,
      ),
      retentionCount: normalizeRetention(
        _prefs.getInt(_keyRetentionCount) ?? 3,
      ),
      lastBackupAt: DateTime.tryParse(_prefs.getString(_keyLastBackupAt) ?? ''),
      lastError: _prefs.getString(_keyLastError),
    );
  }

  Future<void> save(BackupSettings settings) async {
    await _prefs.setBool(_keyLocalEnabled, settings.localEnabled);
    await _prefs.setString(_keyLocalFolder, settings.localFolder);
    await _prefs.setBool(_keyWebDavEnabled, settings.webdavEnabled);
    await _prefs.setString(_keyWebDavUrl, settings.webdavUrl);
    await _prefs.setString(_keyWebDavUsername, settings.webdavUsername);
    await _prefs.setString(_keyWebDavRemoteFolder, settings.webdavRemoteFolder);
    await _prefs.setInt(_keyRetentionCount, settings.retentionCount);
    await _prefs.setBool(_keyAutoBackup, settings.autoBackupEnabled);
    await _prefs.setInt(
      _keyAutoBackupTimeMinutes,
      normalizeAutoBackupTimeMinutes(settings.autoBackupTimeMinutes),
    );
    await _writeNullableString(
      _keyLastBackupAt,
      settings.lastBackupAt?.toIso8601String(),
    );
    await _writeNullableString(_keyLastError, settings.lastError);
  }

  static int normalizeRetention(int count) => count.clamp(1, 100).toInt();

  static int normalizeAutoBackupTimeMinutes(int minutes) {
    return minutes.clamp(0, 1439).toInt();
  }

  static String normalizeRemoteFolder(String folder) {
    final trimmed = folder.trim();
    if (trimmed.isEmpty) return '/orbita';
    return trimmed.startsWith('/') ? trimmed : '/$trimmed';
  }

  Future<void> _writeNullableString(String key, Object? value) async {
    if (value == null) {
      await _prefs.remove(key);
      return;
    }
    await _prefs.setString(key, value.toString());
  }

  String? _legacyFolder(String? remotePath) {
    if (remotePath == null || remotePath.trim().isEmpty) return null;
    final path = remotePath.trim();
    final index = path.lastIndexOf('/');
    if (index <= 0) return '/orbita';
    return path.substring(0, index);
  }
}
