import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/widgets/orbita_forui.dart';

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
  return showOrbitaBottomSheet<void>(
    context: context,
    mainAxisMaxRatio: null,
    builder: (ctx) {
      final l10n = AppLocalizations.of(ctx)!;
      final theme = Theme.of(ctx);
      final disabledColor = theme.colorScheme.onSurface.withAlpha(97);

      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const FDivider(),
            for (final item in items)
              FItem(
                prefix: Icon(
                  item.icon,
                  size: 20,
                  color: item.wip
                      ? disabledColor
                      : item.destructive
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary,
                ),
                title: Text(
                  item.wip
                      ? '${item.label} (${l10n.inDevelopment})'
                      : item.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: item.wip
                        ? disabledColor
                        : item.destructive
                        ? theme.colorScheme.error
                        : theme.colorScheme.onSurface,
                  ),
                ),
                onPress: item.wip
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
