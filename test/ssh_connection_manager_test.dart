import 'dart:async';

import 'package:dartssh2/dartssh2.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbita/models/server.dart';
import 'package:orbita/pages/server/terminal/terminal_launch_mode.dart';
import 'package:orbita/services/ssh_connection_manager.dart';
import 'package:orbita/services/ssh_service.dart';

void main() {
  test(
    'acquire keeps idle connection reusable after the last lease releases',
    () async {
      final services = <_FakeSshService>[];
      final manager = SshConnectionManager(
        idleTimeout: const Duration(milliseconds: 50),
        connector:
            ({
              required host,
              required port,
              required username,
              password,
              key,
            }) async {
              final service = _FakeSshService();
              services.add(service);
              return service;
            },
      );
      const server = Server(
        id: 'server-1',
        name: 'Server',
        host: '127.0.0.1',
        username: 'root',
        password: 'secret',
      );

      final firstLease = await manager.acquire(server);
      final secondLease = await manager.acquire(server);

      expect(services, hasLength(1));
      expect(identical(firstLease.service, secondLease.service), isTrue);

      firstLease.release();
      expect(services.single.disconnectCount, 0);

      secondLease.release();
      expect(services.single.disconnectCount, 0);

      final thirdLease = await manager.acquire(server);
      expect(services, hasLength(1));
      expect(identical(firstLease.service, thirdLease.service), isTrue);
      thirdLease.release();

      await Future<void>.delayed(const Duration(milliseconds: 80));
      expect(services.single.disconnectCount, 1);
    },
  );

  test('acquire reconnects when the server fingerprint changes', () async {
    final services = <_FakeSshService>[];
    final manager = SshConnectionManager(
      idleTimeout: Duration.zero,
      connector:
          ({
            required host,
            required port,
            required username,
            password,
            key,
          }) async {
            final service = _FakeSshService();
            services.add(service);
            return service;
          },
    );
    const server = Server(
      id: 'server-1',
      name: 'Server',
      host: '127.0.0.1',
      username: 'root',
      password: 'secret',
    );

    final firstLease = await manager.acquire(server);
    final updatedServer = server.copyWith(password: () => 'changed');
    final secondLease = await manager.acquire(updatedServer);

    expect(services, hasLength(2));
    expect(services.first.disconnectCount, 1);
    expect(identical(firstLease.service, secondLease.service), isFalse);

    firstLease.release();
    secondLease.release();
    expect(services.last.disconnectCount, 1);
  });

  test('markUnhealthy drops stale connection and reconnects', () async {
    final services = <_FakeSshService>[];
    final manager = SshConnectionManager(
      idleTimeout: Duration.zero,
      connector:
          ({
            required host,
            required port,
            required username,
            password,
            key,
          }) async {
            final service = _FakeSshService();
            services.add(service);
            return service;
          },
    );
    const server = Server(
      id: 'server-1',
      name: 'Server',
      host: '127.0.0.1',
      username: 'root',
      password: 'secret',
    );

    final staleLease = await manager.acquire(server);
    manager.markUnhealthy(server.id, staleLease.service);
    final freshLease = await manager.acquire(server);

    expect(services, hasLength(2));
    expect(services.first.disconnectCount, 1);
    expect(identical(staleLease.service, freshLease.service), isFalse);

    staleLease.release();
    freshLease.release();
    expect(services.last.disconnectCount, 1);
  });

  test('tmuxSessionNameForServer sanitizes unsupported characters', () {
    const server = Server(
      id: 'srv:01',
      name: 'Server',
      host: '127.0.0.1',
      username: 'root',
    );

    expect(tmuxSessionNameForServer(server), 'orbita_srv_01');
  });
}

class _FakeSshService implements SshClientSession {
  final Completer<void> _done = Completer<void>();

  var disconnectCount = 0;
  var _closed = false;

  @override
  Future<void> get done => _done.future;

  @override
  bool get isClosed => _closed;

  @override
  void disconnect() {
    disconnectCount += 1;
    if (_closed) return;
    _closed = true;
    if (!_done.isCompleted) {
      _done.complete();
    }
  }

  @override
  Future<String> execute(String command) async {
    throw UnimplementedError();
  }

  @override
  Future<String> executeStreaming(
    String command, {
    required void Function(String chunk) onOutput,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<SftpClient> openSftp() async {
    throw UnimplementedError();
  }

  @override
  Future<SshShellSession> openShell({
    required int columns,
    required int rows,
    int pixelWidth = 0,
    int pixelHeight = 0,
  }) async {
    throw UnimplementedError();
  }
}
