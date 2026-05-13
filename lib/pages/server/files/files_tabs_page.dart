import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/pages/server/files/files_page.dart';
import 'package:orbita/providers/navigation_reset_provider.dart';
import 'package:orbita/providers/server_provider.dart';
import 'package:orbita/widgets/server_picker_list.dart';
import 'package:orbita/widgets/server_tabs_scaffold.dart';

class FilesTabsPage extends ConsumerStatefulWidget {
  final String? initialServerId;

  const FilesTabsPage({super.key, this.initialServerId});

  @override
  ConsumerState<FilesTabsPage> createState() => _FilesTabsPageState();
}

class _FilesTabsPageState extends ConsumerState<FilesTabsPage> {
  final _tabs = <_FilesTab>[];
  var _selectedIndex = 0;
  var _nextTabId = 0;
  String? _handledInitialServerId;
  FilePendingTransfer? _pendingTransfer;

  @override
  void initState() {
    super.initState();
    _tabs.add(_newTab(serverId: widget.initialServerId));
    _handledInitialServerId = widget.initialServerId;
  }

  @override
  void didUpdateWidget(covariant FilesTabsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final initialServerId = widget.initialServerId;
    if (initialServerId != null && initialServerId != _handledInitialServerId) {
      _openServerTab(initialServerId);
      _handledInitialServerId = initialServerId;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(navigationBranchResetProvider(1), (_, _) => _resetTabs());
    final l10n = AppLocalizations.of(context)!;

    return ServerTabsScaffold(
      tabs: [
        for (final tab in _tabs)
          ServerTabItem(
            title: _tabTitle(tab, l10n),
            isNew: tab.serverId == null,
          ),
      ],
      selectedIndex: _selectedIndex,
      onSelectTab: (index) => setState(() => _selectedIndex = index),
      onCloseTab: _closeTab,
      onAddTab: _addTab,
      hideOnScroll: true,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          for (var index = 0; index < _tabs.length; index++)
            _buildTabBody(index),
        ],
      ),
    );
  }

  Widget _buildTabBody(int index) {
    final tab = _tabs[index];
    final serverId = tab.serverId;
    if (serverId == null) {
      return ServerPickerList(
        key: ValueKey(tab.id),
        emptyIcon: Ionicons.folder,
        onSelected: (server) => _assignServer(server.id),
      );
    }
    return FilesPage(
      key: ValueKey(tab.id),
      serverId: serverId,
      showAppBar: false,
      initialPath: tab.path,
      transferTargets: _transferTargetsFor(index),
      pendingTransfer: _pendingTransfer,
      onPathChanged: (path) => _updateTabPath(tab.id, path),
      onPendingTransferChanged: (server, entry, action) {
        setState(() {
          _pendingTransfer = FilePendingTransfer(
            sourceTabId: tab.id,
            sourceServer: server,
            entry: entry,
            action: action,
          );
        });
      },
      onPendingTransferCleared: () => setState(() => _pendingTransfer = null),
    );
  }

  _FilesTab _newTab({String? serverId}) {
    return _FilesTab(
      id: 'files-tab-${_nextTabId++}',
      serverId: serverId,
      path: '/',
    );
  }

  String _tabTitle(_FilesTab tab, AppLocalizations l10n) {
    final serverId = tab.serverId;
    if (serverId == null) return l10n.newTab;
    return ref.watch(serverByIdProvider(serverId))?.name ??
        l10n.fileServerMissing;
  }

  void _assignServer(String serverId) {
    setState(() {
      _tabs[_selectedIndex] = _tabs[_selectedIndex].copyWith(
        serverId: serverId,
        path: '/',
      );
    });
  }

  void _openServerTab(String serverId) {
    final existingIndex = _tabs.indexWhere((tab) => tab.serverId == serverId);
    setState(() {
      if (existingIndex >= 0) {
        _selectedIndex = existingIndex;
      } else if (_tabs[_selectedIndex].serverId == null) {
        _tabs[_selectedIndex] = _tabs[_selectedIndex].copyWith(
          serverId: serverId,
          path: '/',
        );
      } else {
        _tabs.add(_newTab(serverId: serverId));
        _selectedIndex = _tabs.length - 1;
      }
    });
  }

  void _addTab() {
    setState(() {
      _tabs.add(_newTab());
      _selectedIndex = _tabs.length - 1;
    });
  }

  void _updateTabPath(String tabId, String path) {
    final index = _tabs.indexWhere((tab) => tab.id == tabId);
    if (index < 0 || _tabs[index].path == path) return;
    setState(() => _tabs[index] = _tabs[index].copyWith(path: path));
  }

  List<FileTransferTarget> _transferTargetsFor(int sourceIndex) {
    final targets = <FileTransferTarget>[];
    for (var index = 0; index < _tabs.length; index++) {
      if (index == sourceIndex) continue;
      final tab = _tabs[index];
      final serverId = tab.serverId;
      if (serverId == null) continue;
      final server = ref.watch(serverByIdProvider(serverId));
      if (server == null) continue;
      targets.add(
        FileTransferTarget(tabId: tab.id, server: server, path: tab.path),
      );
    }
    return targets;
  }

  void _resetTabs() {
    if (!mounted) return;
    setState(() {
      _tabs
        ..clear()
        ..add(_newTab());
      _selectedIndex = 0;
      _handledInitialServerId = null;
      _pendingTransfer = null;
    });
  }

  void _closeTab(int index) {
    setState(() {
      final removedTab = _tabs[index];
      if (_tabs.length == 1) {
        _tabs[0] = _newTab();
        _selectedIndex = 0;
        if (_pendingTransfer?.sourceTabId == removedTab.id) {
          _pendingTransfer = null;
        }
        return;
      }
      _tabs.removeAt(index);
      if (_pendingTransfer?.sourceTabId == removedTab.id) {
        _pendingTransfer = null;
      }
      if (_selectedIndex >= _tabs.length) {
        _selectedIndex = _tabs.length - 1;
      } else if (index < _selectedIndex) {
        _selectedIndex--;
      }
    });
  }
}

class _FilesTab {
  final String id;
  final String? serverId;
  final String path;

  const _FilesTab({required this.id, required this.path, this.serverId});

  _FilesTab copyWith({String? serverId, String? path}) {
    return _FilesTab(
      id: id,
      serverId: serverId ?? this.serverId,
      path: path ?? this.path,
    );
  }
}
