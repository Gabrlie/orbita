import 'package:orbita/utils/format_utils.dart';

part 'server_status_parser.dart';

/// Raw cumulative snapshot for calculating rates between polls.
class RawNetIoSnapshot {
  final int netRxBytes;
  final int netTxBytes;
  final int ioReadBytes;
  final int ioWriteBytes;
  final DateTime timestamp;
  final Map<String, RawInterfaceSnapshot> interfaces;

  const RawNetIoSnapshot({
    required this.netRxBytes,
    required this.netTxBytes,
    required this.ioReadBytes,
    required this.ioWriteBytes,
    required this.timestamp,
    this.interfaces = const {},
  });
}

class RawInterfaceSnapshot {
  final int rxBytes;
  final int txBytes;

  const RawInterfaceSnapshot({required this.rxBytes, required this.txBytes});
}

class CpuCoreStatus {
  final String label;
  final double percent;

  const CpuCoreStatus({required this.label, required this.percent});
}

class CpuBreakdownStatus {
  final double user;
  final double nice;
  final double system;
  final double idle;
  final double ioWait;
  final double irq;
  final double softIrq;
  final double steal;

  const CpuBreakdownStatus({
    this.user = 0,
    this.nice = 0,
    this.system = 0,
    this.idle = 0,
    this.ioWait = 0,
    this.irq = 0,
    this.softIrq = 0,
    this.steal = 0,
  });
}

class NetworkInterfaceStatus {
  final String name;
  final double upRate;
  final double downRate;
  final int txTotal;
  final int rxTotal;

  const NetworkInterfaceStatus({
    required this.name,
    required this.upRate,
    required this.downRate,
    required this.txTotal,
    required this.rxTotal,
  });
}

/// Parsed server status metrics.
class ServerStatus {
  final double cpuPercent;
  final int cpuCores;
  final int memTotal;
  final int memUsed;
  final int memAvailable;
  final int memCached;
  final int diskTotal;
  final int diskUsed;
  final int diskAvailable;
  final String diskMount;
  final String diskFsType;
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
  final String osPrettyName;
  final String osArch;
  final RawNetIoSnapshot snapshot;
  final List<CpuCoreStatus> cpuCoresStatus;
  final CpuBreakdownStatus cpuBreakdown;
  final List<NetworkInterfaceStatus> networkInterfaces;

  const ServerStatus({
    required this.cpuPercent,
    required this.cpuCores,
    required this.memTotal,
    required this.memUsed,
    this.memAvailable = 0,
    this.memCached = 0,
    required this.diskTotal,
    required this.diskUsed,
    this.diskAvailable = 0,
    this.diskMount = '/',
    this.diskFsType = '',
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
    this.osPrettyName = '',
    this.osArch = '',
    required this.snapshot,
    this.cpuCoresStatus = const [],
    this.cpuBreakdown = const CpuBreakdownStatus(),
    this.networkInterfaces = const [],
  });

  double get memPercent => memTotal > 0 ? memUsed / memTotal : 0;
  double get diskPercent => diskTotal > 0 ? diskUsed / diskTotal : 0;
  int get memFree => memAvailable;
  int get memAppUsed => (memUsed - memCached).clamp(0, memTotal);
  String get uptimeStr => formatUptime(uptimeSeconds);
  String get memSub => formatBytes(memTotal);
  String get diskSub => formatBytes(diskTotal);
  String get cpuSub => '$cpuCores Core${cpuCores > 1 ? 's' : ''}';
  String get osDisplayName {
    final name = osPrettyName.isNotEmpty ? osPrettyName : osId;
    if (osArch.isEmpty || name.toLowerCase().contains(osArch.toLowerCase())) {
      return name;
    }
    return '$name $osArch';
  }
}
