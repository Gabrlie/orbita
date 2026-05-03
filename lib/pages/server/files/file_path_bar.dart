import 'package:flutter/material.dart';
import 'package:orbita/models/remote_file_entry.dart';

class FilePathBar extends StatelessWidget {
  final String path;
  final ValueChanged<String>? onTapPath;

  const FilePathBar({super.key, required this.path, this.onTapPath});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final breadcrumbs = remotePathBreadcrumbs(path);

    return Material(
      color: theme.colorScheme.surface,
      child: SizedBox(
        height: 48,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          scrollDirection: Axis.horizontal,
          itemCount: breadcrumbs.length,
          separatorBuilder: (context, index) => Icon(
            Icons.chevron_right,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          itemBuilder: (context, index) {
            final breadcrumb = breadcrumbs[index];
            final selected = index == breadcrumbs.length - 1;
            return ActionChip(
              label: Text(breadcrumb.label),
              visualDensity: VisualDensity.compact,
              backgroundColor: selected
                  ? theme.colorScheme.primaryContainer
                  : theme.colorScheme.surfaceContainerHighest.withAlpha(120),
              labelStyle: theme.textTheme.bodySmall?.copyWith(
                color: selected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant,
              ),
              onPressed: selected
                  ? null
                  : () => onTapPath?.call(breadcrumb.path),
            );
          },
        ),
      ),
    );
  }
}
