import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/models/server.dart';
import 'package:orbita/pages/home/server_search.dart';
import 'package:orbita/providers/server_provider.dart';
import 'package:orbita/widgets/common.dart';
import 'package:orbita/widgets/os_icon.dart';

class HomeSearchPage extends ConsumerStatefulWidget {
  const HomeSearchPage({super.key});

  @override
  ConsumerState<HomeSearchPage> createState() => _HomeSearchPageState();
}

class _HomeSearchPageState extends ConsumerState<HomeSearchPage> {
  final _controller = TextEditingController();
  var _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final serversAsync = ref.watch(serverListProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: _SearchField(
          controller: _controller,
          hintText: l10n.serverSearchHint,
          query: _query,
          onChanged: (value) => setState(() => _query = value),
          onClear: () {
            _controller.clear();
            setState(() => _query = '');
          },
        ),
      ),
      body: serversAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (servers) {
          final results = filterServersForQuery(servers, _query);
          if (servers.isEmpty) {
            return EmptyState(
              icon: Ionicons.server,
              title: l10n.noServersTitle,
              subtitle: l10n.noServersSubtitle,
            );
          }
          if (results.isEmpty) {
            return EmptyState(
              icon: Ionicons.search,
              title: l10n.serverSearchNoResults,
              subtitle: l10n.serverSearchNoResultsSubtitle,
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: results.length,
            itemBuilder: (context, index) {
              return _ServerSearchResultTile(server: results[index]);
            },
          );
        },
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchField({
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

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: SizedBox(
        height: 42,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withAlpha(120),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: colorScheme.outlineVariant.withAlpha(120),
            ),
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
                  autofocus: true,
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
                  tooltip: MaterialLocalizations.of(
                    context,
                  ).deleteButtonTooltip,
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
      ),
    );
  }
}

class _ServerSearchResultTile extends StatelessWidget {
  final Server server;

  const _ServerSearchResultTile({required this.server});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tags = server.tags.take(3).join(' · ');

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: OsIcon(type: server.osType, size: 22),
      title: Text(
        server.name,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        tags.isEmpty
            ? '${server.host}:${server.port}'
            : '$tags · ${server.host}',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Icon(
        Ionicons.chevron_forward,
        size: 18,
        color: theme.colorScheme.outline,
      ),
      onTap: () => context.go('/home/server/${server.id}'),
    );
  }
}
