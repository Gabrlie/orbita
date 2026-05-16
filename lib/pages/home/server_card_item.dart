import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/models/server.dart';
import 'package:orbita/providers/key_provider.dart';
import 'package:orbita/providers/server_monitor_provider.dart';
import 'package:orbita/providers/server_provider.dart';
import 'package:orbita/providers/server_refresh_provider.dart';
import 'package:orbita/providers/ssh_connection_provider.dart';
import 'package:orbita/utils/format_utils.dart';
import 'package:orbita/widgets/common.dart';
import 'package:orbita/widgets/orbita_forui.dart';
import 'package:orbita/widgets/server_card.dart';

/// Wraps ServerCard with live status from SSH and popup menu.
class ServerCardItem extends ConsumerWidget {
  final Server server;

  const ServerCardItem({super.key, required this.server});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final statusAsync = ref.watch(serverStatusProvider(server.id));
    final status = statusAsync.value;
    final online = status != null;

    String? statusMessage;
    if (!online) {
      if (statusAsync.isLoading) {
        statusMessage = server.connectionMode == ServerConnectionMode.tailscale
            ? l10n.tailnetStarting
            : l10n.sshConnecting;
      } else if (statusAsync.hasError) {
        statusMessage = '${l10n.sshConnectionFailed}: ${statusAsync.error}';
      } else {
        statusMessage = l10n.sshConnectionFailed;
      }
    }

    final card = ServerCard(
      name: server.name,
      osType: server.osType,
      online: online,
      statusMessage: statusMessage,
      uptime: status?.uptimeStr ?? '',
      load: _latestLoad(status?.loadAvg),
      cpuPercent: status?.cpuPercent ?? 0,
      cpuSub: status?.cpuSub ?? '',
      memPercent: status?.memPercent ?? 0,
      memSub: status?.memSub ?? '',
      diskPercent: status?.diskPercent ?? 0,
      diskSub: status?.diskSub ?? '',
      netUp: status != null ? formatRate(status.netUpRate) : '',
      netUpTotal: status != null ? formatBytes(status.netTxTotal) : '',
      netDown: status != null ? formatRate(status.netDownRate) : '',
      netDownTotal: status != null ? formatBytes(status.netRxTotal) : '',
      ioWrite: status != null ? formatRate(status.ioWriteRate) : '',
      ioWriteTotal: status != null ? formatBytes(status.ioWriteTotal) : '',
      ioRead: status != null ? formatRate(status.ioReadRate) : '',
      ioReadTotal: status != null ? formatBytes(status.ioReadTotal) : '',
      onTap: () => context.go('/home/server/${server.id}'),
    );

    return OrbitaLongPressMenu<String>(
      actions: _serverMenuActions(l10n),
      onSelected: (value) => _handleServerMenuAction(
        context,
        ref,
        server,
        value,
      ),
      child: card,
    );
  }

  String _latestLoad(String? loadAvg) {
    if (loadAvg == null) return '';
    final parts = loadAvg.trim().split(RegExp(r'\s+'));
    return parts.isEmpty || parts.first.isEmpty ? '' : parts.first;
  }

  List<OrbitaMenuAction<String>> _serverMenuActions(AppLocalizations l10n) => [
        OrbitaMenuAction(
          value: 'terminal',
          icon: Ionicons.terminal_outline,
          label: l10n.navTerminal,
        ),
        OrbitaMenuAction(
          value: 'files',
          icon: Ionicons.folder_outline,
          label: l10n.actionFileManager,
        ),
        OrbitaMenuAction(
          value: 'docker',
          icon: Ionicons.cube_outline,
          label: l10n.navDocker,
        ),
        OrbitaMenuAction(
          value: 'refresh',
          icon: Ionicons.refresh_outline,
          label: l10n.commonRefresh,
        ),
        OrbitaMenuAction(
          value: 'test',
          icon: Ionicons.speedometer_outline,
          label: l10n.commonTest,
        ),
        OrbitaMenuAction(
          value: 'logs',
          icon: Ionicons.receipt_outline,
          label: l10n.serverLogsShort,
        ),
        OrbitaMenuAction(
          value: 'reboot',
          icon: Ionicons.reload_outline,
          label: l10n.serverReboot,
          dividerBefore: true,
        ),
        OrbitaMenuAction(
          value: 'shutdown',
          icon: Ionicons.power_outline,
          label: l10n.serverShutdown,
        ),
        OrbitaMenuAction(
          value: 'edit',
          icon: Ionicons.create_outline,
          label: l10n.commonEdit,
        ),
        OrbitaMenuAction(
          value: 'delete',
          icon: Ionicons.trash_outline,
          label: l10n.commonDelete,
          destructive: true,
        ),
      ];

  void _handleServerMenuAction(
    BuildContext context,
    WidgetRef ref,
    Server server,
    String value,
  ) {
      final l10n = AppLocalizations.of(context)!;
      if (!context.mounted) return;
      switch (value) {
        case 'terminal':
          context.go('/terminal/${server.id}');
        case 'files':
          context.go('/files/${server.id}');
        case 'docker':
          context.go('/docker/${server.id}');
        case 'refresh':
          ref
              .read(serverRefreshControllerProvider.notifier)
              .refreshServer(server.id);
        case 'test':
          context.go('/home/server/${server.id}/test');
        case 'logs':
          context.go('/home/server/${server.id}/logs');
        case 'reboot':
          _confirmRemotePowerAction(
            context,
            ref,
            server,
            title: l10n.serverRebootConfirmTitle,
            content: l10n.serverRebootConfirmContent(server.name),
            command: 'systemctl reboot || sudo -n reboot || reboot',
          );
        case 'shutdown':
          _confirmRemotePowerAction(
            context,
            ref,
            server,
            title: l10n.serverShutdownConfirmTitle,
            content: l10n.serverShutdownConfirmContent(server.name),
            command: 'systemctl poweroff || sudo -n poweroff || poweroff',
          );
        case 'edit':
          context.go('/home/server/${server.id}/edit');
        case 'delete':
          _confirmDelete(context, ref, server);
      }
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Server server,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.deleteServerTitle,
      content: l10n.deleteServerContent(server.name),
      confirmLabel: l10n.commonDelete,
      destructive: true,
    );
    if (confirmed) {
      ref.read(serverListProvider.notifier).deleteServer(server.id);
    }
  }

  Future<void> _confirmRemotePowerAction(
    BuildContext context,
    WidgetRef ref,
    Server server, {
    required String title,
    required String content,
    required String command,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showConfirmDialog(
      context,
      title: title,
      content: content,
      confirmLabel: l10n.commonConfirm,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    try {
      final key = await resolveServerKey(
        server,
        ref.read(keyListProvider.future),
      );
      if (server.authType == AuthType.key && key == null) {
        throw StateError(l10n.authNoKey);
      }
      final lease = await ref
          .read(sshConnectionManagerProvider)
          .acquire(server, key: key);
      try {
        await lease.service.execute(command);
      } finally {
        lease.release();
      }
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.commonActionDone)));
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.commonActionFailed}: $error')),
      );
    }
  }
}
