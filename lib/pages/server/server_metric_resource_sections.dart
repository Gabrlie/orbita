part of 'server_metric_sections.dart';

class _CpuSection extends StatelessWidget {
  final ServerStatus? status;
  final List<ServerStatus> history;

  const _CpuSection({this.status, required this.history});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cores = status?.cpuCoresStatus ?? const <CpuCoreStatus>[];
    return _Panel(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _ValueChip(
                  l10n.metricUsed,
                  '${((status?.cpuPercent ?? 0) * 100).round()}%',
                ),
              ),
              CircularMetric(
                label: l10n.metricCpu,
                percent: status?.cpuPercent ?? 0,
                subtitle: status?.cpuSub ?? '-',
                size: 70,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _TrendLine(
            values: _metricTrend(
              history,
              (status) => status.cpuPercent,
              status?.cpuPercent ?? 0,
            ),
          ),
          const SizedBox(height: 12),
          for (final core in cores.take(8))
            _ProgressRow(label: core.label, percent: core.percent),
        ],
      ),
    );
  }
}

class _MemorySection extends StatelessWidget {
  final ServerStatus? status;
  final List<ServerStatus> history;

  const _MemorySection({this.status, required this.history});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final s = status;
    return _Panel(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _ValueChip(l10n.metricUsed, formatBytes(s?.memUsed ?? 0)),
                    _ValueChip(
                      l10n.metricCached,
                      formatBytes(s?.memCached ?? 0),
                    ),
                    _ValueChip(l10n.metricFree, formatBytes(s?.memFree ?? 0)),
                    _ValueChip(l10n.metricTotal, formatBytes(s?.memTotal ?? 0)),
                  ],
                ),
              ),
              CircularMetric(
                label: l10n.metricMemory,
                percent: s?.memPercent ?? 0,
                subtitle: s?.memSub ?? '-',
                size: 70,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _StackBar(
            values: [
              _StackValue(s?.memAppUsed ?? 0),
              _StackValue(s?.memCached ?? 0),
              _StackValue(s?.memFree ?? 0),
            ],
            total: s?.memTotal ?? 0,
          ),
          const SizedBox(height: 12),
          _TrendLine(
            values: _metricTrend(
              history,
              (status) => status.memPercent,
              s?.memPercent ?? 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _DiskSection extends StatelessWidget {
  final ServerStatus? status;

  const _DiskSection({this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final s = status;
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(s?.diskMount ?? '/')),
              if ((s?.diskFsType ?? '').isNotEmpty) _Badge(s!.diskFsType),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${formatBytes(s?.diskUsed ?? 0)} / ${formatBytes(s?.diskTotal ?? 0)}',
                ),
              ),
              Text('${((s?.diskPercent ?? 0) * 100).round()}%'),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: s?.diskPercent ?? 0),
          const SizedBox(height: 8),
          Text('${l10n.metricFree}: ${formatBytes(s?.diskAvailable ?? 0)}'),
        ],
      ),
    );
  }
}

class _NetworkSection extends StatelessWidget {
  final ServerStatus? status;
  final List<ServerStatus> history;

  const _NetworkSection({this.status, required this.history});

  @override
  Widget build(BuildContext context) {
    final s = status;
    return _Panel(
      child: Column(
        children: [
          _TrendLine(values: _networkTrend(history, s)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final iface
                  in s?.networkInterfaces ?? const <NetworkInterfaceStatus>[])
                _InterfaceCard(iface: iface),
            ],
          ),
        ],
      ),
    );
  }
}
