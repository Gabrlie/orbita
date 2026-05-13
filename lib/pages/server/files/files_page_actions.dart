part of 'files_page.dart';

enum _FilesMenuAction {
  uploadFile,
  uploadDirectory,
  refresh,
  newFile,
  newFolder,
  root,
}

enum FilePendingAction { copy, move }

enum _FileConflictAction { overwrite, keepBoth, cancel }

extension _FilesPageActions on _FilesPageState {
  void _handleMoreAction(Server server, _FilesMenuAction action) {
    switch (action) {
      case _FilesMenuAction.uploadFile:
        _FilesPageUploadActions(this)._uploadFiles(server);
      case _FilesMenuAction.uploadDirectory:
        _FilesPageUploadActions(this)._uploadDirectory(server);
      case _FilesMenuAction.refresh:
        _loadDirectory(_currentPath);
      case _FilesMenuAction.newFile:
        _createFile(server);
      case _FilesMenuAction.newFolder:
        _createDirectory(server);
      case _FilesMenuAction.root:
        _loadDirectory('/');
    }
  }

  void _openEntry(Server server, RemoteFileEntry entry) {
    if (entry.isParentLink || entry.isDirectory) {
      _loadDirectory(entry.path);
      return;
    }
    if (isLikelyTextFileName(entry.name)) {
      _openEditor(server, entry);
      return;
    }
    if (isExtractableArchiveFileName(entry.name)) {
      _FilesPageArchiveActions(this)._previewArchive(server, entry);
      return;
    }
    showInfoDialog(
      context,
      title: AppLocalizations.of(context)!.fileOpenUnsupportedTitle,
      content: AppLocalizations.of(context)!.fileOpenUnsupportedContent,
    );
  }

