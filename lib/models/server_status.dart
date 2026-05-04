import 'package:orbita/utils/format_utils.dart';

/// Raw cumulative snapshot for calculating rates between polls.
class RawNetIoSnapshot {
  final int netRxBytes;
  final int netTxBytes;
  final int ioReadBytes;
  final int ioWriteBytes;
  final DateTime timestamp;

  const RawNetIoSnapshot({
    required this.netRxBytes,
    required this.netTxBytes,
    required this.ioReadBytes,
    required this.ioWriteBytes,
    required this.timestamp,
  });
}

/// Parsed server status metrics.
class ServerStatus {
  final double cpuPercent;
  final int cpuCores;
  final int memTotal;
  final int memUsed;
  final int diskTotal;
  final int diskUsed;
  final int uptimeSeconds;
  final String loadAvg;
  final double netUpRate;
  final double netDownRate;
  final int netTxTotal;
  final int netRxTotal;
  final double ioWriteRate;
  final double ioReadRate;
  final int ioWriteTotal;
  final int ioReadTotal;
  final String osId;
  final RawNetIoSnapshot snapshot;

  const ServerStatus({
    required this.cpuPercent,
    required this.cpuCores,
    required this.memTotal,
    required this.memUsed,
    required this.diskTotal,
    required this.diskUsed,
    required this.uptimeSeconds,
    required this.loadAvg,
    required this.netUpRate,
    required this.netDownRate,
    required this.netTxTotal,
    required this.netRxTotal,
    required this.ioWriteRate,
    required this.ioReadRate,
    required this.ioWriteTotal,
    required this.ioReadTotal,
    required this.osId,
    required this.snapshot,
  });

  double get memPercent => memTotal > 0 ? memUsed / memTotal : 0;
  double get diskPercent => diskTotal > 0 ? diskUsed / diskTotal : 0;
  String get uptimeStr => formatUptime(uptimeSeconds);
  String get memSub => formatBytes(memTotal);
  String get diskSub => formatBytes(diskTotal);
  String get cpuSub => '$cpuCores Core${cpuCores > 1 ? 's' : ''}';
}

