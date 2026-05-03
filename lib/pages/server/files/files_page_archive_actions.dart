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
    final password = await showExtractPasswordDialog(context);
    if (password == null) return;
    final tools = extractRequiredTools(entry.name);
    if (!await _ensureTools(server, tools)) return;
    await _runMutation(
      server,
      (service, key) => service.extract(
        server,
        entry: entry,
        password: password.isEmpty ? null : password,
        key: key,
      ),
    );
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
    final success = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => FileToolInstallDialog(
        tools: missing,
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
    final key = await _resolveKey(server);
    await ref.read(fileDownloadProvider.notifier).add(server, key, entry);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.fileDownloadAdded)),
    );
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
