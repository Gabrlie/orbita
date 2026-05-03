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
        FilePathBar(
          path: _currentPath,
          onTapPath: _isMutating ? null : _loadDirectory,
        ),
        if (_error != null) _errorBanner(context),
        Expanded(child: _buildList(context, l10n, server)),
        if (_pendingEntry != null && _pendingAction != null)
          _pendingToolbar(l10n, server),
      ],
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
    final action = _pendingAction!;
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
                      ? l10n.fileCopyPending(_pendingEntry!.name)
                      : l10n.fileMovePending(_pendingEntry!.name),
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
    return PopupMenuButton<_FilesMenuAction>(
      tooltip: AppLocalizations.of(context)!.homeMoreActions,
      icon: const Icon(Ionicons.ellipsis_horizontal),
      enabled: !_isMutating,
      onSelected: (action) {
        final server = ref.read(serverByIdProvider(widget.serverId));
        if (server == null) return;
        _FilesPageActions(this)._handleMoreAction(server, action);
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: _FilesMenuAction.refresh,
          child: Text(AppLocalizations.of(context)!.commonRefresh),
        ),
        PopupMenuItem(
          value: _FilesMenuAction.newFile,
          child: Text(AppLocalizations.of(context)!.fileNewFile),
        ),
        PopupMenuItem(
          value: _FilesMenuAction.newFolder,
          child: Text(AppLocalizations.of(context)!.fileNewFolder),
        ),
        PopupMenuItem(
          value: _FilesMenuAction.root,
          child: Text(AppLocalizations.of(context)!.fileGoRoot),
        ),
      ],
    );
  }

  Widget _downloadButton() {
    return IconButton(
      tooltip: AppLocalizations.of(context)!.fileDownloadCenter,
      icon: const Icon(Ionicons.download_outline),
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => const DownloadCenterPage(),
        ),
      ),
    );
  }
}
