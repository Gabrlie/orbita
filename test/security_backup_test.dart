import 'package:flutter_test/flutter_test.dart';
import 'package:orbita/services/backup_encryption_service.dart';
import 'package:orbita/services/security_crypto_service.dart';

void main() {
  final crypto = SecurityCryptoService(memoryKb: 1024, iterations: 1);

  test(
    'app password verifier only matches the same password and salt',
    () async {
      final salt = crypto.randomBytes(16);
      final first = await crypto.derivePasswordKey('correct horse', salt);
      final second = await crypto.derivePasswordKey('correct horse', salt);
      final wrong = await crypto.derivePasswordKey('wrong horse', salt);

      expect(crypto.verifierForKey(first), crypto.verifierForKey(second));
      expect(crypto.verifierForKey(first), isNot(crypto.verifierForKey(wrong)));
    },
  );

  test('aes gcm decrypts original plaintext and rejects wrong key', () {
    final key = crypto.randomBytes(32);
    final nonce = crypto.randomBytes(12);
    final plainText = [1, 2, 3, 4, 5];
    final cipherText = crypto.encryptAesGcm(
      key: key,
      nonce: nonce,
      plainText: plainText,
    );

    expect(
      crypto.decryptAesGcm(key: key, nonce: nonce, cipherText: cipherText),
      plainText,
    );
    expect(
      () => crypto.decryptAesGcm(
        key: crypto.randomBytes(32),
        nonce: nonce,
        cipherText: cipherText,
      ),
      throwsA(isA<Object>()),
    );
  });

  test('backup envelope decrypts with app password', () async {
    final service = BackupEncryptionService(crypto: crypto);
    final snapshot = <String, Object?>{
      'schema': 1,
      'servers': [
        {'name': 'demo', 'host': '127.0.0.1'},
      ],
    };

    final result = await service.encryptWithPassword(snapshot, 'app-pass');
    final restored = await service.decryptWithPassword(
      result.envelope,
      'app-pass',
    );

    expect(restored['schema'], 1);
    expect(restored['servers'], isA<List>());
    await expectLater(
      service.decryptWithPassword(result.envelope, 'bad-pass'),
      throwsA(isA<Object>()),
    );
  });
}
