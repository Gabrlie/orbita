import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:dartssh2/dartssh2.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinenacl/ed25519.dart' as ed25519;
import 'package:pointycastle/export.dart';
import 'package:orbita/models/server.dart';
import 'package:orbita/models/ssh_key.dart';
import 'package:orbita/providers/server_provider.dart';

// -- SSH Key List --

final keyListProvider = AsyncNotifierProvider<KeyListNotifier, List<SshKey>>(
  KeyListNotifier.new,
);

class KeyListNotifier extends AsyncNotifier<List<SshKey>> {
  @override
  Future<List<SshKey>> build() async {
    return ref.read(storageServiceProvider).loadKeys();
  }

  Future<void> addKey(SshKey key) async {
    final current = <SshKey>[...(state.value ?? []), key];
    await ref.read(storageServiceProvider).saveKeys(current);
    state = AsyncData(current);
  }

  Future<void> updateKey(SshKey key) async {
    final current = (state.value ?? [])
        .map((k) => k.id == key.id ? key : k)
        .toList();
    await ref.read(storageServiceProvider).saveKeys(current);
    state = AsyncData(current);
  }

  Future<void> deleteKey(String id) async {
    final servers = await ref.read(serverListProvider.future);
    final usedBy = serversUsingKey(servers, id);
    if (usedBy.isNotEmpty) {
      throw KeyInUseException(usedBy);
    }

    final current = (state.value ?? []).where((k) => k.id != id).toList();
    await ref.read(storageServiceProvider).saveKeys(current);
    state = AsyncData(current);
  }

  /// Generate a new key pair and return it (not yet saved).
  Future<SshKey> generateKey({
    required String id,
    required String name,
    required SshKeyType keyType,
    String? passphrase,
  }) async {
    final SSHKeyPair pair;
    if (keyType == SshKeyType.rsa) {
      pair = _generateRsa(4096);
    } else {
      pair = _generateEd25519();
    }

    final publicKeyBytes = pair.toPublicKey().encode();
    final publicKeyB64 = base64.encode(publicKeyBytes);
    final publicKeyStr = '${pair.type} $publicKeyB64 orbita';

    return SshKey(
      id: id,
      name: name,
      keyType: keyType,
      privateKeyPem: pair.toPem(),
      publicKey: publicKeyStr,
      passphrase: passphrase,
      createdAt: DateTime.now(),
    );
  }

  static OpenSSHEd25519KeyPair _generateEd25519() {
    final signingKey = ed25519.SigningKey.generate();
    final publicKey = Uint8List.fromList(signingKey.verifyKey.asTypedList);
    final privateKey = Uint8List.fromList(signingKey.asTypedList);
    return OpenSSHEd25519KeyPair(publicKey, privateKey, 'orbita');
  }

  static OpenSSHRsaKeyPair _generateRsa(int bits) {
    final keyGen = RSAKeyGenerator()
      ..init(
        ParametersWithRandom(
          RSAKeyGeneratorParameters(BigInt.parse('65537'), bits, 64),
          FortunaRandom()..seed(KeyParameter(_randomBytes(32))),
        ),
      );
    final pair = keyGen.generateKeyPair();
    final pub = pair.publicKey;
    final priv = pair.privateKey;
    // ignore: deprecated_member_use
    final iqmp = priv.q!.modInverse(priv.p!);
    return OpenSSHRsaKeyPair(
      // ignore: deprecated_member_use
      pub.n!,
      pub.publicExponent!,
      priv.privateExponent!,
      iqmp,
      priv.p!,
      priv.q!,
      'orbita',
    );
  }

  static Uint8List _randomBytes(int length) {
    final rng = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(length, (_) => rng.nextInt(256)),
    );
  }

  /// Derive public key string from a PEM private key.
  /// Returns null if parsing fails.
  static String? derivePublicKey(String pem, [String? passphrase]) {
    try {
      final pairs = SSHKeyPair.fromPem(pem, passphrase);
      if (pairs.isEmpty) return null;
      final pair = pairs.first;
      final pubBytes = pair.toPublicKey().encode();
      final pubB64 = base64.encode(pubBytes);
      return '${pair.type} $pubB64 orbita';
    } catch (_) {
      return null;
    }
  }
}

List<Server> serversUsingKey(List<Server> servers, String keyId) {
  return servers
      .where(
        (server) => server.authType == AuthType.key && server.keyId == keyId,
      )
      .toList();
}

class KeyInUseException implements Exception {
  final List<Server> servers;

  const KeyInUseException(this.servers);
}

final keyByIdProvider = Provider.family<SshKey?, String>((ref, id) {
  final keys = ref.watch(keyListProvider).value ?? [];
  return keys.where((k) => k.id == id).firstOrNull;
});
