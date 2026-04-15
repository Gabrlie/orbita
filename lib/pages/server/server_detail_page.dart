import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:orbita/l10n/app_localizations.dart';

import 'status/status_page.dart';
import 'terminal/terminal_page.dart';
import 'files/files_page.dart';
import 'docker/docker_page.dart';
import 'scripts/scripts_page.dart';

class ServerDetailPage extends StatefulWidget {
  final String id;

  const ServerDetailPage({super.key, required this.id});

  @override
  State<ServerDetailPage> createState() => _ServerDetailPageState();
}

class _ServerDetailPageState extends State<ServerDetailPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  static const _tabPages = <Widget>[
    StatusPage(),
    TerminalPage(),
    FilesPage(),
    DockerPage(),
    ScriptsPage(),
  ];

  // Mock server names for placeholder UI
  static const _mockNames = {
    '1': 'Web Server 1',
    '2': 'DB Server',
    '3': 'Backup Node',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabPages.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: Text(_mockNames[widget.id] ?? l10n.serverDetail),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(icon: const Icon(Icons.insert_chart_outlined), text: l10n.statusTab),
            Tab(icon: const Icon(Icons.terminal), text: l10n.terminalTab),
            Tab(icon: const Icon(Icons.folder_outlined), text: l10n.filesTab),
            Tab(icon: const Icon(Icons.widgets_outlined), text: l10n.dockerTab),
            Tab(icon: const Icon(Icons.code), text: l10n.scriptsTab),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabPages,
      ),
    );
  }
}
