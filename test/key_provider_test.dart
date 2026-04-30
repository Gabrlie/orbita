import 'package:flutter_test/flutter_test.dart';
import 'package:orbita/models/server.dart';
import 'package:orbita/providers/key_provider.dart';

void main() {
  test('serversUsingKey returns only key-auth servers using the key', () {
    const servers = [
      Server(
        id: 'server-1',
        name: 'App',
        host: '10.0.0.1',
        username: 'root',
        authType: AuthType.key,
        keyId: 'key-1',
      ),
      Server(
        id: 'server-2',
        name: 'DB',
        host: '10.0.0.2',
        username: 'root',
        authType: AuthType.key,
        keyId: 'key-2',
      ),
      Server(
        id: 'server-3',
        name: 'Password',
        host: '10.0.0.3',
        username: 'root',
        authType: AuthType.password,
        keyId: 'key-1',
      ),
    ];

    final result = serversUsingKey(servers, 'key-1');

    expect(result.map((server) => server.id), ['server-1']);
  });
}
