import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/pages/server/terminal/terminal_launch_mode.dart';
import 'package:orbita/pages/server/terminal/terminal_platform.dart';
import 'package:orbita/pages/server/terminal/terminal_dashboard.dart';
import 'package:orbita/providers/server_provider.dart';

import 'status/status_page.dart';
import 'terminal/terminal_page.dart';
import 'files/files_page.dart';
import 'docker/docker_page.dart';
import 'scripts/scripts_page.dart';

class ServerDetailPage extends ConsumerStatefulWidget {
  final String id;

  const ServerDetailPage({super.key, required this.id});

  @override
  ConsumerState<ServerDetailPage> createState() => _ServerDetailPageState();
}

class _ServerDetailPageState extends ConsumerState<ServerDetailPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  var _tabIndex = 0;
  var _terminalLaunchMode = TerminalLaunchMode.direct;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (_tabIndex != _tabController.index) {
        setState(() => _tabIndex = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final server = ref.watch(serverByIdProvider(widget.id));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: Text(server?.name ?? l10n.serverDetail),
        actions: _buildActions(context),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(
              icon: const Icon(Icons.insert_chart_outlined),
              text: l10n.statusTab,
            ),
            Tab(icon: const Icon(Icons.terminal), text: l10n.terminalTab),
            Tab(icon: const Icon(Icons.folder_outlined), text: l10n.filesTab),
            Tab(icon: const Icon(Icons.widgets_outlined), text: l10n.dockerTab),
            Tab(icon: const Icon(Icons.code), text: l10n.scriptsTab),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const StatusPage(),
          TerminalPage(
            serverId: widget.id,
            showAppBar: false,
            launchMode: _terminalLaunchMode,
          ),
          const FilesPage(),
          const DockerPage(),
          const ScriptsPage(),
        ],
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_tabIndex == 1) {
      return [
        if (isTouchPlatform())
          IconButton(
            tooltip: l10n.terminalDashboard,
            icon: const Icon(Ionicons.speedometer_outline),
            onPressed: () => _openTerminalDashboard(context),
          ),
        PopupMenuButton<TerminalLaunchMode>(
          tooltip: l10n.terminalConnectOptions,
          icon: const Icon(Ionicons.ellipsis_horizontal),
          initialValue: _terminalLaunchMode,
          onSelected: (mode) {
            if (_terminalLaunchMode == mode) return;
            setState(() => _terminalLaunchMode = mode);
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: TerminalLaunchMode.direct,
              child: Row(
                children: [
                  const Icon(Ionicons.terminal_outline, size: 20),
                  const SizedBox(width: 12),
                  Text(l10n.actionConnect),
                ],
              ),
            ),
            PopupMenuItem(
              value: TerminalLaunchMode.tmux,
              child: Row(
                children: [
                  const Icon(Ionicons.layers_outline, size: 20),
                  const SizedBox(width: 12),
                  Text(l10n.terminalConnectTmux),
                ],
              ),
            ),
          ],
        ),
      ];
    }
    return [
      IconButton(
        icon: const Icon(Icons.edit_outlined),
        onPressed: () => context.go('/home/server/${widget.id}/edit'),
      ),
    ];
  }

  void _openTerminalDashboard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text(l10n.terminalDashboard)),
          body: TerminalDashboard(serverId: widget.id),
        ),
      ),
    );
  }
}
