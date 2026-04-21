import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/models/server.dart';
import 'package:orbita/providers/server_monitor_provider.dart';
import 'package:orbita/providers/server_provider.dart';
import 'package:orbita/providers/server_refresh_provider.dart';
import 'package:orbita/utils/format_utils.dart';
import 'package:orbita/widgets/common.dart';
import 'package:orbita/widgets/server_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final serversAsync = ref.watch(serverListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.servers),
        actions: [
          PopupMenuButton<String>(
            tooltip: l10n.homeMoreActions,
            icon: const Icon(Ionicons.ellipsis_horizontal),
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: Text(
                  '${l10n.homeLayoutOptions} (${l10n.inDevelopment})',
                ),
              ),
              PopupMenuItem(
                enabled: false,
                child: Text('${l10n.settingsGroups} (${l10n.inDevelopment})'),
              ),
            ],
          ),
        ],
      ),
      body: serversAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (servers) => RefreshIndicator(
          onRefresh: () async {
            ref
                .read(serverRefreshControllerProvider.notifier)
                .refreshAll(servers.map((server) => server.id));
          },
          child: servers.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(top: 32),
                  children: [
                    SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.6,
                      child: EmptyState(
                        icon: Ionicons.server,
                        title: l10n.noServersTitle,
                        subtitle: l10n.noServersSubtitle,
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: servers.length,
                  itemBuilder: (context, index) {
                    final s = servers[index];
                    return _ServerCardItem(server: s);
                  },
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/home/server/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Wraps ServerCard with live status from SSH and popup menu.
class _ServerCardItem extends ConsumerWidget {
  final Server server;
  const _ServerCardItem({required this.server});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final statusAsync = ref.watch(serverStatusProvider(server.id));
    final status = statusAsync.value;
    final online = status != null;

    // Determine status message for offline state
    String? statusMessage;
    if (!online) {
      if (statusAsync.isLoading) {
        statusMessage = l10n.sshConnecting;
      } else if (statusAsync.hasError) {
        statusMessage = '${l10n.sshConnectionFailed}: ${statusAsync.error}';
      } else {
        // AsyncData(null) → connection failed or returned null
        statusMessage = l10n.sshConnectionFailed;
      }
    }

    return ServerCard(
      name: server.name,
      subtitle: '${server.host}:${server.port}',
      osType: server.osType,
      online: online,
      statusMessage: statusMessage,
      uptime: status?.uptimeStr ?? '',
      load: status?.loadAvg ?? '',
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
      onLongPress: (position) =>
          _showServerMenu(context, ref, server, position),
    );
  }

  void _showServerMenu(
    BuildContext context,
    WidgetRef ref,
    Server server,
    Offset position,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final relativeRect = RelativeRect.fromRect(
      Rect.fromLTWH(position.dx, position.dy, 0, 0),
      Offset.zero & overlay.size,
    );

    final disabledStyle = TextStyle(color: theme.disabledColor);
    final errorStyle = TextStyle(color: theme.colorScheme.error);

    showMenu<String>(
      context: context,
      position: relativeRect,
      items: [
        PopupMenuItem(
          enabled: false,
          child: Text(
            '${l10n.actionConnect} (${l10n.inDevelopment})',
            style: disabledStyle,
          ),
        ),
        PopupMenuItem(
          enabled: false,
          child: Text(
            '${l10n.actionFileManager} (${l10n.inDevelopment})',
            style: disabledStyle,
          ),
        ),
        PopupMenuItem(
          enabled: false,
          child: Text(
            '${l10n.actionDocker} (${l10n.inDevelopment})',
            style: disabledStyle,
          ),
        ),
        PopupMenuItem(
          enabled: false,
          child: Text(
            '${l10n.actionScripts} (${l10n.inDevelopment})',
            style: disabledStyle,
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'refresh',
          height: 48,
          child: Row(
            children: [
              const Icon(Icons.refresh, size: 20),
              const SizedBox(width: 12),
              Text(
                l10n.actionRefresh,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'logs',
          height: 48,
          child: Row(
            children: [
              const Icon(Icons.receipt_long_outlined, size: 20),
              const SizedBox(width: 12),
              Text(
                l10n.actionLogs,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'edit',
          height: 48,
          child: Row(
            children: [
              const Icon(Icons.edit_outlined, size: 20),
              const SizedBox(width: 12),
              Text(
                l10n.actionEdit,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          height: 48,
          child: Row(
            children: [
              Icon(
                Icons.delete_outline,
                size: 20,
                color: theme.colorScheme.error,
              ),
              const SizedBox(width: 12),
              Text(
                l10n.actionDelete,
                style: errorStyle.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == null || !context.mounted) return;
      switch (value) {
        case 'refresh':
          ref
              .read(serverRefreshControllerProvider.notifier)
              .refreshServer(server.id);
        case 'logs':
          context.go('/home/server/${server.id}/logs');
        case 'edit':
          context.go('/home/server/${server.id}/edit');
        case 'delete':
          _confirmDelete(context, ref, server);
      }
    });
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
}
