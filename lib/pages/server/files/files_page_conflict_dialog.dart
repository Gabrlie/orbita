part of 'files_page.dart';

extension _FilesPageConflictDialog on _FilesPageState {
  Future<_FileConflictAction> _resolveConflictAction(String name) async {
    switch (ref.read(transferSettingsProvider).duplicateAction) {
      case TransferDuplicateAction.overwrite:
        return _FileConflictAction.overwrite;
      case TransferDuplicateAction.keepBoth:
        return _FileConflictAction.keepBoth;
      case TransferDuplicateAction.cancel:
        return _FileConflictAction.cancel;
      case TransferDuplicateAction.ask:
        final choice = await _showConflictAction(name);
        return choice ?? _FileConflictAction.cancel;
    }
  }

  Future<_FileConflictAction?> _showConflictAction(String name) async {
    final l10n = AppLocalizations.of(context)!;
    return showOrbitaDialog<_FileConflictAction>(
      context: context,
      builder: (context, animation) => OrbitaDialog(
        animation: animation,
        title: l10n.fileOverwriteTitle,
        actions: [
          OrbitaDialogAction(
            label: l10n.commonCancel,
            variant: FButtonVariant.ghost,
            onPress: () =>
                Navigator.of(context).pop(_FileConflictAction.cancel),
          ),
          OrbitaDialogAction(
            label: l10n.fileKeepBoth,
            variant: FButtonVariant.outline,
            onPress: () =>
                Navigator.of(context).pop(_FileConflictAction.keepBoth),
          ),
          OrbitaDialogAction(
            label: l10n.fileOverwrite,
            onPress: () =>
                Navigator.of(context).pop(_FileConflictAction.overwrite),
          ),
        ],
        child: Text(l10n.fileOverwriteContent(name)),
      ),
    );
  }
}
