import 'package:flutter_test/flutter_test.dart';
import 'package:orbita/models/server.dart';
import 'package:orbita/models/ssh_key.dart';
import 'package:orbita/providers/server_monitor_provider.dart';

void main() {
  test(
    'resolveServerKey awaits async keys and returns the selected key',
    () async {
      const server = Server(
        id: 'server-1',
        name: 'Server',
        host: '127.0.0.1',
        username: 'root',
        authType: AuthType.key,
        keyId: 'key-1',
      );
      final key = SshKey(
        id: 'key-1',
        name: 'Key',
        keyType: SshKeyType.ed25519,
        privateKeyPem: 'pem',
        createdAt: DateTime(2026),
      );

      final result = await resolveServerKey(server, Future.value([key]));

      expect(result, same(key));
    },
  );

  test('resolveServerKey skips lookup for password auth', () async {
    const server = Server(
      id: 'server-1',
      name: 'Server',
      host: '127.0.0.1',
      username: 'root',
    );

    final result = await resolveServerKey(server, Future.value([]));

    expect(result, isNull);
  });
}
