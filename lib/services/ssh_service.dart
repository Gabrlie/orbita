import 'dart:convert';
import 'dart:typed_data';

import 'package:dartssh2/dartssh2.dart';
import 'package:orbita/models/ssh_key.dart';

abstract interface class SshClientSession {
  Future<SftpClient> openSftp();

  Future<SshShellSession> openShell({
    required int columns,
    required int rows,
    int pixelWidth,
    int pixelHeight,
  });

  Future<String> execute(String command);

  Future<String> executeStreaming(
    String command, {
    required void Function(String chunk) onOutput,
  });

  Future<void> get done;

  bool get isClosed;

  void disconnect();
}

/// Lightweight wrapper around dartssh2's SSHClient.
class SshService implements SshClientSession {
  final SSHClient _client;

  SshService._(this._client);

  static Future<SshService> connect({
    required String host,
    required int port,
    required String username,
    String? password,
    SshKey? key,
  }) async {
    final socket = await SSHSocket.connect(
      host,
      port,
      timeout: const Duration(seconds: 10),
    );

    final client = key != null
        ? SSHClient(
            socket,
            username: username,
            identities: SSHKeyPair.fromPem(key.privateKeyPem, key.passphrase),
            keepAliveInterval: const Duration(seconds: 30),
          )
        : SSHClient(
            socket,
            username: username,
            onPasswordRequest: () => password ?? '',
            keepAliveInterval: const Duration(seconds: 30),
          );

    final service = SshService._(client);

    // Wait for authentication by trying a simple command.
    await service.execute('echo ok');
    return service;
  }

  @override
  bool get isClosed => _client.isClosed;

  @override
  Future<void> get done => _client.done;

  @override
  Future<SshShellSession> openShell({
    required int columns,
    required int rows,
    int pixelWidth = 0,
    int pixelHeight = 0,
  }) async {
    if (isClosed) {
      throw StateError('SSH client not connected');
    }
    final session = await _client.shell(
      pty: SSHPtyConfig(
        width: columns,
        height: rows,
        pixelWidth: pixelWidth,
        pixelHeight: pixelHeight,
      ),
    );
    return SshShellSession._(session);
  }

  @override
  Future<SftpClient> openSftp() async {
    if (isClosed) {
      throw StateError('SSH client not connected');
    }
    return _client.sftp();
  }

  @override
  Future<String> execute(String command) async {
    if (isClosed) {
      throw StateError('SSH client not connected');
    }
    final session = await _client.execute(command);
    final stdout = await utf8.decodeStream(session.stdout);
    session.close();
    return stdout;
  }

  @override
  Future<String> executeStreaming(
    String command, {
    required void Function(String chunk) onOutput,
  }) async {
    if (isClosed) {
      throw StateError('SSH client not connected');
    }
    final session = await _client.execute(command);
    final output = StringBuffer();
    final stdout = session.stdout.listen((bytes) {
      final chunk = utf8.decode(bytes, allowMalformed: true);
      output.write(chunk);
      onOutput(chunk);
    });
    final stderr = session.stderr.listen((bytes) {
      final chunk = utf8.decode(bytes, allowMalformed: true);
      output.write(chunk);
      onOutput(chunk);
    });
    try {
      await session.done;
      return output.toString();
    } finally {
      await stdout.cancel();
      await stderr.cancel();
      session.close();
    }
  }

  @override
  void disconnect() {
    _client.close();
  }
}

class SshShellSession {
  final SSHSession _session;

  SshShellSession._(this._session);

  Stream<Uint8List> get stdout => _session.stdout;

  Stream<Uint8List> get stderr => _session.stderr;

  Future<void> get done => _session.done;

  void write(List<int> data) {
    _session.write(Uint8List.fromList(data));
  }

  void resizeTerminal(
    int columns,
    int rows, [
    int pixelWidth = 0,
    int pixelHeight = 0,
  ]) {
    _session.resizeTerminal(columns, rows, pixelWidth, pixelHeight);
  }

  void close() {
    _session.close();
  }
}
