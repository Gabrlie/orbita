import 'dart:convert';

import 'package:dartssh2/dartssh2.dart';
import 'package:orbita/models/ssh_key.dart';

/// Lightweight wrapper around dartssh2's SSHClient.
class SshService {
  SSHClient? _client;

  bool get isClosed => _client == null || _client!.isClosed;

  /// Connect to a server. Throws on failure.
  Future<void> connect({
    required String host,
    required int port,
    required String username,
    String? password,
    SshKey? key,
  }) async {
    final socket = await SSHSocket.connect(host, port,
        timeout: const Duration(seconds: 10));

    if (key != null) {
      final passphrase = key.passphrase;
      final identities = SSHKeyPair.fromPem(key.privateKeyPem, passphrase);
      _client = SSHClient(
        socket,
        username: username,
        identities: identities,
      );
    } else {
      _client = SSHClient(
        socket,
        username: username,
        onPasswordRequest: () => password ?? '',
      );
    }

    // Wait for authentication by trying a simple command
    await execute('echo ok');
  }

  /// Execute a command and return stdout as a string.
  Future<String> execute(String command) async {
    if (_client == null || _client!.isClosed) {
      throw StateError('SSH client not connected');
    }
    final session = await _client!.execute(command);
    final stdout = await utf8.decodeStream(session.stdout);
    session.close();
    return stdout;
  }

  /// Disconnect and clean up.
  void disconnect() {
    _client?.close();
    _client = null;
  }
}
