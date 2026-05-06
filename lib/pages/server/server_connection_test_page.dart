import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/models/server.dart';
import 'package:orbita/providers/key_provider.dart';
import 'package:orbita/providers/server_monitor_provider.dart';
import 'package:orbita/providers/server_provider.dart';
import 'package:orbita/providers/ssh_connection_provider.dart';
import 'package:orbita/widgets/common.dart';

class ServerConnectionTestPage extends ConsumerStatefulWidget {
  final String serverId;

  const ServerConnectionTestPage({super.key, required this.serverId});

  @override
  ConsumerState<ServerConnectionTestPage> createState() =>
      _ServerConnectionTestPageState();
}

class _ServerConnectionTestPageState
    extends ConsumerState<ServerConnectionTestPage> {
  final _logs = <String>[];
  Duration? _latency;
  bool _running = true;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _runTest();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final server = ref.watch(serverByIdProvider(widget.serverId));

    return Scaffold(
      appBar: compactPageAppBar(
        context,
        title: l10n.serverConnectionTestTitle,
      ),
      body: TonalListBackground(
        child: server == null
            ? EmptyState(
                icon: Ionicons.warning_outline,
                title: l10n.fileServerMissing,
                subtitle: l10n.fileServerMissingSubtitle,
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  _SummaryCard(
                    server: server,
                    running: _running,
                    latency: _latency,
                  ),
                  const SizedBox(height: 16),
                  SectionHeader(
                    title: l10n.serverConnectionLogs,
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  ),
                  Material(
                    color: tonalItemColor(context),
                    borderRadius: BorderRadius.circular(14),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        for (var i = 0; i < _logs.length; i++) ...[
                          if (i > 0) const Divider(height: 1),
                          ListTile(
                            dense: true,
                            leading: const Icon(
                              Ionicons.ellipse,
                              size: 8,
                            ),
                            title: Text(_logs[i]),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _runTest() async {
    final l10n = AppLocalizations.of(context)!;
    final server = ref.read(serverByIdProvider(widget.serverId));
    if (server == null) return;
    _append(l10n.serverConnectionLogResolving);

    try {
      final key = await resolveServerKey(
        server,
        ref.read(keyListProvider.future),
      );
      if (server.authType == AuthType.key && key == null) {
        throw StateError(l10n.authNoKey);
      }
      _append(l10n.serverConnectionLogConnecting(server.host, server.port));

      final stopwatch = Stopwatch()..start();
      final lease = await ref
          .read(sshConnectionManagerProvider)
          .acquire(server, key: key);
      try {
        await lease.service.execute('printf orbita');
        stopwatch.stop();
        _append(l10n.serverConnectionLogSucceeded);
        if (!mounted) return;
        setState(() {
          _latency = stopwatch.elapsed;
          _running = false;
        });
      } finally {
        lease.release();
      }
    } catch (error) {
      _append('${l10n.sshConnectionFailed}: $error');
      if (!mounted) return;
      setState(() => _running = false);
    }
  }

  void _append(String message) {
    if (!mounted) return;
    setState(() => _logs.add(message));
  }
}

class _SummaryCard extends StatelessWidget {
  final Server server;
  final bool running;
  final Duration? latency;

  const _SummaryCard({
    required this.server,
    required this.running,
    required this.latency,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final latency = this.latency;
    return Material(
      color: tonalItemColor(context),
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              running
                  ? Ionicons.sync_outline
                  : latency == null
                  ? Ionicons.close_circle_outline
                  : Ionicons.checkmark_circle_outline,
              color: latency == null && !running
                  ? theme.colorScheme.error
                  : theme.colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    server.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    latency == null
                        ? l10n.serverConnectionTesting
                        : l10n.serverConnectionLatency(
                            latency.inMilliseconds,
                          ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
