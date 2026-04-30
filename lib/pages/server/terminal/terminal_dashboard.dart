import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/providers/server_monitor_provider.dart';
import 'package:orbita/utils/format_utils.dart';
import 'package:orbita/widgets/circular_metric.dart';
import 'package:orbita/widgets/text_metric.dart';

class TerminalDashboard extends ConsumerWidget {
  final String serverId;

  const TerminalDashboard({super.key, required this.serverId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final statusAsync = ref.watch(serverStatusProvider(serverId));
    final status = statusAsync.value;

    return Material(
      color: theme.colorScheme.surface,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.terminalDashboard,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          if (statusAsync.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (status == null)
            Text(
              l10n.sshDisconnected,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CircularMetric(
                  label: l10n.metricCpu,
                  percent: status.cpuPercent,
                  subtitle: status.cpuSub,
                ),
                CircularMetric(
                  label: l10n.metricMemory,
                  percent: status.memPercent,
                  subtitle: status.memSub,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: CircularMetric(
                label: l10n.metricDisk,
                percent: status.diskPercent,
                subtitle: status.diskSub,
              ),
            ),
            const SizedBox(height: 20),
            TextMetric(
              label: l10n.metricNetwork,
              up: formatRate(status.netUpRate),
              upTotal: formatBytes(status.netTxTotal),
              down: formatRate(status.netDownRate),
              downTotal: formatBytes(status.netRxTotal),
            ),
            const SizedBox(height: 16),
            TextMetric(
              label: l10n.metricIo,
              up: formatRate(status.ioWriteRate),
              upTotal: formatBytes(status.ioWriteTotal),
              down: formatRate(status.ioReadRate),
              downTotal: formatBytes(status.ioReadTotal),
            ),
          ],
        ],
      ),
    );
  }
}
