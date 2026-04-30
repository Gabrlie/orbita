import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/pages/home/server_card_item.dart';
import 'package:orbita/providers/server_provider.dart';
import 'package:orbita/providers/server_refresh_provider.dart';
import 'package:orbita/widgets/common.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final serversAsync = ref.watch(serverListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.servers),
        actions: [
          IconButton(
            tooltip: l10n.serverSearchTitle,
            icon: const Icon(Ionicons.search_outline),
            onPressed: () => context.go('/home/search'),
          ),
          PopupMenuButton<String>(
            tooltip: l10n.homeMoreActions,
            icon: const Icon(Ionicons.ellipsis_horizontal),
            onSelected: (value) {
              switch (value) {
                case 'add':
                  context.go('/home/server/add');
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'add',
                child: Row(
                  children: [
                    const Icon(Ionicons.add, size: 20),
                    const SizedBox(width: 12),
                    Text(l10n.addServer),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                enabled: false,
                child: Text(
                  '${l10n.homeLayoutOptions} (${l10n.inDevelopment})',
                ),
              ),
              PopupMenuItem(
                enabled: false,
                child: Text('${l10n.settingsGroups} (${l10n.inDevelopment})'),
              ),
            ],
          ),
        ],
      ),
      body: serversAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (servers) => RefreshIndicator(
          onRefresh: () async {
            ref
                .read(serverRefreshControllerProvider.notifier)
                .refreshAll(servers.map((server) => server.id));
          },
          child: servers.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(top: 32),
                  children: [
                    SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.6,
                      child: EmptyState(
                        icon: Ionicons.server,
                        title: l10n.noServersTitle,
                        subtitle: l10n.noServersSubtitle,
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: servers.length,
                  itemBuilder: (context, index) {
                    final s = servers[index];
                    return ServerCardItem(server: s);
                  },
                ),
        ),
      ),
    );
  }
}
