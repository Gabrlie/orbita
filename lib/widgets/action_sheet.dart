import 'package:flutter/material.dart';

/// A single action item for [showActionSheet].
class ActionSheetItem {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  /// Whether this feature is not yet implemented.
  /// Shows a dimmed style with "(开发中)" / "(WIP)" suffix.
  final bool wip;

  /// Destructive actions are shown in error color.
  final bool destructive;

  const ActionSheetItem({
    required this.icon,
    required this.label,
    this.onTap,
    this.wip = false,
    this.destructive = false,
  });
}

/// Show a reusable bottom-sheet action menu.
///
/// [title] is displayed as the sheet header.
/// [items] is the list of actions to display.
Future<void> showActionSheet(
  BuildContext context, {
  required String title,
  required List<ActionSheetItem> items,
}) {
  return showModalBottomSheet(
    context: context,
    builder: (ctx) {
      final theme = Theme.of(ctx);
      final disabledColor = theme.colorScheme.onSurface.withAlpha(97);

      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(title, style: theme.textTheme.titleMedium),
            ),
            const Divider(height: 1),
            for (final item in items)
              ListTile(
                leading: Icon(
                  item.icon,
                  color: item.wip
                      ? disabledColor
                      : item.destructive
                          ? theme.colorScheme.error
                          : null,
                ),
                title: Text(
                  item.wip ? '${item.label}（开发中）' : item.label,
                  style: TextStyle(
                    color: item.wip
                        ? disabledColor
                        : item.destructive
                            ? theme.colorScheme.error
                            : null,
                  ),
                ),
                onTap: item.wip
                    ? null
                    : () {
                        Navigator.pop(ctx);
                        item.onTap?.call();
                      },
              ),
          ],
        ),
      );
    },
  );
}
