import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart' as crypto_kdf;
import 'package:crypto/crypto.dart';
import 'package:pointycastle/export.dart';

class SecurityCryptoService {
  static const appPasswordContext = 'orbita-app-password-v1';
  static const backupContext = 'orbita-backup-v1';

  final int memoryKb;
  final int iterations;
  final int parallelism;

  const SecurityCryptoService({
    this.memoryKb = 19456,
    this.iterations = 2,
    this.parallelism = 1,
  });

  Uint8List randomBytes(int length) {
    final rng = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(length, (_) => rng.nextInt(256)),
    );
  }

  Future<Uint8List> derivePasswordKey(String password, List<int> salt) async {
    final algorithm = crypto_kdf.Argon2id(
      parallelism: parallelism,
      memory: memoryKb,
      iterations: iterations,
      hashLength: 32,
    );
    final key = await algorithm.deriveKeyFromPassword(
      password: password,
      nonce: salt,
    );
    return Uint8List.fromList(await key.extractBytes());
  }

  String verifierForKey(List<int> key) {
    final hmac = Hmac(sha256, key);
    return hmac.convert(utf8.encode(appPasswordContext)).toString();
  }

  Uint8List encryptAesGcm({
    required List<int> key,
    required List<int> nonce,
    required List<int> plainText,
    List<int> associatedData = const [],
  }) {
    final cipher = GCMBlockCipher(AESEngine())
      ..init(
        true,
        AEADParameters(
          KeyParameter(Uint8List.fromList(key)),
          128,
          Uint8List.fromList(nonce),
          Uint8List.fromList(associatedData),
        ),
      );
    return cipher.process(Uint8List.fromList(plainText));
  }

  Uint8List decryptAesGcm({
    required List<int> key,
    required List<int> nonce,
    required List<int> cipherText,
    List<int> associatedData = const [],
  }) {
    final cipher = GCMBlockCipher(AESEngine())
      ..init(
        false,
        AEADParameters(
          KeyParameter(Uint8List.fromList(key)),
          128,
          Uint8List.fromList(nonce),
          Uint8List.fromList(associatedData),
        ),
      );
    return cipher.process(Uint8List.fromList(cipherText));
  }

  String encodeBytes(List<int> bytes) => base64Encode(bytes);

  Uint8List decodeBytes(String encoded) => base64Decode(encoded);
}