/// The compound shell command to fetch all metrics.
/// Takes ~0.5s due to CPU measurement interval.
const monitorCommand = r'''S1=$(head -1 /proc/stat);sleep 0.5;S2=$(head -1 /proc/stat);echo "==S1==$S1";echo "==S2==$S2";echo "==UP==";cat /proc/uptime;echo "==LA==";cat /proc/loadavg;echo "==MEM==";grep -E '^Mem(Total|Available):' /proc/meminfo;echo "==DF==";df -B1 / 2>/dev/null|tail -1;echo "==ND==";cat /proc/net/dev 2>/dev/null;echo "==DI==";cat /proc/diskstats 2>/dev/null;echo "==NC==";nproc 2>/dev/null||echo 1;echo "==OS==";(. /etc/os-release 2>/dev/null && echo "$ID")||echo unknown;echo "==END=="''';

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
      final key = line.substring(0, 4);
      sections[key] = line.substring(6).trim();
      currentKey = '';
    } else {
      buf.writeln(line);
    }
  }
  if (currentKey.isNotEmpty) {
    sections[currentKey] = buf.toString().trim();
  }

  // CPU
  final cpu = _parseCpu(sections['S1'] ?? '', sections['S2'] ?? '');

  // Uptime
  final uptimeParts = (sections['UP'] ?? '0').split(' ');
  final uptimeSeconds = double.tryParse(uptimeParts.first)?.toInt() ?? 0;

  // Load
  final loadParts = (sections['LA'] ?? '').split(' ');
  final loadAvg = loadParts.take(3).join(' ');

  // Memory (in kB from /proc/meminfo)
  int memTotal = 0, memAvailable = 0;
  for (final line in (sections['MEM'] ?? '').split('\n')) {
    final match = RegExp(r'(\w+):\s+(\d+)').firstMatch(line);
    if (match != null) {
      final val = int.tryParse(match.group(2)!) ?? 0;
      if (line.startsWith('MemTotal')) memTotal = val * 1024;
      if (line.startsWith('MemAvailable')) memAvailable = val * 1024;
    }
  }

  // Disk (df -B1 output: filesystem total used available use% mount)
  int diskTotal = 0, diskUsed = 0;
  final dfParts = (sections['DF'] ?? '').trim().split(RegExp(r'\s+'));
  if (dfParts.length >= 4) {
    diskTotal = int.tryParse(dfParts[1]) ?? 0;
    diskUsed = int.tryParse(dfParts[2]) ?? 0;
  }

  // Network (cumulative bytes from /proc/net/dev)
  int netRx = 0, netTx = 0;
  for (final line in (sections['ND'] ?? '').split('\n')) {
    if (line.contains('|') || line.trim().isEmpty) continue;
    final parts = line.trim().split(RegExp(r'[:\s]+'));
    if (parts.length < 10) continue;
    final iface = parts[0];
    if (iface == 'lo') continue;
    netRx += int.tryParse(parts[1]) ?? 0;
    netTx += int.tryParse(parts[9]) ?? 0;
  }

  // Disk IO (cumulative sectors from /proc/diskstats)
  int ioRead = 0, ioWrite = 0;
  for (final line in (sections['DI'] ?? '').split('\n')) {
    final parts = line.trim().split(RegExp(r'\s+'));
    if (parts.length < 10) continue;
    final name = parts[2];
    // Skip partitions (ending in digit), loop, dm-, ram
    if (RegExp(r'\d$').hasMatch(name)) continue;
    if (name.startsWith('loop') ||
        name.startsWith('dm-') ||
        name.startsWith('ram')) {
      continue;
    }
    ioRead += (int.tryParse(parts[5]) ?? 0) * 512; // sectors → bytes
    ioWrite += (int.tryParse(parts[9]) ?? 0) * 512;
  }

  // OS
  final osId = (sections['OS'] ?? 'unknown').trim();

  // CPU cores
  final cpuCores = int.tryParse((sections['NC'] ?? '1').trim()) ?? 1;

  // Calculate rates from previous snapshot
  final now = DateTime.now();
  final snapshot = RawNetIoSnapshot(
    netRxBytes: netRx,
    netTxBytes: netTx,
    ioReadBytes: ioRead,
    ioWriteBytes: ioWrite,
    timestamp: now,
  );

  double netUpRate = 0, netDownRate = 0, ioWriteRate = 0, ioReadRate = 0;
  if (prev != null) {
    final dt = now.difference(prev.timestamp).inMilliseconds / 1000.0;
    if (dt > 0) {
      netDownRate = (netRx - prev.netRxBytes) / dt;
      netUpRate = (netTx - prev.netTxBytes) / dt;
      ioReadRate = (ioRead - prev.ioReadBytes) / dt;
      ioWriteRate = (ioWrite - prev.ioWriteBytes) / dt;
      // Clamp negatives (counter reset)
      if (netDownRate < 0) netDownRate = 0;
      if (netUpRate < 0) netUpRate = 0;
      if (ioReadRate < 0) ioReadRate = 0;
      if (ioWriteRate < 0) ioWriteRate = 0;
    }
  }

  return ServerStatus(
    cpuPercent: cpu,
    cpuCores: cpuCores,
    memTotal: memTotal,
    memUsed: memTotal - memAvailable,
    diskTotal: diskTotal,
    diskUsed: diskUsed,
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
  );
}

double _parseCpu(String s1, String s2) {
  final p1 = s1.split(RegExp(r'\s+')).skip(1).map(int.tryParse).toList();
  final p2 = s2.split(RegExp(r'\s+')).skip(1).map(int.tryParse).toList();
  if (p1.length < 4 || p2.length < 4) return 0;
  final total1 = p1.fold<int>(0, (sum, v) => sum + (v ?? 0));
  final total2 = p2.fold<int>(0, (sum, v) => sum + (v ?? 0));
  final idle1 = p1[3] ?? 0;
  final idle2 = p2[3] ?? 0;
  final totalDelta = total2 - total1;
  if (totalDelta <= 0) return 0;
  return 1.0 - (idle2 - idle1) / totalDelta;
}
