part of 'server_status.dart';

/// The compound shell command to fetch all metrics.
/// Takes ~0.5s due to CPU measurement interval.
const monitorCommand = r'''
echo "==S1=="; grep '^cpu' /proc/stat
sleep 0.5
echo "==S2=="; grep '^cpu' /proc/stat
echo "==UP=="; cat /proc/uptime
echo "==LA=="; cat /proc/loadavg
echo "==MEM=="; grep -E '^(MemTotal|MemAvailable|Cached):' /proc/meminfo
echo "==DF=="; df -B1 -T / 2>/dev/null | tail -1
echo "==ND=="; cat /proc/net/dev 2>/dev/null
echo "==DI=="; cat /proc/diskstats 2>/dev/null
echo "==NC=="; nproc 2>/dev/null || echo 1
echo "==OS=="; (. /etc/os-release 2>/dev/null && echo "$ID") || echo unknown
echo "==END=="
''';

/// Parse the output of [monitorCommand] into a [ServerStatus].
ServerStatus parseMonitorOutput(String output, RawNetIoSnapshot? prev) {
  final sections = <String, String>{};
  String currentKey = '';
  final buf = StringBuffer();

  for (final line in output.split('\n')) {
    if (line.startsWith('==') && line.endsWith('==') && line.length > 4) {
      if (currentKey.isNotEmpty) {
        sections[currentKey] = buf.toString().trim();
        buf.clear();
      }
      currentKey = line.replaceAll('==', '').trim();
    } else if (line.startsWith('==S1==') || line.startsWith('==S2==')) {
      final key = line.startsWith('==S1==') ? 'S1' : 'S2';
      sections[key] = line.substring(6).trim();
      currentKey = '';
    } else {
      buf.writeln(line);
    }
  }
  if (currentKey.isNotEmpty) {
    sections[currentKey] = buf.toString().trim();
  }

  final cpu = _parseCpu(sections['S1'] ?? '', sections['S2'] ?? '');

  final uptimeParts = (sections['UP'] ?? '0').split(' ');
  final uptimeSeconds = double.tryParse(uptimeParts.first)?.toInt() ?? 0;

  final loadParts = (sections['LA'] ?? '').split(' ');
  final loadAvg = loadParts.take(3).join(' ');

  int memTotal = 0, memAvailable = 0, memCached = 0;
  for (final line in (sections['MEM'] ?? '').split('\n')) {
    final match = RegExp(r'(\w+):\s+(\d+)').firstMatch(line);
    if (match != null) {
      final val = int.tryParse(match.group(2)!) ?? 0;
      if (line.startsWith('MemTotal')) memTotal = val * 1024;
      if (line.startsWith('MemAvailable')) memAvailable = val * 1024;
      if (line.startsWith('Cached')) memCached = val * 1024;
    }
  }

  int diskTotal = 0, diskUsed = 0, diskAvailable = 0;
  var diskMount = '/';
  var diskFsType = '';
  final dfParts = (sections['DF'] ?? '').trim().split(RegExp(r'\s+'));
  if (dfParts.length >= 7) {
    diskFsType = dfParts[1];
    diskTotal = int.tryParse(dfParts[2]) ?? 0;
    diskUsed = int.tryParse(dfParts[3]) ?? 0;
    diskAvailable = int.tryParse(dfParts[4]) ?? 0;
    diskMount = dfParts[6];
  } else if (dfParts.length >= 4) {
    diskTotal = int.tryParse(dfParts[1]) ?? 0;
    diskUsed = int.tryParse(dfParts[2]) ?? 0;
    diskAvailable = int.tryParse(dfParts[3]) ?? 0;
  }

  int netRx = 0, netTx = 0;
  final rawInterfaces = <String, RawInterfaceSnapshot>{};
  for (final line in (sections['ND'] ?? '').split('\n')) {
    if (line.contains('|') || line.trim().isEmpty) continue;
    final parts = line.trim().split(RegExp(r'[:\s]+'));
    if (parts.length < 10) continue;
    final iface = parts[0];
    if (iface == 'lo') continue;
    final rx = int.tryParse(parts[1]) ?? 0;
    final tx = int.tryParse(parts[9]) ?? 0;
    rawInterfaces[iface] = RawInterfaceSnapshot(rxBytes: rx, txBytes: tx);
    netRx += rx;
    netTx += tx;
  }

  int ioRead = 0, ioWrite = 0;
  for (final line in (sections['DI'] ?? '').split('\n')) {
    final parts = line.trim().split(RegExp(r'\s+'));
    if (parts.length < 10) continue;
    final name = parts[2];
    if (RegExp(r'\d$').hasMatch(name)) continue;
    if (name.startsWith('loop') ||
        name.startsWith('dm-') ||
        name.startsWith('ram')) {
      continue;
    }
    ioRead += (int.tryParse(parts[5]) ?? 0) * 512;
    ioWrite += (int.tryParse(parts[9]) ?? 0) * 512;
  }

  final osId = (sections['OS'] ?? 'unknown').trim();
  final cpuCores = int.tryParse((sections['NC'] ?? '1').trim()) ?? 1;

  final now = DateTime.now();
  final snapshot = RawNetIoSnapshot(
    netRxBytes: netRx,
    netTxBytes: netTx,
    ioReadBytes: ioRead,
    ioWriteBytes: ioWrite,
    timestamp: now,
    interfaces: rawInterfaces,
  );

  double netUpRate = 0, netDownRate = 0, ioWriteRate = 0, ioReadRate = 0;
  var networkInterfaces = <NetworkInterfaceStatus>[];
  if (prev != null) {
    final dt = now.difference(prev.timestamp).inMilliseconds / 1000.0;
    if (dt > 0) {
      netDownRate = (netRx - prev.netRxBytes) / dt;
      netUpRate = (netTx - prev.netTxBytes) / dt;
      ioReadRate = (ioRead - prev.ioReadBytes) / dt;
      ioWriteRate = (ioWrite - prev.ioWriteBytes) / dt;
      if (netDownRate < 0) netDownRate = 0;
      if (netUpRate < 0) netUpRate = 0;
      if (ioReadRate < 0) ioReadRate = 0;
      if (ioWriteRate < 0) ioWriteRate = 0;
      networkInterfaces = [
        for (final entry in rawInterfaces.entries)
          _interfaceStatus(
            entry.key,
            entry.value,
            prev.interfaces[entry.key],
            dt,
          ),
      ];
    }
  }
  if (networkInterfaces.isEmpty) {
    networkInterfaces = [
      for (final entry in rawInterfaces.entries)
        NetworkInterfaceStatus(
          name: entry.key,
          upRate: 0,
          downRate: 0,
          txTotal: entry.value.txBytes,
          rxTotal: entry.value.rxBytes,
        ),
    ];
  }

  return ServerStatus(
    cpuPercent: cpu.total,
    cpuCores: cpuCores,
    memTotal: memTotal,
    memUsed: memTotal - memAvailable,
    memAvailable: memAvailable,
    memCached: memCached,
    diskTotal: diskTotal,
    diskUsed: diskUsed,
    diskAvailable: diskAvailable,
    diskMount: diskMount,
    diskFsType: diskFsType,
    uptimeSeconds: uptimeSeconds,
    loadAvg: loadAvg,
    netUpRate: netUpRate,
    netDownRate: netDownRate,
    netTxTotal: netTx,
    netRxTotal: netRx,
    ioWriteRate: ioWriteRate,
    ioReadRate: ioReadRate,
    ioWriteTotal: ioWrite,
    ioReadTotal: ioRead,
    osId: osId,
    snapshot: snapshot,
    cpuCoresStatus: cpu.cores,
    networkInterfaces: networkInterfaces,
  );
}

