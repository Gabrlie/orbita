part of 'files_page.dart';

extension _FilesPageUploadActions on _FilesPageState {
  Future<({String name, bool overwrite})?> _resolveUploadTarget(
    Server server,
    String name, {
    String? remoteDirectory,
  }) async {
    final directory = remoteDirectory ?? _currentPath;
    var targetName = name;
    var overwrite = false;
    final service = ref.read(sftpFileServiceProvider);
    final key = await _resolveKey(server);
    final exists = await service.exists(
      server,
      path: joinRemotePath(directory, targetName),
      key: key,
    );
    if (!exists) return (name: targetName, overwrite: overwrite);
    if (!mounted) return null;
    final choice = await _FilesPageConflictDialog(
      this,
    )._showConflictAction(name);
    if (!mounted || choice == null || choice == _FileConflictAction.cancel) {
      return null;
    }
    if (choice == _FileConflictAction.overwrite) {
      overwrite = true;
    } else {
      var index = 1;
      do {
        targetName = duplicateRemoteEntryName(name, index);
        index += 1;
      } while (await service.exists(
        server,
        path: joinRemotePath(directory, targetName),
        key: key,
      ));
    }
    return (name: targetName, overwrite: overwrite);
  }

  Future<void> _uploadFiles(Server server) async {
    final result = await FilePicker.pickFiles(allowMultiple: true);
    if (result == null || result.files.isEmpty) return;
    final key = await _resolveKey(server);
    for (final picked in result.files) {
      final path = picked.path;
      if (path == null || path.isEmpty) continue;
      final target = await _resolveUploadTarget(server, picked.name);
      if (target == null) continue;
      await ref
          .read(fileTransferProvider.notifier)
          .addFileUpload(
            server,
            key,
            localPath: path,
            remotePath: joinRemotePath(_currentPath, target.name),
            overwrite: target.overwrite,
          );
    }
    _showUploadAdded();
  }

  Future<void> _uploadDirectory(Server server) async {
    final path = await FilePicker.getDirectoryPath();
    if (path == null || path.isEmpty) return;
    if (!await _FilesPageArchiveActions(
      this,
    )._ensureTools(server, const ['tar', 'sha256sum'])) {
      return;
    }
    final name = path
        .split(RegExp(r'[\\/]'))
        .where((part) => part.trim().isNotEmpty)
        .lastOrNull;
    if (name == null) return;
    final target = await _resolveUploadTarget(server, name);
    if (target == null) return;
    final key = await _resolveKey(server);
    await ref
        .read(fileTransferProvider.notifier)
        .addDirectoryUpload(
          server,
          key,
          directoryPath: Directory(path).path,
          remoteDirectory: _currentPath,
          rootName: target.name,
          overwrite: target.overwrite,
        );
    _showUploadAdded();
  }

  void _showUploadAdded() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.fileUploadAdded)),
    );
  }
}