  void _openEditor(Server server, RemoteFileEntry entry) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => FileTextEditorPage(
          serverId: server.id,
          path: entry.path,
          fileName: entry.name,
        ),
      ),
    );
  }

  Future<void> _showEntryMenu(Server server, RemoteFileEntry entry) async {
    final action = await showFileEntryActionsDialog(
      context,
      title: entry.name,
      isArchive: isExtractableArchiveFileName(entry.name),
      canTransferToTab: widget.transferTargets.isNotEmpty,
    );
    if (action == null || !mounted) return;
    switch (action) {
      case FileEntryAction.copy:
        _setPending(server, entry, FilePendingAction.copy);
      case FileEntryAction.move:
        _setPending(server, entry, FilePendingAction.move);
      case FileEntryAction.delete:
        await _deleteEntry(server, entry);
      case FileEntryAction.rename:
        await _renameEntry(server, entry);
      case FileEntryAction.tools:
        return;
      case FileEntryAction.archive:
        isExtractableArchiveFileName(entry.name)
            ? await _FilesPageArchiveActions(this)._extractEntry(server, entry)
            : await _FilesPageArchiveActions(
                this,
              )._compressEntry(server, entry);
      case FileEntryAction.properties:
        _FilesPageArchiveActions(this)._showProperties(entry);
      case FileEntryAction.download:
        await _FilesPageArchiveActions(this)._downloadEntry(server, entry);
      case FileEntryAction.transferToTab:
        await _FilesPageTransferActions(this)._transferEntry(server, entry);
    }
  }

  void _setPending(
    Server sourceServer,
    RemoteFileEntry entry,
    FilePendingAction action,
  ) {
    _setPendingAction(sourceServer, entry, action);
  }

  Future<void> _applyPendingAction(Server server) async {
    final pending = widget.pendingTransfer;
    if (pending == null) return;

    if (pending.sourceServer.id != server.id) {
      final completed = await _applyCrossServerPending(server, pending);
      if (completed && mounted) _clearPendingAction();
      return;
    }

    final completed = await _applyPendingActionWithConflict(
      server,
      pending.entry,
      pending.action,
      overwrite: false,
      keepBoth: false,
    );
    if (!completed || !mounted) return;
    _clearPendingAction();
  }

  Future<bool> _applyCrossServerPending(
    Server targetServer,
    FilePendingTransfer pending,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    if (pending.action == FilePendingAction.move) {
      showInfoDialog(
        context,
        title: l10n.fileMove,
        content: l10n.fileMoveAcrossServersUnsupported,
      );
      return false;
    }
    if (pending.entry.isDirectory) {
      showInfoDialog(
        context,
        title: l10n.fileOpenUnsupportedTitle,
        content: l10n.fileDownloadDirectoryUnsupported,
      );
      return false;
    }
    final resolved = await _FilesPageUploadActions(this)._resolveUploadTarget(
      targetServer,
      pending.entry.name,
      remoteDirectory: _currentPath,
    );
    if (resolved == null || !mounted) return false;
    final sourceKey = await _resolveKey(pending.sourceServer);
    final targetKey = await _resolveKey(targetServer);
    await ref
        .read(fileTransferProvider.notifier)
        .addServerTransfer(
          sourceServer: pending.sourceServer,
          sourceKey: sourceKey,
          targetServer: targetServer,
          targetKey: targetKey,
          entry: pending.entry,
          targetPath: joinRemotePath(_currentPath, resolved.name),
          overwrite: resolved.overwrite,
        );
    if (!mounted) return false;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.fileTransferAdded)));
    return true;
  }

  Future<bool> _applyPendingActionWithConflict(
    Server server,
    RemoteFileEntry entry,
    FilePendingAction action, {
    required bool overwrite,
    required bool keepBoth,
  }) async {
    try {
      if (action == FilePendingAction.copy) {
        await _runMutationWithEntries(
          server,
          (service, key) => service.copyAndList(
            server,
            entry: entry,
            targetDirectory: _currentPath,
            overwrite: overwrite,
            keepBoth: keepBoth,
            listPath: _currentPath,
            key: key,
          ),
          rethrowErrors: true,
        );
      } else {
        await _runMutationWithEntries(
          server,
          (service, key) => service.moveAndList(
            server,
            entry: entry,
            targetDirectory: _currentPath,
            overwrite: overwrite,
            keepBoth: keepBoth,
            listPath: _currentPath,
            key: key,
          ),
          rethrowErrors: true,
        );
      }
      return true;
    } on SftpFileException catch (error) {
      if (error.code != 'targetExists' || overwrite || keepBoth || !mounted) {
        return false;
      }
      final choice = await _FilesPageConflictDialog(
        this,
      )._showConflictAction(entry.name);
      if (!mounted || choice == null || choice == _FileConflictAction.cancel) {
        return false;
      }
      return _applyPendingActionWithConflict(
        server,
        entry,
        action,
        overwrite: choice == _FileConflictAction.overwrite,
        keepBoth: choice == _FileConflictAction.keepBoth,
      );
    }
  }

  Future<bool> _confirmOverwrite(String name) async {
    final l10n = AppLocalizations.of(context)!;
    return showConfirmDialog(
      context,
      title: l10n.fileOverwriteTitle,
      content: l10n.fileOverwriteContent(name),
      confirmLabel: l10n.fileOverwrite,
      destructive: true,
    );
  }

  Future<bool?> _confirmOverwriteIfNeeded(Server server, String name) async {
    final service = ref.read(sftpFileServiceProvider);
    final key = await _resolveKey(server);
    final target = joinRemotePath(_currentPath, name);
    final exists = await service.exists(server, path: target, key: key);
    if (!exists) return false;
    if (!mounted) return null;
    final confirmed = await _confirmOverwrite(name);
    return confirmed ? true : null;
  }

  Future<void> _createFile(Server server) async {
    final l10n = AppLocalizations.of(context)!;
    final name = await showFileNameDialog(
      context,
      title: l10n.fileNewFile,
      label: l10n.fileName,
    );
    if (name == null) return;
    await _runMutation(
      server,
      (service, key) => service.createFile(
        server,
        parentPath: _currentPath,
        name: name,
        key: key,
      ),
    );
  }

  Future<void> _createDirectory(Server server) async {
    final l10n = AppLocalizations.of(context)!;
    final name = await showFileNameDialog(
      context,
      title: l10n.fileNewFolder,
      label: l10n.fileName,
    );
    if (name == null) return;
    await _runMutation(
      server,
      (service, key) => service.createDirectory(
        server,
        parentPath: _currentPath,
        name: name,
        key: key,
      ),
    );
  }

  Future<void> _renameEntry(Server server, RemoteFileEntry entry) async {
    final l10n = AppLocalizations.of(context)!;
    final name = await showFileNameDialog(
      context,
      title: l10n.fileRename,
      label: l10n.fileName,
      initialValue: entry.name,
    );
    if (name == null || name == entry.name) return;
    await _runMutation(
      server,
      (service, key) =>
          service.rename(server, path: entry.path, nextName: name, key: key),
    );
  }

  Future<void> _deleteEntry(Server server, RemoteFileEntry entry) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.fileDeleteTitle,
      content: entry.isDirectory
          ? l10n.fileDeleteDirectoryContent(entry.name)
          : l10n.fileDeleteFileContent(entry.name),
      confirmLabel: l10n.commonDelete,
      destructive: true,
    );
    if (!confirmed) return;
    await _runMutationWithEntries(
      server,
      (service, key) => service.deleteAndList(
        server,
        entry: entry,
        listPath: _currentPath,
        key: key,
      ),
    );
  }

  String _messageForError(Object error) {
    final l10n = AppLocalizations.of(context)!;
    if (error is SftpFileException) {
      return switch (error.code) {
        'tooLarge' => l10n.fileTooLarge,
        'binary' => l10n.fileBinaryUnsupported,
        'invalidTarget' => l10n.fileInvalidTarget,
        'deleteFailed' => l10n.fileDeleteFailed,
        'commandFailed' => error.details ?? l10n.fileCommandFailed,
        _ => '$error',
      };
    }
    if (error is ArgumentError) {
      return l10n.fileInvalidName;
    }
    return '$error';
  }
}
