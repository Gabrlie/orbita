import 'package:flutter_test/flutter_test.dart';
import 'package:orbita/models/server.dart';
import 'package:orbita/pages/home/server_search.dart';

void main() {
  const servers = [
    Server(
      id: 'server-1',
      name: 'Production API',
      host: '10.0.0.10',
      username: 'root',
      tags: ['prod', 'api'],
    ),
    Server(
      id: 'server-2',
      name: 'Database',
      host: '192.168.1.20',
      username: 'postgres',
      tags: ['db'],
    ),
    Server(
      id: 'server-3',
      name: 'Tailnet Box',
      host: '',
      username: 'root',
      connectionMode: ServerConnectionMode.tailscale,
      tailscaleDnsName: 'box.tail.ts.net',
    ),
  ];

  test('filterServersForQuery matches name, endpoint, username, and tags', () {
    expect(
      filterServersForQuery(servers, 'production').map((server) => server.id),
      ['server-1'],
    );
    expect(
      filterServersForQuery(servers, '192.168').map((server) => server.id),
      ['server-2'],
    );
    expect(
      filterServersForQuery(servers, 'postgres').map((server) => server.id),
      ['server-2'],
    );
    expect(filterServersForQuery(servers, 'api').map((server) => server.id), [
      'server-1',
    ]);
    expect(
      filterServersForQuery(servers, 'box.tail').map((server) => server.id),
      ['server-3'],
    );
  });

  test('filterServersForQuery requires every search term to match', () {
    expect(
      filterServersForQuery(servers, 'prod 10.0').map((server) => server.id),
      ['server-1'],
    );
    expect(filterServersForQuery(servers, 'prod postgres'), isEmpty);
  });

  test('tailnet server display endpoint uses selected DNS name', () {
    expect(servers.last.displayHost, 'box.tail.ts.net');
    expect(servers.last.displayEndpoint, 'box.tail.ts.net:22');
  });
}
