import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/models/server.dart';
import 'package:orbita/providers/server_group_provider.dart';
import 'package:orbita/providers/server_provider.dart';
import 'package:orbita/widgets/common.dart';
import 'package:orbita/widgets/os_icon.dart';

class ServerPickerList extends ConsumerWidget {
  final IconData emptyIcon;
  final ValueChanged<Server> onSelected;
  final void Function(
    BuildContext context,
    WidgetRef ref,
    Server server,
    Offset position,
  )?
  onLongPress;

  const ServerPickerList({
    super.key,
    required this.emptyIcon,
    required this.onSelected,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final serversAsync = ref.watch(serverListProvider);
    final groupState = ref.watch(serverGroupProvider);

    return TonalListBackground(
      child: serversAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (servers) {
          if (servers.isEmpty) {
            return EmptyState(
              icon: emptyIcon,
              title: l10n.noServersTitle,
              subtitle: l10n.noServersSubtitle,
            );
          }
          final buckets = groupServersForDisplay(
            servers: servers,
            groupState: groupState,
            unnamedGroupName: l10n.serverGroupUnnamed,
          ).where((bucket) => bucket.servers.isNotEmpty).toList();
          final showHeaders = shouldShowServerGroupHeaders(buckets);
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              for (final bucket in buckets) ...[
                if (showHeaders)
                  SectionHeader(
                    title: bucket.name,
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  ),
                for (final server in bucket.servers)
                  _ServerPickerTile(
                    server: server,
                    onTap: () => onSelected(server),
                    onLongPress: onLongPress == null
                        ? null
                        : (position) =>
                              onLongPress!(context, ref, server, position),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _ServerPickerTile extends StatelessWidget {
  final Server server;
  final VoidCallback onTap;
  final ValueChanged<Offset>? onLongPress;

  const _ServerPickerTile({
    required this.server,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 3,
      shadowColor: theme.colorScheme.shadow.withAlpha(32),
      surfaceTintColor: Colors.transparent,
      color: tonalItemColor(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      clipBehavior: Clip.antiAlias,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPressStart: onLongPress == null
            ? null
            : (details) => onLongPress!(details.globalPosition),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                OsIcon(type: server.osType, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        server.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${server.host}:${server.port}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Ionicons.chevron_forward,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
