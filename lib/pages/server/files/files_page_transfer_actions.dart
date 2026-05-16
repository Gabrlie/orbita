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
    final useLocalRelay = await _shouldUseLocalRelay(
      sourceServer,
      target.server,
    );
    if (useLocalRelay == null) return;
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
          useLocalRelay: useLocalRelay,
        );
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.fileTransferAdded)));
  }

  Future<bool?> _shouldUseLocalRelay(
    Server sourceServer,
    Server targetServer,
  ) async {
    final settings = ref.read(transferSettingsProvider);
    switch (settings.toolPreference) {
      case TransferToolPreference.localRelay:
        return true;
      case TransferToolPreference.rsync:
        return await _ensureServerTransferTools(sourceServer, targetServer)
            ? false
            : null;
      case TransferToolPreference.auto:
        final ready = await _hasServerTransferTools(sourceServer, targetServer);
        return !ready;
    }
  }

  Future<bool> _hasServerTransferTools(
    Server sourceServer,
    Server targetServer,
  ) async {
    return await _hasTransferTools(targetServer, const [
          'ssh',
          'ssh-keygen',
          'rsync',
        ]) &&
        mounted &&
        await _hasTransferTools(sourceServer, const ['rsync']);
  }

  Future<bool> _hasTransferTools(Server server, List<String> tools) async {
    final service = ref.read(sftpFileServiceProvider);
    final key = await _resolveKey(server);
    final missing = await service.missingTools(server, tools: tools, key: key);
    return missing.isEmpty;
  }

  Future<bool> _ensureServerTransferTools(
    Server sourceServer,
    Server targetServer,
  ) async {
    if (!await _ensureTransferTools(targetServer, const [
      'ssh',
      'ssh-keygen',
      'rsync',
    ])) {
      return false;
    }
    if (!mounted) return false;
    return _ensureTransferTools(sourceServer, const ['rsync']);
  }

  Future<bool> _ensureTransferTools(Server server, List<String> tools) async {
    final l10n = AppLocalizations.of(context)!;
    final service = ref.read(sftpFileServiceProvider);
    final key = await _resolveKey(server);
    final missing = await service.missingTools(server, tools: tools, key: key);
    if (missing.isEmpty) return true;
    if (!mounted) return false;
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.fileMissingToolsTitle,
      content:
          '${server.name}: ${l10n.fileMissingToolsContent(missing.join(', '))}',
      confirmLabel: l10n.fileInstallTools,
    );
    if (!confirmed || !mounted) return false;
    final success = await showOrbitaDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context, animation) => FileToolInstallDialog(
        tools: missing,
        animation: animation,
        onInstall: (onOutput) => service.installToolsWithOutput(
          server,
          tools: missing,
          key: key,
          onOutput: onOutput,
        ),
      ),
    );
    return success ?? false;
  }

  Future<FileTransferTarget?> _pickTarget() {
    return showOrbitaBottomSheet<FileTransferTarget>(
      context: context,
      mainAxisMaxRatio: null,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Text(
                l10n.fileTransferCenter,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            for (final target in widget.transferTargets)
              FItem(
                prefix: const Icon(Ionicons.folder_open_outline),
                title: Text(target.server.name),
                subtitle: Text(
                  target.path,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onPress: () => Navigator.of(context).pop(target),
              ),
          ],
        );
      },
    );
  }
}
