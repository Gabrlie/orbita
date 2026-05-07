import 'package:flutter_test/flutter_test.dart';
import 'package:orbita/models/backup_models.dart';
import 'package:orbita/services/backup_encryption_service.dart';
import 'package:orbita/services/backup_file_service.dart';
import 'package:orbita/services/backup_settings_store.dart';
import 'package:orbita/services/backup_snapshot_service.dart';
import 'package:orbita/services/security_crypto_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  test(
    'backup filenames are timestamped and retention keeps newest entries',
    () {
      const service = BackupFileService();
      final first = BackupEntry(
        location: BackupLocation.local,
        name: 'orbita-backup-20260507-010000.json',
        path: 'a',
        modifiedAt: DateTime(2026, 5, 7, 1),
      );
      final second = BackupEntry(
        location: BackupLocation.local,
        name: 'orbita-backup-20260507-020000.json',
        path: 'b',
        modifiedAt: DateTime(2026, 5, 7, 2),
      );
      final third = BackupEntry(
        location: BackupLocation.local,
        name: 'orbita-backup-20260507-030000.json',
        path: 'c',
        modifiedAt: DateTime(2026, 5, 7, 3),
      );

      expect(
        service.createFileName(DateTime(2026, 5, 7, 9, 8, 6)),
        'orbita-backup-20260507-090806.json',
      );
      expect(service.isBackupName(BackupFileService.legacyName), isTrue);
      expect(service.entriesToDelete([first, third, second], 2), [first]);
    },
  );

  test('backup snapshot validation rejects unreadable restore payloads', () {
    expect(
      () => validateBackupSnapshot({
        'schema': 1,
        'createdAt': '2026-05-07T00:00:00Z',
        'servers': const [],
        'keys': const [],
        'groups': const <String, Object?>{},
        'scripts': const [],
        'snippets': const [],
      }),
      returnsNormally,
    );
    expect(
      () => validateBackupSnapshot({
        'schema': 1,
        'createdAt': '2026-05-07T00:00:00Z',
        'servers': const [],
      }),
      throwsA(
        isA<BackupException>().having(
          (error) => error.message,
          'message',
          BackupException.invalidSnapshot,
        ),
      ),
    );
  });

  test('backup settings persist daily auto backup time', () async {
    SharedPreferences.setMockInitialValues({
      'backup_auto_time_minutes': 25 * 60,
    });
    final prefs = await SharedPreferences.getInstance();
    final store = BackupSettingsStore(prefs);

    expect(store.read().autoBackupTimeMinutes, 1439);

    await store.save(
      const BackupSettings(
        autoBackupEnabled: true,
        autoBackupTimeMinutes: 9 * 60 + 30,
      ),
    );

    final restored = store.read();
    expect(restored.autoBackupEnabled, isTrue);
    expect(restored.autoBackupTimeMinutes, 570);
  });
}