NetworkInterfaceStatus _interfaceStatus(
  String name,
  RawInterfaceSnapshot current,
  RawInterfaceSnapshot? previous,
  double dt,
) {
  final up = previous == null ? 0.0 : (current.txBytes - previous.txBytes) / dt;
  final down = previous == null
      ? 0.0
      : (current.rxBytes - previous.rxBytes) / dt;
  return NetworkInterfaceStatus(
    name: name,
    upRate: up < 0 ? 0.0 : up,
    downRate: down < 0 ? 0.0 : down,
    txTotal: current.txBytes,
    rxTotal: current.rxBytes,
  );
}

_CpuParseResult _parseCpu(String s1, String s2) {
  final before = _cpuLines(s1);
  final after = _cpuLines(s2);
  final total = _cpuPercent(
    before['cpu'] ?? const [],
    after['cpu'] ?? const [],
  );
  final cores = [
    for (final entry in after.entries)
      if (entry.key != 'cpu' && before.containsKey(entry.key))
        CpuCoreStatus(
          label: entry.key.toUpperCase(),
          percent: _cpuPercent(before[entry.key]!, entry.value),
        ),
  ];
  return _CpuParseResult(total: total, cores: cores);
}

Map<String, List<int?>> _cpuLines(String raw) {
  final result = <String, List<int?>>{};
  for (final line in raw.split('\n')) {
    final parts = line.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || !parts.first.startsWith('cpu')) continue;
    result[parts.first] = parts.skip(1).map(int.tryParse).toList();
  }
  return result;
}

double _cpuPercent(List<int?> p1, List<int?> p2) {
  if (p1.length < 4 || p2.length < 4) return 0;
  final total1 = p1.fold<int>(0, (sum, v) => sum + (v ?? 0));
  final total2 = p2.fold<int>(0, (sum, v) => sum + (v ?? 0));
  final idle1 = p1[3] ?? 0;
  final idle2 = p2[3] ?? 0;
  final totalDelta = total2 - total1;
  if (totalDelta <= 0) return 0;
  return 1.0 - (idle2 - idle1) / totalDelta;
}

class _CpuParseResult {
  final double total;
  final List<CpuCoreStatus> cores;

  const _CpuParseResult({required this.total, required this.cores});
}
