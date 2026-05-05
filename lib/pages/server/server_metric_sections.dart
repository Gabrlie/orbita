import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/models/server.dart';
import 'package:orbita/models/server_status.dart';
import 'package:orbita/utils/format_utils.dart';
import 'package:orbita/widgets/circular_metric.dart';
import 'package:orbita/widgets/os_icon.dart';

part 'server_metric_resource_sections.dart';
part 'server_metric_widgets.dart';
part 'server_metric_chart.dart';

class ServerMetricSections extends StatelessWidget {
  final Server server;
  final ServerStatus? status;
  final List<ServerStatus> history;
  final String? statusMessage;
  final void Function(String command, String title) onOpenCommand;

  const ServerMetricSections({
    super.key,
    required this.server,
    required this.status,
    this.history = const [],
    required this.statusMessage,
    required this.onOpenCommand,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final s = status;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _OverviewSection(server: server, status: s, message: statusMessage),
        _SectionTitle(title: l10n.metricCpu),
        _CpuSection(status: s, history: history),
        _SectionTitle(title: l10n.metricMemory),
        _MemorySection(status: s, history: history),
        _SectionTitle(title: l10n.metricDisk),
        _DiskSection(status: s),
        _SectionTitle(title: l10n.metricNetwork),
        _NetworkSection(status: s, history: history),
        _SectionTitle(title: l10n.serverScriptsSection),
        _ActionGrid(
          actions: [
            _ActionSpec(
              icon: Ionicons.code_slash_outline,
              label: l10n.settingsScripts,
              onTap: () => context.go('/settings/scripts'),
            ),
            _ActionSpec(
              icon: Ionicons.add_circle_outline,
              label: l10n.scriptAdd,
              onTap: () => context.go('/settings/scripts/add'),
            ),
            _ActionSpec(
              icon: Ionicons.extension_puzzle_outline,
              label: l10n.settingsSnippets,
              onTap: () => context.go('/settings/snippets'),
            ),
          ],
        ),
        _SectionTitle(title: l10n.serverToolsSection),
        _ActionGrid(actions: _toolActions(l10n, context)),
      ],
    );
  }

  List<_ActionSpec> _toolActions(AppLocalizations l10n, BuildContext context) {
    return [
      _ActionSpec(
        icon: Ionicons.list_outline,
        label: l10n.serverToolProcesses,
        onTap: () => onOpenCommand(
          "ps aux --sort=-%cpu | head -25",
          l10n.serverToolProcesses,
        ),
      ),
      _ActionSpec(
        icon: Ionicons.git_network_outline,
        label: l10n.serverToolIpAddress,
        onTap: () => onOpenCommand(
          "ip -brief address || hostname -I",
          l10n.serverToolIpAddress,
        ),
      ),
      _ActionSpec(
        icon: Ionicons.analytics_outline,
        label: l10n.serverToolTraffic,
        onTap: () => onOpenCommand("cat /proc/net/dev", l10n.serverToolTraffic),
      ),
      _ActionSpec(
        icon: Ionicons.cube_outline,
        label: l10n.serverToolDocker,
        onTap: () => context.go('/docker/${server.id}'),
      ),
    ];
  }
}

class _OverviewSection extends StatelessWidget {
  final Server server;
  final ServerStatus? status;
  final String? message;

  const _OverviewSection({required this.server, this.status, this.message});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final os = osConfigOf(server.osType);
    final load = (status?.loadAvg ?? '0 0 0').split(RegExp(r'\s+'));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: OsIcon(type: server.osType, size: 28),
          title: Text(os.label),
          subtitle: Text('${server.host}:${server.port}'),
          trailing: const Icon(Ionicons.chevron_down_outline),
        ),
        _Panel(
          child: Row(
            children: [
              Expanded(child: _TinyMetric(l10n.metricLoad1, _part(load, 0))),
              Expanded(child: _TinyMetric(l10n.metricLoad5, _part(load, 1))),
              Expanded(child: _TinyMetric(l10n.metricLoad15, _part(load, 2))),
              Expanded(
                child: _TinyMetric(l10n.metricUptime, status?.uptimeStr ?? '-'),
              ),
              CircularMetric(
                label: l10n.metricCpu,
                percent: status?.cpuPercent ?? 0,
                subtitle: status?.cpuSub ?? '-',
                size: 58,
              ),
            ],
          ),
        ),
        if (status == null && message != null) ...[
          const SizedBox(height: 8),
          Text(
            message!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}
