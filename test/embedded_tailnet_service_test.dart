import 'package:flutter_test/flutter_test.dart';
import 'package:orbita/models/server.dart';
import 'package:orbita/services/embedded_tailnet_service.dart';

void main() {
  test('status parses embedded tailnet json', () async {
    final service = EmbeddedTailnetService(gateway: _FakeTailnetGateway());

    final status = await service.start();

    expect(status.isRunning, isTrue);
    expect(status.error, isEmpty);
    expect(status.peers.single.displayName, 'box.tail.ts.net');
  });

  test('resolveEndpoint opens a local proxy for tailnet servers', () async {
    final gateway = _FakeTailnetGateway();
    final service = EmbeddedTailnetService(gateway: gateway);
    const server = Server(
      id: 'server-1',
      name: 'Server',
      host: '',
      username: 'root',
      port: 22,
      connectionMode: ServerConnectionMode.tailscale,
      tailscaleDnsName: 'box.tail.ts.net',
    );

    final lease = await service.resolveEndpoint(server);

    expect(lease.server.host, '127.0.0.1');
    expect(lease.server.port, 43001);
    expect(gateway.openTargets, ['box.tail.ts.net:22']);

    await lease.release();
    expect(gateway.closedProxyIds, ['proxy-1']);
  });

  test('startWithPeers fills peer list from gateway peer query', () async {
    final gateway = _StatusWithoutPeersGateway();
    final service = EmbeddedTailnetService(gateway: gateway);

    final status = await service.startWithPeers();

    expect(status.isRunning, isTrue);
    expect(status.authUrl, isEmpty);
    expect(status.peers.single.displayName, 'box.tail.ts.net');
  });

  test('openAuthUrl opens login URL through gateway', () async {
    final gateway = _FakeTailnetGateway();
    final service = EmbeddedTailnetService(gateway: gateway);

    await service.openAuthUrl();

    expect(gateway.openedUrls, ['https://login.tailscale.test/a']);
  });

  test('resolveEndpoint waits for tailnet startup before proxying', () async {
    final gateway = _StartingTailnetGateway();
    final service = EmbeddedTailnetService(
      gateway: gateway,
      startupTimeout: const Duration(milliseconds: 50),
      pollInterval: const Duration(milliseconds: 1),
    );
    const server = Server(
      id: 'server-1',
      name: 'Server',
      host: '',
      username: 'root',
      port: 22,
      connectionMode: ServerConnectionMode.tailscale,
      tailscaleDnsName: 'box.tail.ts.net',
    );

    final lease = await service.resolveEndpoint(server);

    expect(gateway.statusCalls, 1);
    expect(gateway.openTargets, ['box.tail.ts.net:22']);
    await lease.release();
  });

  test('resolveEndpoint leaves direct servers untouched', () async {
    final gateway = _FakeTailnetGateway();
    final service = EmbeddedTailnetService(gateway: gateway);
    const server = Server(
      id: 'server-1',
      name: 'Server',
      host: '192.168.1.10',
      username: 'root',
    );

    final lease = await service.resolveEndpoint(server);

    expect(identical(lease.server, server), isTrue);
    expect(gateway.openTargets, isEmpty);
  });

  test('old server json without connection mode stays direct', () {
    final server = Server.fromJson(const {
      'id': 'server-1',
      'name': 'Server',
      'host': '192.168.1.10',
    });

    expect(server.connectionMode, ServerConnectionMode.direct);
    expect(server.host, '192.168.1.10');
  });
}

class _StatusWithoutPeersGateway extends _FakeTailnetGateway {
  @override
  Future<String> start() async => _statusWithoutPeersJson;

  @override
  Future<String> status() async => _statusWithoutPeersJson;
}

class _StartingTailnetGateway extends _FakeTailnetGateway {
  var statusCalls = 0;

  @override
  Future<String> start() async => _startingStatusJson;

  @override
  Future<String> status() async {
    statusCalls += 1;
    return _statusWithoutPeersJson;
  }
}

class _FakeTailnetGateway implements EmbeddedTailnetGateway {
  final openTargets = <String>[];
  final closedProxyIds = <String>[];
  final openedUrls = <String>[];

  @override
  Future<String> start() async => _statusJson;

  @override
  Future<String> status() async => _statusJson;

  @override
  Future<String> authUrl() async => 'https://login.tailscale.test/a';

  @override
  Future<void> openUrl(String url) async {
    openedUrls.add(url);
  }

  @override
  Future<String> listPeers() async =>
      '[{"id":"nodekey:abc","hostName":"box","dnsName":"box.tail.ts.net.","tailscaleIps":["100.64.0.2"],"online":true}]';

  @override
  Future<String> openTcpProxy(String target, int port) async {
    openTargets.add('$target:$port');
    return '{"id":"proxy-1","host":"127.0.0.1","port":43001,"target":"$target","remotePort":$port}';
  }

  @override
  Future<void> closeProxy(String id) async {
    closedProxyIds.add(id);
  }

  @override
  Future<void> stop() async {}

  @override
  Future<void> clearState() async {}
}

const _statusJson = '''
{
  "backendState": "Running",
  "authUrl": "",
  "self": {
    "id": "self",
    "hostName": "orbita",
    "dnsName": "orbita.tail.ts.net.",
    "tailscaleIps": ["100.64.0.1"],
    "online": true,
    "isSelf": true
  },
  "peers": [
    {
      "id": "nodekey:abc",
      "hostName": "box",
      "dnsName": "box.tail.ts.net.",
      "tailscaleIps": ["100.64.0.2"],
      "online": true
    }
  ]
}
''';

const _statusWithoutPeersJson = '''
{
  "backendState": "Running",
  "authUrl": "",
  "self": {
    "id": "self",
    "hostName": "orbita",
    "dnsName": "orbita.tail.ts.net.",
    "tailscaleIps": ["100.64.0.1"],
    "online": true,
    "isSelf": true
  },
  "peers": []
}
''';

const _startingStatusJson = '''
{
  "backendState": "Starting",
  "authUrl": "",
  "peers": []
}
''';
