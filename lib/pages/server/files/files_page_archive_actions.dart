part of 'files_page.dart';

extension _FilesPageArchiveActions on _FilesPageState {
  Future<void> _previewArchive(Server server, RemoteFileEntry entry) async {
    final tools = previewArchiveRequiredTools(entry.name);
    if (!await _ensureTools(server, tools)) return;
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) =>
            ArchivePreviewPage(serverId: server.id, entry: entry),
      ),
    );
  }

  Future<void> _compressEntry(Server server, RemoteFileEntry entry) async {
    final options = await showCompressDialog(context);
    if (options == null) return;
    final targetName = archiveTargetName(entry.name, options.format);
    final overwrite = await _FilesPageActions(
      this,
    )._confirmOverwriteIfNeeded(server, targetName);
    if (overwrite == null) return;
    final tools = compressRequiredTools(
      options.format,
      password: options.password,
    );
    if (!await _ensureTools(server, tools)) return;
    await _runMutation(
      server,
      (service, key) => service.compress(
        server,
        entry: entry,
        format: options.format,
        password: options.password,
        overwrite: overwrite,
        key: key,
      ),
    );
  }

  Future<void> _extractEntry(Server server, RemoteFileEntry entry) async {
    final tools = extractRequiredTools(entry.name);
    if (!await _ensureTools(server, tools)) return;
    try {
      await _runMutationWithEntries(
        server,
        (service, key) => service.extractAndList(
          server,
          entry: entry,
          listPath: _currentPath,
          key: key,
        ),
        rethrowErrors: true,
      );
      return;
    } catch (error) {
      if (!mounted || !_shouldPromptExtractPassword(entry, error)) return;
    }

    // ignore: use_build_context_synchronously
    final password = await showExtractPasswordDialog(context);
    if (password == null || !mounted) return;
    await _runMutationWithEntries(
      server,
      (service, key) => service.extractAndList(
        server,
        entry: entry,
        listPath: _currentPath,
        password: password.trim().isEmpty ? null : password,
        key: key,
      ),
    );
  }

  bool _shouldPromptExtractPassword(RemoteFileEntry entry, Object error) {
    if (!entry.name.trim().toLowerCase().endsWith('.zip')) return false;
    final message = error.toString().toLowerCase();
    return message.contains('password') ||
        message.contains('encrypted') ||
        message.contains('incorrect');
  }

  Future<bool> _ensureTools(Server server, List<String> tools) async {
    final l10n = AppLocalizations.of(context)!;
    final service = ref.read(sftpFileServiceProvider);
    final key = await _resolveKey(server);
    final missing = await service.missingTools(server, tools: tools, key: key);
    if (missing.isEmpty) return true;
    if (!mounted) return false;
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.fileMissingToolsTitle,
      content: l10n.fileMissingToolsContent(missing.join(', ')),
      confirmLabel: l10n.fileInstallTools,
    );
    if (!confirmed) return false;
    if (!mounted) return false;
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

  Future<void> _downloadEntry(Server server, RemoteFileEntry entry) async {
    if (entry.isDirectory) {
      showInfoDialog(
        context,
        title: AppLocalizations.of(context)!.fileOpenUnsupportedTitle,
        content: AppLocalizations.of(context)!.fileDownloadDirectoryUnsupported,
      );
      return;
    }
    final localPath = await _resolveDownloadLocalPath(server, entry);
    if (localPath == null) return;
    final key = await _resolveKey(server);
    final added = await ref
        .read(fileTransferProvider.notifier)
        .addDownload(server, key, entry, localPath: localPath);
    if (!added) return;
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.fileTransferAdded)),
    );
  }

  Future<String?> _resolveDownloadLocalPath(
    Server server,
    RemoteFileEntry entry,
  ) async {
    final settings = ref.read(transferSettingsProvider);
    final initialDirectory = settings.downloadDirectory.trim().isEmpty
        ? null
        : settings.downloadDirectory.trim();
    if (settings.askDownloadLocation) {
      final selected = await FilePicker.saveFile(
        dialogTitle: AppLocalizations.of(context)!.transferDownloadSaveAs,
        fileName: entry.name,
        initialDirectory: initialDirectory,
      );
      if (selected == null || selected.isEmpty) return null;
      await _deleteExistingLocalFile(selected);
      return selected;
    }

    final directory = await _downloadDirectoryFor(server, settings);
    await directory.create(recursive: true);
    final safeName = _safeLocalFileName(entry.name);
    var candidate = File('${directory.path}${Platform.pathSeparator}$safeName');
    if (await candidate.exists()) {
      final action = await _resolveDuplicateDownloadAction(
        settings,
        entry.name,
      );
      if (action == null || action == TransferDuplicateAction.cancel) {
        return null;
      }
      if (action == TransferDuplicateAction.overwrite) {
        await _deleteExistingLocalFile(candidate.path);
        return candidate.path;
      }
      var index = 1;
      do {
        candidate = File(
          '${directory.path}${Platform.pathSeparator}'
          '${duplicateRemoteEntryName(safeName, index)}',
        );
        index += 1;
      } while (await candidate.exists());
    }
    return candidate.path;
  }

  Future<TransferDuplicateAction?> _resolveDuplicateDownloadAction(
    TransferSettings settings,
    String name,
  ) async {
    if (settings.duplicateAction != TransferDuplicateAction.ask) {
      return settings.duplicateAction;
    }
    if (!mounted) return null;
    final choice = await _FilesPageConflictDialog(
      this,
    )._showConflictAction(name);
    return switch (choice) {
      _FileConflictAction.overwrite => TransferDuplicateAction.overwrite,
      _FileConflictAction.keepBoth => TransferDuplicateAction.keepBoth,
      _FileConflictAction.cancel || null => TransferDuplicateAction.cancel,
    };
  }

  Future<Directory> _downloadDirectoryFor(
    Server server,
    TransferSettings settings,
  ) async {
    final configured = settings.downloadDirectory.trim();
    if (configured.isNotEmpty) return Directory(configured);
    final base = await _defaultDownloadRootDirectory();
    return Directory(
      '${base.path}${Platform.pathSeparator}Orbite'
      '${Platform.pathSeparator}${_safeLocalFileName(server.name)}',
    );
  }

  Future<Directory> _defaultDownloadRootDirectory() async {
    if (Platform.isAndroid) {
      final publicDownloads = Directory('/storage/emulated/0/Download');
      if (await publicDownloads.exists()) return publicDownloads;
    }
    return await getDownloadsDirectory() ??
        await getApplicationDocumentsDirectory();
  }

  Future<void> _deleteExistingLocalFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }

  String _safeLocalFileName(String name) {
    final safe = name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
    return safe.isEmpty ? 'download' : safe;
  }

  void _showProperties(RemoteFileEntry entry) {
    final l10n = AppLocalizations.of(context)!;
    showInfoDialog(
      context,
      title: l10n.fileProperties,
      content: [
        '${l10n.fileName}: ${entry.name}',
        '${l10n.filePath}: ${entry.path}',
        '${l10n.fileType}: ${entry.kind.name}',
        '${l10n.fileSize}: ${entry.size}',
        if (entry.mode != null) '${l10n.fileMode}: ${entry.mode}',
        if (entry.modifiedAt != null)
          '${l10n.fileModified}: ${entry.modifiedAt!.toLocal()}',
      ].join('\n'),
    );
  }
}
