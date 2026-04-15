import 'package:flutter/material.dart';
import 'package:orbita/widgets/circular_metric.dart';
import 'package:orbita/widgets/os_icon.dart';

/// Rich server status card for the home page.
class ServerCard extends StatelessWidget {
  final String name;
  final OsType osType;
  final bool online;
  final String uptime;
  final String load;
  final double cpuPercent;
  final String cpuSub;
  final double memPercent;
  final String memSub;
  final double diskPercent;
  final String diskSub;
  final String netUp;
  final String netUpTotal;
  final String netDown;
  final String netDownTotal;
  final String ioWrite;
  final String ioWriteTotal;
  final String ioRead;
  final String ioReadTotal;
  final VoidCallback? onTap;

  const ServerCard({
    super.key,
    required this.name,
    this.osType = OsType.unknown,
    this.online = false,
    this.uptime = '',
    this.load = '',
    this.cpuPercent = 0,
    this.cpuSub = '',
    this.memPercent = 0,
    this.memSub = '',
    this.diskPercent = 0,
    this.diskSub = '',
    this.netUp = '',
    this.netUpTotal = '',
    this.netDown = '',
    this.netDownTotal = '',
    this.ioWrite = '',
    this.ioWriteTotal = '',
    this.ioRead = '',
    this.ioReadTotal = '',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withAlpha(120),
          width: 1,
        ),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme),
              if (online) ...[
                const SizedBox(height: 16),
                _buildMetrics(theme),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        OsIcon(type: osType, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              if (!online)
                Text('离线',
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: theme.colorScheme.outlineVariant)),
            ],
          ),
        ),
        if (online && uptime.isNotEmpty) ...[
          Icon(Icons.power_settings_new, size: 14,
              color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(uptime,
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(width: 12),
        ],
        if (online && load.isNotEmpty) ...[
          Icon(Icons.show_chart, size: 14,
              color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(load,
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ],
    );
  }

  Widget _buildMetrics(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CircularMetric(
                  label: 'CPU', percent: cpuPercent, subtitle: cpuSub),
              CircularMetric(
                  label: 'Mem', percent: memPercent, subtitle: memSub),
              CircularMetric(
                  label: '磁盘', percent: diskPercent, subtitle: diskSub),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Row(
            children: [
              Expanded(
                  child: _TextMetric(
                      label: '网络',
                      up: netUp,
                      upTotal: netUpTotal,
                      down: netDown,
                      downTotal: netDownTotal)),
              Expanded(
                  child: _TextMetric(
                      label: 'I/O',
                      up: ioWrite,
                      upTotal: ioWriteTotal,
                      down: ioRead,
                      downTotal: ioReadTotal)),
            ],
          ),
        ),
      ],
    );
  }
}

class _TextMetric extends StatelessWidget {
  final String label;
  final String up;
  final String upTotal;
  final String down;
  final String downTotal;

  const _TextMetric({
    required this.label,
    required this.up,
    required this.upTotal,
    required this.down,
    required this.downTotal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sub = theme.textTheme.labelSmall?.copyWith(fontSize: 10);
    final val = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      fontSize: 10,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: theme.textTheme.labelSmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('↑ ', style: sub?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            Flexible(
                child: Text(up, style: sub, overflow: TextOverflow.ellipsis)),
          ],
        ),
        Text(upTotal, style: val),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('↓ ', style: sub?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            Flexible(
                child: Text(down, style: sub, overflow: TextOverflow.ellipsis)),
          ],
        ),
        Text(downTotal, style: val),
      ],
    );
  }
}
