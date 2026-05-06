import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/pages/server/docker/docker_manager_page.dart';
import 'package:orbita/providers/docker_provider.dart';
import 'package:orbita/providers/navigation_reset_provider.dart';
import 'package:orbita/providers/server_provider.dart';
import 'package:orbita/widgets/server_picker_list.dart';
import 'package:orbita/widgets/server_tabs_scaffold.dart';

class DockerPage extends ConsumerStatefulWidget {
  final String? initialServerId;

  const DockerPage({super.key, this.initialServerId});

  @override
  ConsumerState<DockerPage> createState() => _DockerPageState();
}

class _DockerPageState extends ConsumerState<DockerPage> {
  final _tabs = <_DockerTab>[];
  var _selectedIndex = 0;
  var _nextTabId = 0;
  String? _handledInitialServerId;

  @override
  void initState() {
    super.initState();
    _tabs.add(_newTab(serverId: widget.initialServerId));
    _handledInitialServerId = widget.initialServerId;
  }

  @override
  void didUpdateWidget(covariant DockerPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final initialServerId = widget.initialServerId;
    if (initialServerId != null && initialServerId != _handledInitialServerId) {
      _openServerTab(initialServerId);
      _handledInitialServerId = initialServerId;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(navigationBranchResetProvider(3), (_, _) => _resetTabs());
    final l10n = AppLocalizations.of(context)!;
    final activeTab = _tabs[_selectedIndex];
    final activeServerId = activeTab.serverId;

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
      actions: [
        if (activeServerId != null)
          IconButton(
            tooltip: l10n.commonRefresh,
            icon: const Icon(Ionicons.refresh_outline),
            onPressed: () => ref
                .read(dockerRefreshProvider(activeServerId).notifier)
                .refresh(),
          ),
      ],
      body: activeServerId == null
          ? ServerPickerList(
              emptyIcon: Ionicons.cube,
              onSelected: (server) => _assignServer(server.id),
            )
          : DockerManagerPage(
              key: ValueKey(activeTab.id),
              serverId: activeServerId,
              showAppBar: false,
            ),
    );
  }

  _DockerTab _newTab({String? serverId}) {
    return _DockerTab(id: 'docker-tab-${_nextTabId++}', serverId: serverId);
  }

  String _tabTitle(_DockerTab tab, AppLocalizations l10n) {
    final serverId = tab.serverId;
    if (serverId == null) return l10n.newTab;
    return ref.watch(serverByIdProvider(serverId))?.name ??
        l10n.fileServerMissing;
  }

  void _assignServer(String serverId) {
    setState(() {
      _tabs[_selectedIndex] = _tabs[_selectedIndex].copyWith(
        serverId: serverId,
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

  void _resetTabs() {
    if (!mounted) return;
    setState(() {
      _tabs
        ..clear()
        ..add(_newTab());
      _selectedIndex = 0;
      _handledInitialServerId = null;
    });
  }

  void _closeTab(int index) {
    setState(() {
      if (_tabs.length == 1) {
        _tabs[0] = _newTab();
        _selectedIndex = 0;
        return;
      }
      _tabs.removeAt(index);
      if (_selectedIndex >= _tabs.length) {
        _selectedIndex = _tabs.length - 1;
      } else if (index < _selectedIndex) {
        _selectedIndex--;
      }
    });
  }
}

class _DockerTab {
  final String id;
  final String? serverId;

  const _DockerTab({required this.id, this.serverId});

  _DockerTab copyWith({String? serverId}) {
    return _DockerTab(id: id, serverId: serverId ?? this.serverId);
  }
}
