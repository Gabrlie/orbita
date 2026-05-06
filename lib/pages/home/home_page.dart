import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/models/server.dart';
import 'package:orbita/models/server_group.dart';
import 'package:orbita/pages/home/server_card_item.dart';
import 'package:orbita/pages/home/server_search.dart';
import 'package:orbita/providers/navigation_reset_provider.dart';
import 'package:orbita/providers/server_group_provider.dart';
import 'package:orbita/providers/server_provider.dart';
import 'package:orbita/providers/server_refresh_provider.dart';
import 'package:orbita/widgets/common.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _searchController = TextEditingController();
  var _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(navigationBranchResetProvider(0), (_, _) => _resetSearch());
    final l10n = AppLocalizations.of(context)!;
    final serversAsync = ref.watch(serverListProvider);
    final groupState = ref.watch(serverGroupProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: _HomeSearchField(
          controller: _searchController,
          hintText: l10n.serverSearchHint,
          query: _query,
          onChanged: (value) => setState(() => _query = value),
          onClear: () {
            _searchController.clear();
            setState(() => _query = '');
          },
        ),
        actions: [
          IconButton(
            tooltip: l10n.addServer,
            icon: const Icon(Ionicons.add),
            onPressed: () => context.go('/home/server/add'),
          ),
        ],
      ),
      body: serversAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (servers) => TonalListBackground(
          child: RefreshIndicator(
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
                : _serverList(context, l10n, servers, groupState),
          ),
        ),
      ),
    );
  }

  void _resetSearch() {
    if (!mounted) return;
    _searchController.clear();
    setState(() => _query = '');
  }

  Widget _serverList(
    BuildContext context,
    AppLocalizations l10n,
    List<Server> servers,
    ServerGroupState groupState,
  ) {
    final results = filterServersForQuery(servers, _query);
    if (results.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.2),
          EmptyState(
            icon: Ionicons.search,
            title: l10n.serverSearchNoResults,
            subtitle: l10n.serverSearchNoResultsSubtitle,
          ),
        ],
      );
    }

    final buckets = groupServersForDisplay(
      servers: results,
      groupState: groupState,
      unnamedGroupName: l10n.serverGroupUnnamed,
    ).where((bucket) => bucket.servers.isNotEmpty).toList();
    final showHeaders = shouldShowServerGroupHeaders(buckets);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 4),
      children: [
        for (final bucket in buckets) ...[
          if (showHeaders)
            SectionHeader(
              title: bucket.name,
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 4),
            ),
          for (final server in bucket.servers) ServerCardItem(server: server),
        ],
      ],
    );
  }
}

class _HomeSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _HomeSearchField({
    required this.controller,
    required this.hintText,
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      height: 40,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tonalItemColor(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Icon(
              Ionicons.search_outline,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                cursorColor: colorScheme.primary,
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                  isCollapsed: true,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  filled: false,
                ),
                textInputAction: TextInputAction.search,
                onChanged: onChanged,
              ),
            ),
            if (query.isNotEmpty)
              IconButton(
                tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
                icon: Icon(
                  Ionicons.close_circle,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
                constraints: const BoxConstraints.tightFor(
                  width: 36,
                  height: 36,
                ),
                padding: EdgeInsets.zero,
                onPressed: onClear,
              )
            else
              const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}
