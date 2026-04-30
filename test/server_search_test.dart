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
  ];

  test('filterServersForQuery matches name, host, username, and tags', () {
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
  });

  test('filterServersForQuery requires every search term to match', () {
    expect(
      filterServersForQuery(servers, 'prod 10.0').map((server) => server.id),
      ['server-1'],
    );
    expect(filterServersForQuery(servers, 'prod postgres'), isEmpty);
  });
}
