part of 'files_page.dart';

extension _FilesPageConflictDialog on _FilesPageState {
  Future<_FileConflictAction?> _showConflictAction(String name) async {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<_FileConflictAction>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          l10n.fileOverwriteTitle,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        content: Text(l10n.fileOverwriteContent(name)),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(_FileConflictAction.cancel),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(_FileConflictAction.keepBoth),
            child: Text(l10n.fileKeepBoth),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(context).pop(_FileConflictAction.overwrite),
            child: Text(l10n.fileOverwrite),
          ),
        ],
      ),
    );
  }
}
