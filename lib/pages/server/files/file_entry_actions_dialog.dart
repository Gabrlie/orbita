import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/widgets/orbita_forui.dart';

enum FileEntryAction {
  copy,
  move,
  delete,
  rename,
  tools,
  archive,
  properties,
  download,
  transferToTab,
}

Future<FileEntryAction?> showFileEntryActionsDialog(
  BuildContext context, {
  required String title,
  required bool isArchive,
  required bool canTransferToTab,
}) {
  return showOrbitaDialog<FileEntryAction>(
    context: context,
    builder: (context, animation) {
      final l10n = AppLocalizations.of(context)!;
      return OrbitaDialog(
        animation: animation,
        title: l10n.homeMoreActions,
        constraints: const BoxConstraints(minWidth: 280, maxWidth: 420),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _ActionColumn(
                actions: [
                  _DialogAction(
                    FileEntryAction.copy,
                    Ionicons.copy_outline,
                    l10n.fileCopy,
                  ),
                  _DialogAction(
                    FileEntryAction.delete,
                    Ionicons.trash_outline,
                    l10n.commonDelete,
                    destructive: true,
                  ),
                  _DialogAction(
                    FileEntryAction.transferToTab,
                    Ionicons.swap_horizontal_outline,
                    l10n.fileTransferCenter,
                    enabled: canTransferToTab,
                  ),
                  _DialogAction(
                    FileEntryAction.properties,
                    Ionicons.information_circle_outline,
                    l10n.fileProperties,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ActionColumn(
                actions: [
                  _DialogAction(
                    FileEntryAction.move,
                    Ionicons.move_outline,
                    l10n.fileMove,
                  ),
                  _DialogAction(
                    FileEntryAction.rename,
                    Ionicons.create_outline,
                    l10n.fileRename,
                  ),
                  _DialogAction(
                    FileEntryAction.archive,
                    isArchive
                        ? Ionicons.file_tray_outline
                        : Ionicons.archive_outline,
                    isArchive ? l10n.fileExtract : l10n.fileCompress,
                  ),
                  _DialogAction(
                    FileEntryAction.download,
                    Ionicons.download_outline,
                    l10n.fileDownload,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _ActionColumn extends StatelessWidget {
  final List<_DialogAction> actions;

  const _ActionColumn({required this.actions});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final action in actions)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _ActionButton(action: action),
          ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final _DialogAction action;

  const _ActionButton({required this.action});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = action.destructive
        ? theme.colorScheme.error
        : action.enabled
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant.withAlpha(120);

    return FButton(
      variant: action.destructive
          ? FButtonVariant.destructive
          : FButtonVariant.ghost,
      mainAxisSize: MainAxisSize.max,
      onPress: action.enabled
          ? () => Navigator.of(context).pop(action.action)
          : null,
      prefix: Icon(action.icon, size: 20, color: color),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          action.label,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(color: color),
        ),
      ),
    );
  }
}

class _DialogAction {
  final FileEntryAction action;
  final IconData icon;
  final String label;
  final bool enabled;
  final bool destructive;

  const _DialogAction(
    this.action,
    this.icon,
    this.label, {
    this.enabled = true,
    this.destructive = false,
  });
}
