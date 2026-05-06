import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/models/server.dart';
import 'package:orbita/models/server_status.dart';
import 'package:orbita/providers/key_provider.dart';
import 'package:orbita/providers/server_monitor_provider.dart';
import 'package:orbita/providers/ssh_connection_provider.dart';
import 'package:orbita/utils/format_utils.dart';
import 'package:orbita/widgets/circular_metric.dart';
import 'package:orbita/widgets/common.dart';
import 'package:orbita/widgets/os_icon.dart';

part 'server_metric_resource_sections.dart';
part 'server_metric_widgets.dart';
part 'server_metric_chart.dart';

class ServerMetricSections extends ConsumerStatefulWidget {
  final Server server;
  final ServerStatus? status;
  final List<ServerStatus> history;
  final String? statusMessage;
  final bool showTools;

  const ServerMetricSections({
    super.key,
    required this.server,
    required this.status,
    this.history = const [],
    required this.statusMessage,
    this.showTools = true,
  });

  @override
  ConsumerState<ServerMetricSections> createState() =>
      _ServerMetricSectionsState();
}

class _ServerMetricSectionsState extends ConsumerState<ServerMetricSections> {
  final _collapsed = <String>{};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final s = widget.status;
    final osTitle = s?.osDisplayName.isNotEmpty == true
        ? s!.osDisplayName
        : osConfigOf(widget.server.osType).label;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      children: [
        _section(
          id: 'overview',
          title: osTitle,
          icon: OsIcon(type: widget.server.osType, size: 18),
          child: _OverviewSection(status: s, message: widget.statusMessage),
        ),
        _section(
          id: 'cpu',
          title: l10n.metricCpu,
          icon: const Icon(Ionicons.pulse_outline, size: 18),
          child: _CpuSection(status: s, history: widget.history),
        ),
        _section(
          id: 'memory',
          title: l10n.metricMemory,
          icon: const Icon(Ionicons.hardware_chip_outline, size: 18),
          child: _MemorySection(status: s, history: widget.history),
        ),
        _section(
          id: 'disk',
          title: l10n.metricDisk,
          icon: const Icon(Ionicons.layers_outline, size: 18),
          child: _DiskSection(status: s),
        ),
        _section(
          id: 'network',
          title: l10n.metricNetwork,
          icon: const Icon(Ionicons.swap_vertical_outline, size: 18),
          child: _NetworkSection(status: s, history: widget.history),
        ),
        if (widget.showTools) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 22, 2, 8),
            child: Text(
              l10n.serverToolsSection,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _ActionGrid(actions: _toolActions(l10n, context)),
        ],
      ],
    );
  }

  Widget _section({
    required String id,
    required String title,
    required Widget icon,
    required Widget child,
  }) {
    final collapsed = _collapsed.contains(id);
    return _CollapsibleMetricSection(
      title: title,
      icon: icon,
      collapsed: collapsed,
      onTap: () {
        setState(() {
          collapsed ? _collapsed.remove(id) : _collapsed.add(id);
        });
      },
      child: child,
    );
  }

  List<_ActionSpec> _toolActions(AppLocalizations l10n, BuildContext context) {
    return [
      _ActionSpec(
        icon: Ionicons.list_outline,
        label: l10n.serverToolProcesses,
        onTap: () => _showTool(context, _MetricTool.processes, l10n),
      ),
      _ActionSpec(
        icon: Ionicons.git_network_outline,
        label: l10n.serverToolIpAddress,
        onTap: () => _showTool(context, _MetricTool.ipAddress, l10n),
      ),
      _ActionSpec(
        icon: Ionicons.analytics_outline,
        label: l10n.serverToolTraffic,
        onTap: () => _showTool(context, _MetricTool.traffic, l10n),
      ),
    ];
  }

  void _showTool(
    BuildContext context,
    _MetricTool tool,
    AppLocalizations l10n,
  ) {
    final title = switch (tool) {
      _MetricTool.processes => l10n.serverToolProcesses,
      _MetricTool.ipAddress => l10n.serverToolIpAddress,
      _MetricTool.traffic => l10n.serverToolTraffic,
    };
    showDialog<void>(
      context: context,
      builder: (context) => _MetricToolDialog(
        server: widget.server,
        tool: tool,
        title: title,
      ),
    );
  }
}

enum _MetricTool { processes, ipAddress, traffic }

class _MetricToolDialog extends ConsumerStatefulWidget {
  final Server server;
  final _MetricTool tool;
  final String title;

  const _MetricToolDialog({
    required this.server,
    required this.tool,
    required this.title,
  });

  @override
  ConsumerState<_MetricToolDialog> createState() => _MetricToolDialogState();
}

