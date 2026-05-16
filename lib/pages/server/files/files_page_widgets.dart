part of 'files_page.dart';

extension _FilesPageWidgets on _FilesPageState {
  Widget _buildContent(
    BuildContext context,
    AppLocalizations l10n,
    Server? server,
  ) {
    if (server == null) {
      return EmptyState(
        icon: Ionicons.warning_outline,
        title: l10n.fileServerMissing,
        subtitle: l10n.fileServerMissingSubtitle,
      );
    }

    return Column(
      children: [
        if (widget.showAppBar)
          FilePathBar(
            path: _currentPath,
            onTapPath: _isMutating ? null : _loadDirectory,
          ),
        if (_error != null) _errorBanner(context),
        Expanded(child: _buildList(context, l10n, server)),
        if (widget.pendingTransfer != null) _pendingToolbar(l10n, server),
      ],
    );
  }

  Widget _inlineToolbar() {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surface,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
        ),
        child: Row(
          children: [
            Expanded(
              child: FilePathBar(
                path: _currentPath,
                backgroundColor: Colors.transparent,
                onTapPath: _isMutating ? null : _loadDirectory,
              ),
            ),
            _downloadButton(),
            _refreshButton(),
            _moreButton(),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _errorBanner(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.errorContainer,
      child: ListTile(
        dense: true,
        leading: Icon(
          Ionicons.warning_outline,
          color: colorScheme.onErrorContainer,
        ),
        title: Text(
          _error!,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: colorScheme.onErrorContainer),
        ),
      ),
    );
  }

  Widget _pendingToolbar(AppLocalizations l10n, Server server) {
    final pending = widget.pendingTransfer!;
    final action = pending.action;
    return Material(
      elevation: 8,
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  action == FilePendingAction.copy
                      ? l10n.fileCopyPending(pending.entry.name)
                      : l10n.fileMovePending(pending.entry.name),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: _clearPendingAction,
                child: Text(l10n.commonCancel),
              ),
              FilledButton(
                onPressed: _isMutating
                    ? null
                    : () => _FilesPageActions(this)._applyPendingAction(server),
                child: Text(
                  action == FilePendingAction.copy
                      ? l10n.filePaste
                      : l10n.fileMove,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    AppLocalizations l10n,
    Server server,
  ) {
    if (_isLoading && _entries.isEmpty) return _loadingView(l10n);
    final parent = createParentRemoteEntry(_currentPath);
    final entries = parent == null ? _entries : [parent, ..._entries];
    if (entries.isEmpty) return _emptyList(context, l10n);
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () => _loadDirectory(_currentPath),
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: entries.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final entry = entries[index];
              return FileEntryTile(
                entry: entry,
                onTap: _isMutating || _isLoading
                    ? null
                    : () => _FilesPageActions(this)._openEntry(server, entry),
                onLongPress: entry.isParentLink || _isMutating || _isLoading
                    ? null
                    : () =>
                          _FilesPageActions(this)._showEntryMenu(server, entry),
              );
            },
          ),
        ),
        if (_isLoading) _listLoadingOverlay(),
      ],
    );
  }

  Widget _listLoadingOverlay() {
    final colorScheme = Theme.of(context).colorScheme;
    return Positioned.fill(
      child: IgnorePointer(
        child: ColoredBox(
          color: colorScheme.surface.withAlpha(150),
          child: const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  Widget _loadingView(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(l10n.fileLoadingDirectory),
        ],
      ),
    );
  }

  Widget _emptyList(BuildContext context, AppLocalizations l10n) {
    return RefreshIndicator(
      onRefresh: () => _loadDirectory(_currentPath),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.24),
          EmptyState(
            icon: Ionicons.folder_open_outline,
            title: l10n.fileEmptyDirectory,
          ),
        ],
      ),
    );
  }

  Widget _refreshButton() {
    return IconButton(
      tooltip: AppLocalizations.of(context)!.commonRefresh,
      icon: const Icon(Ionicons.refresh_outline),
      onPressed: _isMutating ? null : () => _loadDirectory(_currentPath),
    );
  }

  Widget _moreButton() {
    final l10n = AppLocalizations.of(context)!;
    return OrbitaIconMenuButton<_FilesMenuAction>(
      tooltip: l10n.homeMoreActions,
      icon: Ionicons.ellipsis_horizontal,
      enabled: !_isMutating,
      title: l10n.homeMoreActions,
      onSelected: (action) {
        final server = ref.read(serverByIdProvider(widget.serverId));
        if (server == null) return;
        _FilesPageActions(this)._handleMoreAction(server, action);
      },
      actions: [
        OrbitaMenuAction(
          value: _FilesMenuAction.uploadFile,
          icon: Ionicons.cloud_upload_outline,
          label: l10n.fileUploadFile,
        ),
        OrbitaMenuAction(
          value: _FilesMenuAction.uploadDirectory,
          icon: Ionicons.folder_open_outline,
          label: l10n.fileUploadDirectory,
        ),
        OrbitaMenuAction(
          value: _FilesMenuAction.refresh,
          icon: Ionicons.refresh_outline,
          label: l10n.commonRefresh,
          dividerBefore: true,
        ),
        OrbitaMenuAction(
          value: _FilesMenuAction.newFile,
          icon: Ionicons.document_outline,
          label: l10n.fileNewFile,
        ),
        OrbitaMenuAction(
          value: _FilesMenuAction.newFolder,
          icon: Ionicons.folder_outline,
          label: l10n.fileNewFolder,
        ),
        OrbitaMenuAction(
          value: _FilesMenuAction.root,
          icon: Ionicons.home_outline,
          label: l10n.fileGoRoot,
        ),
      ],
    );
  }

  Widget _downloadButton() {
    return IconButton(
      tooltip: AppLocalizations.of(context)!.fileTransferCenter,
      icon: const Icon(Ionicons.swap_vertical_outline),
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => const TransferCenterPage(),
        ),
      ),
    );
  }
}
