import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:orbita/services/backup_encryption_service.dart';
import 'package:orbita/services/security_crypto_service.dart';

class AppSecurityService {
  static const _saltKey = 'app_password_salt';
  static const _verifierKey = 'app_password_verifier';
  static const _autoBackupSecretKey = 'backup_auto_secret';

  final FlutterSecureStorage _storage;
  final LocalAuthentication _localAuth;
  final SecurityCryptoService crypto;
  String? _sessionPassword;
  late final BackupEncryptionService _backupEncryption;

  AppSecurityService({
    FlutterSecureStorage? storage,
    LocalAuthentication? localAuth,
    SecurityCryptoService? cryptoService,
  }) : _storage = storage ?? const FlutterSecureStorage(),
       _localAuth = localAuth ?? LocalAuthentication(),
       crypto = cryptoService ?? const SecurityCryptoService() {
    _backupEncryption = BackupEncryptionService(crypto: crypto);
  }

  String? get sessionPassword => _sessionPassword;

  Future<bool> hasPassword() async {
    final salt = await _storage.read(key: _saltKey);
    final verifier = await _storage.read(key: _verifierKey);
    return salt != null && verifier != null;
  }

  Future<void> setPassword(String password) async {
    final salt = crypto.randomBytes(16);
    final key = await crypto.derivePasswordKey(password, salt);
    await _storage.write(key: _saltKey, value: crypto.encodeBytes(salt));
    await _storage.write(key: _verifierKey, value: crypto.verifierForKey(key));
    await refreshAutoBackupSecret(password);
    _sessionPassword = password;
  }

  Future<void> clearPassword() async {
    await _storage.delete(key: _saltKey);
    await _storage.delete(key: _verifierKey);
    await clearAutoBackupKey();
    _sessionPassword = null;
  }

  Future<Uint8List?> verifyPassword(String password) async {
    final saltText = await _storage.read(key: _saltKey);
    final storedVerifier = await _storage.read(key: _verifierKey);
    if (saltText == null || storedVerifier == null) return null;
    final salt = crypto.decodeBytes(saltText);
    final key = await crypto.derivePasswordKey(password, salt);
    if (crypto.verifierForKey(key) != storedVerifier) return null;
    _sessionPassword = password;
    return key;
  }

  Future<bool> canUseBiometrics() async {
    try {
      return await _localAuth.isDeviceSupported() &&
          await _localAuth.canCheckBiometrics;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticateBiometric(String reason) async {
    try {
      return _localAuth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
        sensitiveTransaction: false,
      );
    } catch (_) {
      return false;
    }
  }

  Future<void> ensureAutoBackupSecret(String password) async {
    final current = await readAutoBackupSecret();
    if (current != null && current.isNotEmpty) return;
    await refreshAutoBackupSecret(password);
  }

  Future<void> refreshAutoBackupSecret(String password) async {
    final secret = await _backupEncryption.createSecretForPassword(password);
    await storeAutoBackupSecret(jsonEncode(secret.toJson()));
  }

  Future<void> storeAutoBackupSecret(String json) async {
    await _storage.write(key: _autoBackupSecretKey, value: json);
  }

  Future<String?> readAutoBackupSecret() {
    return _storage.read(key: _autoBackupSecretKey);
  }

  Future<void> clearAutoBackupKey() async {
    await _storage.delete(key: _autoBackupSecretKey);
  }
}