class _MetricToolDialogState extends ConsumerState<_MetricToolDialog> {
  late final Future<_MetricToolResult> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: double.maxFinite,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 360),
          child: FutureBuilder<_MetricToolResult>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return SelectableText(
                  '${l10n.fileCommandFailed}\n${snapshot.error}',
                );
              }
              final result = snapshot.data;
              if (result == null || result.rows.isEmpty) {
                return SelectableText(
                  result?.raw.trim().isNotEmpty == true
                      ? result!.raw.trim()
                      : '-',
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                itemCount: result.rows.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final row = result.rows[index];
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(row.title),
                    subtitle: row.subtitle == null ? null : Text(row.subtitle!),
                    trailing: row.trailing == null
                        ? null
                        : Text(
                            row.trailing!,
                            textAlign: TextAlign.right,
                          ),
                  );
                },
              );
            },
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonOk),
        ),
      ],
    );
  }

  Future<_MetricToolResult> _load() async {
    final key = await resolveServerKey(
      widget.server,
      ref.read(keyListProvider.future),
    );
    if (widget.server.authType == AuthType.key && key == null) {
      throw StateError('SSH key not found');
    }
    final lease = await ref
        .read(sshConnectionManagerProvider)
        .acquire(widget.server, key: key);
    try {
      final output = await lease.service.execute(_commandFor(widget.tool));
      return switch (widget.tool) {
        _MetricTool.processes => _parseProcesses(output),
        _MetricTool.ipAddress => _parseIpAddress(output),
        _MetricTool.traffic => _parseTraffic(output),
      };
    } finally {
      lease.release();
    }
  }
}

class _MetricToolResult {
  final List<_MetricToolRow> rows;
  final String raw;

  const _MetricToolResult({required this.rows, required this.raw});
}

class _MetricToolRow {
  final String title;
  final String? subtitle;
  final String? trailing;

  const _MetricToolRow({this.subtitle, this.trailing, required this.title});
}

String _commandFor(_MetricTool tool) {
  return switch (tool) {
    _MetricTool.processes =>
      'ps -eo pid,comm,%cpu,%mem --sort=-%cpu 2>/dev/null | head -16',
    _MetricTool.ipAddress => 'ip -brief address 2>/dev/null || hostname -I',
    _MetricTool.traffic => 'cat /proc/net/dev 2>/dev/null',
  };
}

_MetricToolResult _parseProcesses(String output) {
  final rows = <_MetricToolRow>[];
  for (final line in output.trim().split('\n').skip(1)) {
    final parts = line.trim().split(RegExp(r'\s+'));
    if (parts.length < 4) continue;
    rows.add(
      _MetricToolRow(
        title: parts[1],
        subtitle: 'PID ${parts[0]}',
        trailing: 'CPU ${parts[2]}%\nMEM ${parts[3]}%',
      ),
    );
  }
  return _MetricToolResult(rows: rows, raw: output);
}

_MetricToolResult _parseIpAddress(String output) {
  final rows = <_MetricToolRow>[];
  final trimmed = output.trim();
  if (trimmed.isEmpty) return _MetricToolResult(rows: rows, raw: output);
  final lines = trimmed.split('\n');
  for (final line in lines) {
    final parts = line.trim().split(RegExp(r'\s+'));
    if (parts.length >= 3) {
      rows.add(
        _MetricToolRow(
          title: parts[0],
          subtitle: parts.skip(2).join(' '),
          trailing: parts[1],
        ),
      );
    }
  }
  if (rows.isEmpty) {
    rows.add(_MetricToolRow(title: 'IP', subtitle: trimmed));
  }
  return _MetricToolResult(rows: rows, raw: output);
}

_MetricToolResult _parseTraffic(String output) {
  final rows = <_MetricToolRow>[];
  for (final line in output.split('\n')) {
    final separator = line.indexOf(':');
    if (separator < 0) continue;
    final name = line.substring(0, separator).trim();
    final parts = line
        .substring(separator + 1)
        .trim()
        .split(RegExp(r'\s+'));
    if (name.isEmpty || parts.length < 16) continue;
    final rx = int.tryParse(parts[0]) ?? 0;
    final tx = int.tryParse(parts[8]) ?? 0;
    rows.add(
      _MetricToolRow(
        title: name,
        subtitle: '↑ ${formatBytes(tx)} / ↓ ${formatBytes(rx)}',
      ),
    );
  }
  return _MetricToolResult(rows: rows, raw: output);
}

class _OverviewSection extends StatelessWidget {
  final ServerStatus? status;
  final String? message;

  const _OverviewSection({this.status, this.message});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final load = (status?.loadAvg ?? '0 0 0').split(RegExp(r'\s+'));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Panel(
          surface: true,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _TinyMetric(l10n.metricLoad1, _part(load, 0)),
                        ),
                        Expanded(
                          child: _TinyMetric(l10n.metricLoad5, _part(load, 1)),
                        ),
                        Expanded(
                          child: _TinyMetric(l10n.metricLoad15, _part(load, 2)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _TinyMetric(
                        l10n.metricUptime,
                        status?.uptimeStr ?? '-',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              CircularMetric(
                label: l10n.metricCpu,
                percent: status?.cpuPercent ?? 0,
                subtitle: status?.cpuSub ?? '-',
                size: 54,
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
