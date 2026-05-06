import 'package:flutter_test/flutter_test.dart';
import 'package:orbita/models/server.dart';
import 'package:orbita/models/server_status.dart';
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

  test('parseMonitorOutput parses detail metrics and interface rates', () {
    final previous = RawNetIoSnapshot(
      netRxBytes: 1000,
      netTxBytes: 2000,
      ioReadBytes: 0,
      ioWriteBytes: 0,
      timestamp: DateTime.now().subtract(const Duration(seconds: 1)),
      interfaces: const {
        'eth0': RawInterfaceSnapshot(rxBytes: 1000, txBytes: 2000),
      },
    );

    final status = parseMonitorOutput(_monitorSample, previous);

    expect(status.cpuPercent, greaterThan(0));
    expect(status.cpuCoresStatus.single.label, 'CPU0');
    expect(status.memCached, 100 * 1024);
    expect(status.diskFsType, 'ext4');
    expect(status.diskAvailable, 3000);
    expect(status.loadAvg, '0.10 0.20 0.30');
    expect(status.osDisplayName, 'Ubuntu 24.04 LTS x86_64');
    expect(status.cpuBreakdown.user, greaterThan(0));
    expect(status.networkInterfaces.single.name, 'eth0');
    expect(status.networkInterfaces.single.downRate, greaterThan(0));
  });
}

const _monitorSample = '''
==S1==
cpu  100 0 100 800 0 0 0 0 0 0
cpu0 50 0 50 400 0 0 0 0 0 0
==S2==
cpu  150 0 150 900 0 0 0 0 0 0
cpu0 75 0 75 450 0 0 0 0 0 0
==UP==
3600.00 1000.00
==LA==
0.10 0.20 0.30 1/100 123
==MEM==
MemTotal: 1000 kB
MemAvailable: 400 kB
Cached: 100 kB
==DF==
/dev/sda1 ext4 10000 7000 3000 70% /
==ND==
Inter-|   Receive                                                |  Transmit
 face |bytes    packets errs drop fifo frame compressed multicast|bytes
  eth0: 3000 0 0 0 0 0 0 0 6000 0 0 0 0 0 0 0
==DI==
==NC==
1
==OS==
ubuntu
Ubuntu 24.04 LTS
x86_64
==END==
''';
