part of 'files_page.dart';

extension _FilesPageTransferActions on _FilesPageState {
  Future<void> _transferEntry(
    Server sourceServer,
    RemoteFileEntry entry,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    if (entry.isDirectory) {
      showInfoDialog(
        context,
        title: l10n.fileOpenUnsupportedTitle,
        content: l10n.fileDownloadDirectoryUnsupported,
      );
      return;
    }
    if (widget.transferTargets.isEmpty) {
      showInfoDialog(
        context,
        title: l10n.fileTransferCenter,
        content: l10n.fileServerMissingSubtitle,
      );
      return;
    }
    final target = await _pickTarget();
    if (target == null || !mounted) return;
    final resolved = await _FilesPageUploadActions(this)._resolveUploadTarget(
      target.server,
      entry.name,
      remoteDirectory: target.path,
    );
    if (resolved == null || !mounted) return;
    final sourceKey = await _resolveKey(sourceServer);
    final targetKey = await _resolveKey(target.server);
    await ref
        .read(fileTransferProvider.notifier)
        .addServerTransfer(
          sourceServer: sourceServer,
          sourceKey: sourceKey,
          targetServer: target.server,
          targetKey: targetKey,
          entry: entry,
          targetPath: joinRemotePath(target.path, resolved.name),
          overwrite: resolved.overwrite,
        );
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.fileTransferAdded)));
  }

  Future<FileTransferTarget?> _pickTarget() {
    return showModalBottomSheet<FileTransferTarget>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: Text(
                  l10n.fileTransferCenter,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              for (final target in widget.transferTargets)
                ListTile(
                  leading: const Icon(Ionicons.folder_open_outline),
                  title: Text(target.server.name),
                  subtitle: Text(
                    target.path,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => Navigator.of(context).pop(target),
                ),
            ],
          ),
        );
      },
    );
  }
}
