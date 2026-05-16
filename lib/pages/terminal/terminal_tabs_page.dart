import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/models/server.dart';
import 'package:orbita/pages/server/terminal/terminal_dashboard.dart';
import 'package:orbita/pages/server/terminal/terminal_launch_mode.dart';
import 'package:orbita/pages/server/terminal/terminal_page.dart';
import 'package:orbita/pages/server/terminal/terminal_platform.dart';
import 'package:orbita/providers/navigation_reset_provider.dart';
import 'package:orbita/providers/remote_script_provider.dart';
import 'package:orbita/providers/server_provider.dart';
import 'package:orbita/providers/terminal_connection_preference_provider.dart';
import 'package:orbita/widgets/common.dart';
import 'package:orbita/widgets/orbita_forui.dart';
import 'package:orbita/widgets/remote_script_output_dialog.dart';
import 'package:orbita/widgets/server_picker_list.dart';
import 'package:orbita/widgets/server_tabs_scaffold.dart';

part 'terminal_tabs_tmux.dart';
part 'terminal_tab_model.dart';

class TerminalTabsPage extends ConsumerStatefulWidget {
  final String? initialServerId;
  final TerminalLaunchMode initialLaunchMode;
  final bool initialUseRememberedMode;
  final String? initialCommand;
  final String? initialTitle;

  const TerminalTabsPage({
    super.key,
    this.initialServerId,
    this.initialLaunchMode = TerminalLaunchMode.direct,
    this.initialUseRememberedMode = false,
    this.initialCommand,
    this.initialTitle,
  });

  @override
  ConsumerState<TerminalTabsPage> createState() => _TerminalTabsPageState();
}

class _TerminalTabsPageState extends ConsumerState<TerminalTabsPage> {
  final _tabs = <_TerminalTab>[];
  var _selectedIndex = 0;
  var _nextTabId = 0;
  String? _handledInitialKey;

  @override
  void initState() {
    super.initState();
    _tabs.add(
      _newTab(
        serverId: widget.initialServerId,
        launchMode: _initialLaunchMode,
        initialCommand: widget.initialCommand,
        titleOverride: widget.initialTitle,
      ),
    );
    _handledInitialKey = _initialKey;
  }

  @override
  void didUpdateWidget(covariant TerminalTabsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final key = _initialKey;
    if (widget.initialServerId != null && key != _handledInitialKey) {
      _openServerTab(
        widget.initialServerId!,
        launchMode: _initialLaunchMode,
        initialCommand: widget.initialCommand,
        titleOverride: widget.initialTitle,
      );
      _handledInitialKey = key;
    }
  }

  String? get _initialKey {
    final serverId = widget.initialServerId;
    if (serverId == null) return null;
    return [
      serverId,
      terminalLaunchModeToQuery(widget.initialLaunchMode) ?? 'direct',
      widget.initialCommand ?? '',
      widget.initialTitle ?? '',
      widget.initialUseRememberedMode ? 'remember' : 'fixed',
    ].join('|');
  }

  TerminalLaunchMode get _initialLaunchMode {
    final serverId = widget.initialServerId;
    if (serverId == null || !widget.initialUseRememberedMode) {
      return widget.initialLaunchMode;
    }
    return ref
        .read(terminalConnectionPreferenceProvider.notifier)
        .modeFor(serverId);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(navigationBranchResetProvider(2), (_, _) => _resetTabs());
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
      actions: [
        if (activeServerId != null && isTouchPlatform())
          IconButton(
            tooltip: l10n.terminalDashboard,
            icon: const Icon(Ionicons.ellipsis_horizontal),
            onPressed: () => _openDashboard(activeServerId),
          ),
      ],
      body: activeServerId == null
          ? ServerPickerList(
              emptyIcon: Ionicons.terminal,
              onSelected: (server) => _assignServer(server.id),
              menuActionsBuilder: (context, ref, server) =>
                  _connectionMenuActions(AppLocalizations.of(context)!),
              onMenuSelected: _handleConnectionMenuAction,
            )
          : TerminalPage(
              key: ValueKey(activeTab.id),
              serverId: activeServerId,
              showAppBar: false,
              launchMode: activeTab.launchMode,
              initialCommand: activeTab.initialCommand,
              title: activeTab.titleOverride,
            ),
    );
  }

  _TerminalTab _newTab({
    String? serverId,
    TerminalLaunchMode launchMode = TerminalLaunchMode.direct,
    String? initialCommand,
    String? titleOverride,
  }) {
    return _TerminalTab(
      id: 'terminal-tab-${_nextTabId++}',
      serverId: serverId,
      launchMode: launchMode,
      initialCommand: initialCommand,
      titleOverride: titleOverride,
    );
  }

  String _tabTitle(_TerminalTab tab, AppLocalizations l10n) {
    final serverId = tab.serverId;
    if (serverId == null) return l10n.newTab;
    return tab.titleOverride ??
        ref.watch(serverByIdProvider(serverId))?.name ??
        l10n.fileServerMissing;
  }

  void _assignServer(String serverId, {TerminalLaunchMode? launchMode}) {
    final resolvedMode =
        launchMode ??
        ref
            .read(terminalConnectionPreferenceProvider.notifier)
            .modeFor(serverId);
    if (launchMode != null) {
      unawaited(
        ref
            .read(terminalConnectionPreferenceProvider.notifier)
            .setMode(serverId, launchMode),
      );
    }
    setState(() {
      _tabs[_selectedIndex] = _tabs[_selectedIndex].copyWith(
        serverId: serverId,
        launchMode: resolvedMode,
        clearInitialCommand: true,
        clearTitleOverride: true,
      );
    });
  }

  void _openServerTab(
    String serverId, {
    TerminalLaunchMode launchMode = TerminalLaunchMode.direct,
    String? initialCommand,
    String? titleOverride,
  }) {
    final existingIndex = _tabs.indexWhere(
      (tab) =>
          tab.serverId == serverId &&
          tab.launchMode == launchMode &&
          tab.initialCommand == initialCommand &&
          tab.titleOverride == titleOverride,
    );
    setState(() {
      if (existingIndex >= 0) {
        _selectedIndex = existingIndex;
      } else if (_tabs[_selectedIndex].serverId == null) {
        _tabs[_selectedIndex] = _tabs[_selectedIndex].copyWith(
          serverId: serverId,
          launchMode: launchMode,
          initialCommand: initialCommand,
          titleOverride: titleOverride,
        );
      } else {
        _tabs.add(
          _newTab(
            serverId: serverId,
            launchMode: launchMode,
            initialCommand: initialCommand,
            titleOverride: titleOverride,
          ),
        );
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
      _handledInitialKey = null;
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

  void _openDashboard(String serverId) {
    final l10n = AppLocalizations.of(context)!;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => Scaffold(
          appBar: compactPageAppBar(context, title: l10n.terminalDashboard),
          body: TerminalDashboard(serverId: serverId),
        ),
      ),
    );
  }
}
