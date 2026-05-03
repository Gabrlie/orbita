import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';

enum FileEntryAction {
  copy,
  move,
  delete,
  rename,
  tools,
  archive,
  properties,
  download,
}

Future<FileEntryAction?> showFileEntryActionsDialog(
  BuildContext context, {
  required String title,
  required bool isArchive,
}) {
  return showDialog<FileEntryAction>(
    context: context,
    builder: (context) {
      final l10n = AppLocalizations.of(context)!;
      return Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 14),
                Row(
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
                            FileEntryAction.tools,
                            Ionicons.construct_outline,
                            l10n.fileTools,
                            enabled: false,
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
              ],
            ),
          ),
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

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: action.enabled
          ? () => Navigator.of(context).pop(action.action)
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          children: [
            Icon(action.icon, size: 20, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                action.label,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(color: color),
              ),
            ),
          ],
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
