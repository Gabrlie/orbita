import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/models/server.dart';
import 'package:orbita/models/tailnet_models.dart';
import 'package:orbita/providers/tailnet_provider.dart';
import 'package:orbita/widgets/common.dart';
import 'package:orbita/widgets/orbita_forui.dart';

class ServerNetworkSection extends ConsumerWidget {
  final ServerConnectionMode connectionMode;
  final ValueChanged<ServerConnectionMode> onConnectionModeChanged;
  final String? selectedPeerName;
  final String? selectedPeerDnsName;
  final ValueChanged<TailnetPeer?> onPeerChanged;

  const ServerNetworkSection({
    super.key,
    required this.connectionMode,
    required this.onConnectionModeChanged,
    required this.selectedPeerName,
    required this.selectedPeerDnsName,
    required this.onPeerChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: l10n.serverNetworkSection,
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
        ),
        Text(
          l10n.serverConnectionMode,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        OrbitaSwipeableTabs<ServerConnectionMode>(
          value: connectionMode,
          values: ServerConnectionMode.values,
          labelBuilder: (mode) => switch (mode) {
            ServerConnectionMode.direct => l10n.connectionModeDirect,
            ServerConnectionMode.tailscale => l10n.connectionModeTailscale,
          },
          iconBuilder: (mode) => Icon(
            switch (mode) {
              ServerConnectionMode.direct => Ionicons.server_outline,
              ServerConnectionMode.tailscale => Ionicons.git_network_outline,
            },
            size: 18,
          ),
          onChanged: onConnectionModeChanged,
        ),
        if (connectionMode == ServerConnectionMode.tailscale) ...[
          const SizedBox(height: 12),
          _TailnetStatusTile(onLogin: () => _showAuthUrl(context, ref)),
          const SizedBox(height: 12),
          FButton(
            variant: FButtonVariant.outline,
            onPress: () => _pickPeer(context, ref),
            prefix: const Icon(Ionicons.git_network_outline),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(_selectedPeerLabel(l10n)),
            ),
          ),
        ],
      ],
    );
  }

  String _selectedPeerLabel(AppLocalizations l10n) {
    final dns = selectedPeerDnsName?.trim();
    if (dns != null && dns.isNotEmpty) return dns;
    final name = selectedPeerName?.trim();
    if (name != null && name.isNotEmpty) return name;
    return l10n.tailnetSelectPeer;
  }

  Future<void> _pickPeer(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final peers = await ref.read(embeddedTailnetServiceProvider).listPeers();
      if (!context.mounted) return;
      if (peers.isEmpty) {
        await showInfoDialog(
          context,
          title: l10n.tailnetPeerPickerTitle,
          content: l10n.tailnetNoPeers,
        );
        return;
      }
      final peer = await showOrbitaBottomSheet<TailnetPeer>(
        context: context,
        mainAxisMaxRatio: null,
        builder: (context) => _TailnetPeerSheet(peers: peers),
      );
      if (peer == null) return;
      onPeerChanged(peer);
    } catch (error) {
      if (!context.mounted) return;
      await showInfoDialog(
        context,
        title: l10n.tailnetPeerPickerTitle,
        content: l10n.tailnetPeerLoadFailed(error.toString()),
      );
    }
  }

  Future<void> _showAuthUrl(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await ref.read(embeddedTailnetServiceProvider).openAuthUrl();
    } catch (error) {
      if (!context.mounted) return;
      await showInfoDialog(
        context,
        title: l10n.tailnetEmbeddedService,
        content: l10n.tailnetAuthOpenFailed(error.toString()),
      );
    }
  }
}

class _TailnetStatusTile extends ConsumerWidget {
  final VoidCallback onLogin;

  const _TailnetStatusTile({required this.onLogin});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final status = ref.watch(tailnetStatusProvider);
    return FCard.raw(
      child: status.when(
        data: (value) => FItem(
          prefix: Icon(
            value.isRunning
                ? Ionicons.checkmark_circle_outline
                : Ionicons.log_in_outline,
            color: value.isRunning
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
          title: Text(l10n.tailnetEmbeddedService),
          subtitle: Text(
            value.error.isEmpty
                ? l10n.tailnetBackendState(value.backendState)
                : value.error,
          ),
          suffix: value.needsLogin
              ? FButton(
                  size: FButtonSizeVariant.sm,
                  variant: FButtonVariant.outline,
                  mainAxisSize: MainAxisSize.min,
                  onPress: onLogin,
                  child: Text(l10n.tailnetLogin),
                )
              : null,
        ),
        loading: () =>
            const Padding(padding: EdgeInsets.all(16), child: FProgress()),
        error: (error, stackTrace) => FItem(
          prefix: Icon(
            Ionicons.alert_circle_outline,
            color: theme.colorScheme.error,
          ),
          title: Text(l10n.tailnetUnavailable),
          subtitle: Text(error.toString()),
        ),
      ),
    );
  }
}

class _TailnetPeerSheet extends StatelessWidget {
  final List<TailnetPeer> peers;

  const _TailnetPeerSheet({required this.peers});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          child: Text(
            l10n.tailnetPeerPickerTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        for (final peer in peers)
          FItem(
            prefix: Icon(
              peer.online
                  ? Ionicons.radio_button_on_outline
                  : Ionicons.radio_button_off_outline,
            ),
            title: Text(peer.displayName),
            subtitle: Text(
              [
                if (peer.hostName.isNotEmpty) peer.hostName,
                peer.tailscaleIps.firstOrNull ?? l10n.tailnetPeerNoIp,
                peer.online ? l10n.tailnetPeerOnline : l10n.offline,
              ].join(' · '),
            ),
            onPress: () => Navigator.of(context).pop(peer),
          ),
      ],
    );
  }
}
