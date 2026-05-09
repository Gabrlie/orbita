import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/models/tailnet_models.dart';
import 'package:orbita/providers/tailnet_provider.dart';
import 'package:orbita/widgets/common.dart';

class NetworkSettingsPage extends ConsumerWidget {
  const NetworkSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final status = ref.watch(tailnetStatusProvider);

    return Scaffold(
      appBar: compactPageAppBar(
        context,
        title: l10n.settingsNetwork,
        fallbackLocation: '/settings',
        actions: [
          IconButton(
            tooltip: l10n.tailnetRefreshStatus,
            icon: const Icon(Ionicons.refresh_outline),
            onPressed: () => ref.invalidate(tailnetStatusProvider),
          ),
        ],
      ),
      body: TonalListBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            SectionHeader(
              title: l10n.tailnetSection,
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            ),
            status.when(
              data: (value) => _TailnetStatusCard(status: value),
              loading: () => const LinearProgressIndicator(),
              error: (error, stackTrace) =>
                  _TailnetErrorCard(message: error.toString()),
            ),
          ],
        ),
      ),
    );
  }
}

class _TailnetStatusCard extends ConsumerWidget {
  final TailnetStatus status;

  const _TailnetStatusCard({required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Material(
      color: tonalItemColor(context),
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              status.isRunning
                  ? Ionicons.checkmark_circle_outline
                  : Ionicons.log_in_outline,
              color: status.isRunning
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            title: Text(l10n.tailnetEmbeddedService),
            subtitle: Text(
              status.error.isEmpty
                  ? l10n.tailnetBackendState(status.backendState)
                  : status.error,
            ),
            trailing: status.needsLogin
                ? TextButton(
                    onPressed: () => _showAuthUrl(context, ref),
                    child: Text(l10n.tailnetLogin),
                  )
                : null,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Ionicons.git_network_outline),
            title: Text(l10n.tailnetPeers),
            subtitle: Text(l10n.tailnetPeerCount(status.peers.length)),
          ),
          for (final peer in status.peers.take(6)) ...[
            const Divider(height: 1, indent: 56),
            ListTile(
              dense: true,
              leading: Icon(
                peer.online
                    ? Ionicons.radio_button_on_outline
                    : Ionicons.radio_button_off_outline,
                size: 18,
              ),
              title: Text(peer.displayName),
              subtitle: Text(
                peer.tailscaleIps.firstOrNull ?? l10n.tailnetPeerNoIp,
              ),
            ),
          ],
          const Divider(height: 1),
          OverflowBar(
            alignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () async {
                  await ref.read(embeddedTailnetServiceProvider).clearState();
                  ref.invalidate(tailnetStatusProvider);
                },
                child: Text(l10n.tailnetClearState),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showAuthUrl(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await ref.read(embeddedTailnetServiceProvider).openAuthUrl();
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.tailnetAuthOpenFailed(error.toString()))),
      );
    }
  }
}

class _TailnetErrorCard extends StatelessWidget {
  final String message;

  const _TailnetErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Material(
      color: tonalItemColor(context),
      borderRadius: BorderRadius.circular(14),
      child: ListTile(
        leading: Icon(
          Ionicons.alert_circle_outline,
          color: theme.colorScheme.error,
        ),
        title: Text(l10n.tailnetUnavailable),
        subtitle: Text(message),
      ),
    );
  }
}
