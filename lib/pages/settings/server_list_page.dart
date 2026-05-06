import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/models/server.dart';
import 'package:orbita/providers/server_group_provider.dart';
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
    final groupState = ref.watch(serverGroupProvider);

    return Scaffold(
      appBar: compactPageAppBar(
        context,
        title: l10n.settingsServers,
        fallbackLocation: '/settings',
      ),
      body: TonalListBackground(
        child: serversAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (servers) {
            final buckets = groupServersForDisplay(
              servers: servers,
              groupState: groupState,
              unnamedGroupName: l10n.serverGroupUnnamed,
            ).where((bucket) => bucket.servers.isNotEmpty).toList();
            final showHeaders = shouldShowServerGroupHeaders(buckets);
            return servers.isEmpty
              ? EmptyState(
                  icon: Ionicons.server_outline,
                  title: l10n.noServersTitle,
                  subtitle: l10n.noServersSubtitle,
                )
              : ListView(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  children: [
                    for (final bucket in buckets) ...[
                      if (showHeaders)
                        SectionHeader(
                          title: bucket.name,
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                        ),
                      for (final server in bucket.servers)
                        Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          color: tonalItemColor(context),
                          surfaceTintColor: Colors.transparent,
                          clipBehavior: Clip.antiAlias,
                          child: _ServerListTile(server: server),
                        ),
                    ],
                  ],
                );
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: OsIcon(type: server.osType, size: 22),
      minLeadingWidth: 24,
      title: Text(
        server.name,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text(
          '${server.host}:${server.port} · ${server.username}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
      trailing: Icon(
        Ionicons.chevron_forward,
        color: theme.colorScheme.outline,
        size: 18,
      ),
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
