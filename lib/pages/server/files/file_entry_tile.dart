import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/models/remote_file_entry.dart';
import 'package:orbita/utils/format_utils.dart';

class FileEntryTile extends StatelessWidget {
  final RemoteFileEntry entry;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const FileEntryTile({
    super.key,
    required this.entry,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(_icon, size: 26, color: _iconColor(colorScheme)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              entry.isDirectory || entry.isParentLink
                  ? Ionicons.chevron_forward
                  : Ionicons.create_outline,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  IconData get _icon {
    return switch (entry.kind) {
      RemoteFileKind.parent => Ionicons.return_up_back,
      RemoteFileKind.directory => Ionicons.folder,
      RemoteFileKind.image => Ionicons.image_outline,
      RemoteFileKind.archive => Ionicons.archive_outline,
      RemoteFileKind.symlink => Ionicons.link_outline,
      RemoteFileKind.file => Ionicons.document_text_outline,
      RemoteFileKind.other => Ionicons.document_outline,
    };
  }

  Color _iconColor(ColorScheme colorScheme) {
    return switch (entry.kind) {
      RemoteFileKind.directory || RemoteFileKind.parent => colorScheme.primary,
      RemoteFileKind.image => colorScheme.tertiary,
      RemoteFileKind.archive => colorScheme.secondary,
      _ => colorScheme.onSurfaceVariant,
    };
  }

  String get _subtitle {
    if (entry.isParentLink) return entry.path;
    final details = <String>[];
    if (!entry.isDirectory) details.add(formatBytes(entry.size));
    if (entry.modifiedAt != null) {
      final local = entry.modifiedAt!.toLocal();
      details.add(
        '${local.year}-${_two(local.month)}-${_two(local.day)} '
        '${_two(local.hour)}:${_two(local.minute)}',
      );
    }
    if (entry.mode != null) {
      details.add((entry.mode! & 0x1ff).toRadixString(8).padLeft(3, '0'));
    }
    return details.isEmpty ? entry.path : details.join(' · ');
  }

  String _two(int value) => value.toString().padLeft(2, '0');
}
