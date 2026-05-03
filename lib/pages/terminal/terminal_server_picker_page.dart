import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/models/server.dart';
import 'package:orbita/pages/server/terminal/terminal_launch_mode.dart';
import 'package:orbita/providers/server_provider.dart';
import 'package:orbita/widgets/action_sheet.dart';
import 'package:orbita/widgets/common.dart';
import 'package:orbita/widgets/os_icon.dart';

class TerminalServerPickerPage extends ConsumerWidget {
  const TerminalServerPickerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final serversAsync = ref.watch(serverListProvider);

    return Scaffold(
      appBar: AppBar(),
      body: serversAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (servers) {
          if (servers.isEmpty) {
            return EmptyState(
              icon: Ionicons.terminal,
              title: l10n.noServersTitle,
              subtitle: l10n.noServersSubtitle,
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: servers.length,
            itemBuilder: (context, index) {
              return _TerminalServerTile(server: servers[index]);
            },
          );
        },
      ),
    );
  }
}

class _TerminalServerTile extends StatelessWidget {
  final Server server;

  const _TerminalServerTile({required this.server});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 3,
      shadowColor: theme.colorScheme.shadow.withAlpha(32),
      surfaceTintColor: Colors.transparent,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openTerminal(context),
        onLongPress: () => _showConnectionMenu(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              OsIcon(type: server.osType, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      server.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${server.host}:${server.port}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Ionicons.chevron_forward,
                size: 20,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConnectionMenu(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showActionSheet(
      context,
      title: l10n.terminalConnectOptions,
      items: [
        ActionSheetItem(
          icon: Ionicons.terminal_outline,
          label: l10n.actionConnect,
          onTap: () => _openTerminal(context),
        ),
        ActionSheetItem(
          icon: Ionicons.layers_outline,
          label: l10n.terminalConnectTmux,
          onTap: () => _openTerminal(context, mode: TerminalLaunchMode.tmux),
        ),
      ],
    );
  }

  void _openTerminal(
    BuildContext context, {
    TerminalLaunchMode mode = TerminalLaunchMode.direct,
  }) {
    final queryMode = terminalLaunchModeToQuery(mode);
    final location = Uri(
      path: '/terminal/${server.id}',
      queryParameters: queryMode == null ? null : {'mode': queryMode},
    ).toString();
    context.go(location);
  }
}
