import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/models/server.dart';
import 'package:orbita/models/server_group.dart';
import 'package:orbita/providers/server_group_provider.dart';
import 'package:orbita/widgets/common.dart';
import 'package:orbita/widgets/os_icon.dart';

class GroupDropSection extends ConsumerWidget {
  final ServerGroupBucket bucket;
  final List<ServerGroup> groups;
  final ValueChanged<ServerGroup> onEdit;

  const GroupDropSection({
    super.key,
    required this.bucket,
    required this.groups,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final group = groups.where((item) => item.id == bucket.id).firstOrNull;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DragTarget<Object>(
        onWillAcceptWithDetails: (details) => _canAccept(details.data),
        onAcceptWithDetails: (details) => _accept(ref, details.data),
        builder: (context, candidates, _) {
          final active = candidates.isNotEmpty;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            decoration: BoxDecoration(
              color: tonalItemColor(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: active
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outlineVariant,
              ),
            ),
            child: Column(
              children: [
                _GroupHeader(
                  bucket: bucket,
                  group: group,
                  onEdit: onEdit,
                  onDelete: group == null ? null : () => _delete(context, ref),
                ),
                if (bucket.servers.isEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                    child: Text(
                      l10n.serverGroupDropHint,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                else
                  for (final server in bucket.servers)
                    _DraggableServerTile(server: server, bucketId: bucket.id),
              ],
            ),
          );
        },
      ),
    );
  }

  bool _canAccept(Object data) {
    if (data is Server) return true;
    if (data is ServerGroup) {
      return !bucket.isUngrouped && data.id != bucket.id;
    }
    return false;
  }

  void _accept(WidgetRef ref, Object data) {
    final notifier = ref.read(serverGroupProvider.notifier);
    if (data is Server) {
      notifier.moveServer(
        serverId: data.id,
        groupId: bucket.isUngrouped ? null : bucket.id,
      );
    } else if (data is ServerGroup && !bucket.isUngrouped) {
      notifier.reorderGroup(data.id, bucket.id);
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final group = groups.where((item) => item.id == bucket.id).firstOrNull;
    if (group == null) return;
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.serverGroupDeleteTitle,
      content: l10n.serverGroupDeleteContent(group.name),
      confirmLabel: l10n.commonDelete,
      destructive: true,
    );
    if (confirmed) {
      await ref.read(serverGroupProvider.notifier).deleteGroup(group.id);
    }
  }
}

class _GroupHeader extends StatelessWidget {
  final ServerGroupBucket bucket;
  final ServerGroup? group;
  final ValueChanged<ServerGroup> onEdit;
  final VoidCallback? onDelete;

  const _GroupHeader({
    required this.bucket,
    required this.group,
    required this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final group = this.group;
    return ListTile(
      leading: _GroupDragHandle(
        group: group,
        icon: bucket.isUngrouped
            ? Ionicons.file_tray_outline
            : Ionicons.folder_outline,
      ),
      title: Text(bucket.name),
      subtitle: Text(l10n.serverGroupCount(bucket.servers.length)),
      trailing: bucket.isUngrouped || group == null
          ? null
          : Wrap(
              children: [
                IconButton(
                  tooltip: l10n.commonEdit,
                  icon: const Icon(Ionicons.create_outline),
                  onPressed: () => onEdit(group),
                ),
                IconButton(
                  tooltip: l10n.commonDelete,
                  icon: Icon(
                    Ionicons.trash_outline,
                    color: theme.colorScheme.error,
                  ),
                  onPressed: onDelete,
                ),
              ],
            ),
    );
  }
}

class _GroupDragHandle extends StatelessWidget {
  final ServerGroup? group;
  final IconData icon;

  const _GroupDragHandle({required this.group, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final child = Icon(icon, color: theme.colorScheme.primary);
    final group = this.group;
    if (group == null) return child;
    return LongPressDraggable<ServerGroup>(
      data: group,
      feedback: Material(
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 220,
          child: ListTile(
            leading: child,
            title: Text(group.name),
            trailing: const Icon(Ionicons.reorder_three_outline),
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.35, child: child),
      child: child,
    );
  }
}

class _DraggableServerTile extends ConsumerWidget {
  final Server server;
  final String bucketId;

  const _DraggableServerTile({required this.server, required this.bucketId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DragTarget<Server>(
      onWillAcceptWithDetails: (details) => details.data.id != server.id,
      onAcceptWithDetails: (details) => ref
          .read(serverGroupProvider.notifier)
          .moveServer(
            serverId: details.data.id,
            groupId: bucketId,
            beforeServerId: server.id,
          ),
      builder: (context, candidates, _) {
        final tile = DecoratedBox(
          decoration: BoxDecoration(
            border: candidates.isEmpty
                ? null
                : Border(
                    top: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
          ),
          child: _ServerTile(server: server),
        );
        return LongPressDraggable<Server>(
          data: server,
          feedback: Material(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(width: 260, child: _ServerTile(server: server)),
          ),
          childWhenDragging: Opacity(opacity: 0.35, child: tile),
          child: tile,
        );
      },
    );
  }
}

class _ServerTile extends StatelessWidget {
  final Server server;

  const _ServerTile({required this.server});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: OsIcon(type: server.osType, size: 20),
      title: Text(server.name),
      subtitle: Text(server.displayEndpoint),
      trailing: const Icon(Ionicons.reorder_three_outline),
    );
  }
}
