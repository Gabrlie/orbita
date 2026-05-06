part of 'server_metric_sections.dart';

class _CpuSection extends StatelessWidget {
  final ServerStatus? status;
  final List<ServerStatus> history;

  const _CpuSection({this.status, required this.history});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cores = status?.cpuCoresStatus ?? const <CpuCoreStatus>[];
    final breakdown = status?.cpuBreakdown ?? const CpuBreakdownStatus();
    final breakdownItems = [
      (l10n.metricCpuUser, breakdown.user, theme.colorScheme.primary),
      (l10n.metricCpuNice, breakdown.nice, Colors.orange),
      (l10n.metricCpuSystem, breakdown.system, Colors.indigo),
      (l10n.metricCpuIoWait, breakdown.ioWait, theme.colorScheme.error),
      (l10n.metricCpuIrq, breakdown.irq, Colors.amber),
      (l10n.metricCpuSoftIrq, breakdown.softIrq, Colors.blueGrey),
      (l10n.metricCpuSteal, breakdown.steal, Colors.grey),
      (l10n.metricCpuIdle, breakdown.idle, theme.colorScheme.outlineVariant),
    ];
    return _Panel(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 10,
                  children: [
                    for (final item in breakdownItems)
                      _ValueChip(
                        item.$1,
                        '${(item.$2 * 100).toStringAsFixed(1)}%',
                        color: item.$3,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              CircularMetric(
                label: l10n.metricCpu,
                percent: status?.cpuPercent ?? 0,
                subtitle: status?.cpuSub ?? '-',
                size: 60,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${l10n.metricCpu} ${l10n.metricUsageTrend}',
              style: theme.textTheme.labelLarge,
            ),
          ),
          const SizedBox(height: 8),
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
    final theme = Theme.of(context);
    final s = status;
    return _Panel(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _ValueGrid(
                  children: [
                    _ValueChip(
                      l10n.metricUsed,
                      formatBytes(s?.memUsed ?? 0),
                      color: Colors.orange,
                      width: null,
                    ),
                    _ValueChip(
                      l10n.metricCached,
                      formatBytes(s?.memCached ?? 0),
                      color: theme.colorScheme.primary,
                      width: null,
                    ),
                    _ValueChip(
                      l10n.metricFree,
                      formatBytes(s?.memFree ?? 0),
                      color: theme.colorScheme.outline,
                      width: null,
                    ),
                    _ValueChip(
                      l10n.metricTotal,
                      formatBytes(s?.memTotal ?? 0),
                      color: theme.colorScheme.outlineVariant,
                      width: null,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              CircularMetric(
                label: l10n.metricMemory,
                percent: s?.memPercent ?? 0,
                subtitle: s?.memSub ?? '-',
                size: 60,
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
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${l10n.metricMemory} ${l10n.metricUsageTrend}',
              style: theme.textTheme.labelLarge,
            ),
          ),
          const SizedBox(height: 8),
          _TrendLine(
            values: _metricTrend(
              history,
              (status) => status.memPercent,
              s?.memPercent ?? 0,
            ),
            color: Colors.orange,
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
    final theme = Theme.of(context);
    final s = status;
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  s?.diskMount ?? '/',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if ((s?.diskFsType ?? '').isNotEmpty) _Badge(s!.diskFsType),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${formatBytes(s?.diskUsed ?? 0)} / ${formatBytes(s?.diskTotal ?? 0)}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Text(
                '${((s?.diskPercent ?? 0) * 100).round()}%',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final s = status;
    final uploadColor = theme.colorScheme.primary;
    final downloadColor = theme.colorScheme.error;
    final trendSamples = _networkTrendSamples(history, s);
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.metricRealtimeRateTrend,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.metricUploadDownload,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                _networkRateUnitLabel(trendSamples),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _ValueChip(
                l10n.metricUpload,
                formatRate(s?.netUpRate ?? 0),
                color: uploadColor,
              ),
              _ValueChip(
                l10n.metricDownload,
                formatRate(s?.netDownRate ?? 0),
                color: downloadColor,
              ),
            ],
          ),
          const SizedBox(height: 8),
          _NetworkTrendLine(
            values: trendSamples,
            uploadColor: uploadColor,
            downloadColor: downloadColor,
          ),
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
