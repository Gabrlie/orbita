import 'dart:convert';

import 'package:orbita/models/backup_models.dart';
import 'package:orbita/services/security_crypto_service.dart';

class BackupEncryptionService {
  final SecurityCryptoService crypto;

  const BackupEncryptionService({this.crypto = const SecurityCryptoService()});

  Future<({String envelope, BackupAutoSecret secret})> encryptWithPassword(
    Map<String, Object?> snapshot,
    String password,
  ) async {
    final secret = await createSecretForPassword(password);
    return (envelope: encryptWithSecret(snapshot, secret), secret: secret);
  }

  Future<BackupAutoSecret> createSecretForPassword(String password) async {
    final dataKey = crypto.randomBytes(32);
    final salt = crypto.randomBytes(16);
    final wrapKey = await crypto.derivePasswordKey(password, salt);
    final wrapNonce = crypto.randomBytes(12);
    final wrappedKey = crypto.encryptAesGcm(
      key: wrapKey,
      nonce: wrapNonce,
      plainText: dataKey,
      associatedData: utf8.encode(SecurityCryptoService.backupContext),
    );
    final secret = BackupAutoSecret(
      salt: crypto.encodeBytes(salt),
      wrapNonce: crypto.encodeBytes(wrapNonce),
      wrappedKey: crypto.encodeBytes(wrappedKey),
      dataKey: crypto.encodeBytes(dataKey),
    );
    return secret;
  }

  String encryptWithSecret(
    Map<String, Object?> snapshot,
    BackupAutoSecret secret,
  ) {
    final dataNonce = crypto.randomBytes(12);
    final cipherText = crypto.encryptAesGcm(
      key: crypto.decodeBytes(secret.dataKey),
      nonce: dataNonce,
      plainText: utf8.encode(jsonEncode(snapshot)),
      associatedData: utf8.encode(SecurityCryptoService.backupContext),
    );
    return jsonEncode({
      'version': 1,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
      'kdf': {
        'algorithm': 'Argon2id',
        'salt': secret.salt,
        'memoryKb': crypto.memoryKb,
        'iterations': crypto.iterations,
        'parallelism': crypto.parallelism,
      },
      'wrappedKey': {
        'nonce': secret.wrapNonce,
        'cipherText': secret.wrappedKey,
      },
      'data': {
        'nonce': crypto.encodeBytes(dataNonce),
        'cipherText': crypto.encodeBytes(cipherText),
      },
    });
  }

  Future<Map<String, Object?>> decryptWithPassword(
    String envelope,
    String password,
  ) async {
    final decoded = jsonDecode(envelope) as Map<String, dynamic>;
    final kdf = decoded['kdf'] as Map<String, dynamic>;
    final wrappedKey = decoded['wrappedKey'] as Map<String, dynamic>;
    final data = decoded['data'] as Map<String, dynamic>;
    final wrapKey = await crypto.derivePasswordKey(
      password,
      crypto.decodeBytes(kdf['salt'] as String),
    );
    final dataKey = crypto.decryptAesGcm(
      key: wrapKey,
      nonce: crypto.decodeBytes(wrappedKey['nonce'] as String),
      cipherText: crypto.decodeBytes(wrappedKey['cipherText'] as String),
      associatedData: utf8.encode(SecurityCryptoService.backupContext),
    );
    final plainText = crypto.decryptAesGcm(
      key: dataKey,
      nonce: crypto.decodeBytes(data['nonce'] as String),
      cipherText: crypto.decodeBytes(data['cipherText'] as String),
      associatedData: utf8.encode(SecurityCryptoService.backupContext),
    );
    return Map<String, Object?>.from(jsonDecode(utf8.decode(plainText)) as Map);
  }
}
