import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/models/server.dart';
import 'package:orbita/providers/server_provider.dart';
import 'package:orbita/widgets/common.dart';
import 'package:orbita/widgets/os_icon.dart';

/// Full server list management page (from Settings).
class ServerListPage extends ConsumerWidget {
  const ServerListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final serversAsync = ref.watch(serverListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsServers)),
      body: serversAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (servers) => servers.isEmpty
            ? EmptyState(
                icon: Ionicons.server_outline,
                title: l10n.noServersTitle,
                subtitle: l10n.noServersSubtitle,
              )
            : ListView.builder(
                itemCount: servers.length,
                itemBuilder: (context, index) {
                  final s = servers[index];
                  return _ServerListTile(server: s);
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/settings/servers/add'),
        child: const Icon(Ionicons.add),
      ),
    );
  }
}

class _ServerListTile extends ConsumerWidget {
  final Server server;
  const _ServerListTile({required this.server});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return ListTile(
      leading: OsIcon(type: server.osType, size: 24),
      title: Text(server.name),
      subtitle: Text(
        '${server.host}:${server.port} · ${server.username}',
        style: theme.textTheme.bodySmall,
      ),
      trailing: const Icon(Ionicons.chevron_forward),
      onTap: () => context.go('/settings/servers/${server.id}/edit'),
      onLongPress: () => _confirmDelete(context, ref, server),
    );
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
