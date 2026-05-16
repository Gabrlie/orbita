import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/models/tailnet_models.dart';
import 'package:orbita/providers/tailnet_provider.dart';
import 'package:orbita/widgets/common.dart';
import 'package:orbita/widgets/settings_tiles.dart';

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
            status.when(
              data: (value) => _TailnetStatusCard(status: value),
              loading: () => const LinearProgressIndicator(),
              error: (error, _) => _TailnetErrorCard(message: error.toString()),
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

    return OrbitaSettingsTileGroup(
      title: l10n.tailnetSection,
      padding: EdgeInsets.zero,
      children: [
        orbitaSettingsTile(
          context,
          icon: status.isRunning
              ? Ionicons.checkmark_circle_outline
              : Ionicons.log_in_outline,
          title: l10n.tailnetEmbeddedService,
          subtitle: status.error.isEmpty
              ? l10n.tailnetBackendState(status.backendState)
              : status.error,
          suffix: status.needsLogin
              ? FButton(
                  variant: FButtonVariant.secondary,
                  size: FButtonSizeVariant.sm,
                  mainAxisSize: MainAxisSize.min,
                  onPress: () => _showAuthUrl(context, ref),
                  child: Text(l10n.tailnetLogin),
                )
              : null,
        ),
        orbitaSettingsTile(
          context,
          icon: Ionicons.git_network_outline,
          title: l10n.tailnetPeers,
          subtitle: l10n.tailnetPeerCount(status.peers.length),
        ),
        for (final peer in status.peers.take(6))
          orbitaSettingsTile(
            context,
            icon: peer.online
                ? Ionicons.radio_button_on_outline
                : Ionicons.radio_button_off_outline,
            title: peer.displayName,
            subtitle: peer.tailscaleIps.firstOrNull ?? l10n.tailnetPeerNoIp,
          ),
        orbitaSettingsTile(
          context,
          icon: Ionicons.refresh_circle_outline,
          title: l10n.tailnetClearState,
          destructive: true,
          onPress: () async {
            await ref.read(embeddedTailnetServiceProvider).clearState();
            ref.invalidate(tailnetStatusProvider);
          },
        ),
      ],
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
    return OrbitaSettingsTileGroup(
      padding: EdgeInsets.zero,
      children: [
        orbitaSettingsTile(
          context,
          icon: Ionicons.alert_circle_outline,
          title: l10n.tailnetUnavailable,
          subtitle: message,
          destructive: true,
        ),
      ],
    );
  }
}
