import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/widgets/circular_metric.dart';
import 'package:orbita/widgets/os_icon.dart';
import 'package:orbita/widgets/text_metric.dart';

/// Rich server status card for the home page.
class ServerCard extends StatelessWidget {
  final String name;
  final String? subtitle;
  final OsType osType;
  final bool online;

  /// Shown in the metrics area when [online] is false.
  final String? statusMessage;

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

  /// Long-press callback with the global position (for popup menu).
  final void Function(Offset position)? onLongPress;

  const ServerCard({
    super.key,
    required this.name,
    this.subtitle,
    this.osType = OsType.unknown,
    this.online = false,
    this.statusMessage,
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
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Capture pointer position for long-press popup menu.
    var pointerPosition = Offset.zero;

    return Card(
      elevation: 3,
      shadowColor: theme.colorScheme.shadow.withAlpha(36),
      surfaceTintColor: Colors.transparent,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      clipBehavior: Clip.antiAlias,
      child: Listener(
        onPointerDown: (event) => pointerPosition = event.position,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress != null
              ? () => onLongPress!(pointerPosition)
              : null,
          child: Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildHeader(context, theme),
                ),
                const SizedBox(height: 20),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildMetricsArea(theme, l10n),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        OsIcon(type: osType, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
        if (online && uptime.isNotEmpty) ...[
          Icon(
            Icons.power_settings_new,
            size: 14,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            uptime,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 12),
        ],
        if (online && load.isNotEmpty) ...[
          Icon(
            Icons.show_chart,
            size: 14,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            load,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  /// Always renders metrics; overlays gaussian blur + status text when offline.
  Widget _buildMetricsArea(ThemeData theme, AppLocalizations l10n) {
    final metrics = _buildMetrics(theme, l10n);
    if (online) return metrics;

    // Offline: metrics underneath with blur overlay + centered message
    return ClipRect(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Render metrics as placeholder (values will be 0 / empty)
          metrics,
          // Gaussian blur overlay
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withAlpha(180),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: _buildStatusLabel(theme),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusLabel(ThemeData theme) {
    if (statusMessage == null || statusMessage!.isEmpty) {
      return const SizedBox.shrink();
    }
    final isLoading = statusMessage!.contains('...');
    final color = isLoading
        ? theme.colorScheme.onSurfaceVariant
        : theme.colorScheme.error;
    final icon = isLoading ? Icons.sync : Icons.error_outline;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              statusMessage!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetrics(ThemeData theme, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CircularMetric(
                label: l10n.metricCpu,
                percent: cpuPercent,
                subtitle: cpuSub,
              ),
              CircularMetric(
                label: l10n.metricMemory,
                percent: memPercent,
                subtitle: memSub,
              ),
              CircularMetric(
                label: l10n.metricDisk,
                percent: diskPercent,
                subtitle: diskSub,
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Row(
            children: [
              Expanded(
                child: TextMetric(
                  label: l10n.metricNetwork,
                  up: netUp,
                  upTotal: netUpTotal,
                  down: netDown,
                  downTotal: netDownTotal,
                ),
              ),
              Expanded(
                child: TextMetric(
                  label: l10n.metricIo,
                  up: ioWrite,
                  upTotal: ioWriteTotal,
                  down: ioRead,
                  downTotal: ioReadTotal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
