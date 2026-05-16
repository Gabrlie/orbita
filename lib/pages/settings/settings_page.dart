import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/providers/server_provider.dart';
import 'package:orbita/widgets/common.dart';
import 'package:orbita/widgets/settings_tiles.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final serverCount = ref.watch(serverListProvider).value?.length ?? 0;

    return Scaffold(
      body: TonalListBackground(
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              OrbitaSettingsTileGroup(
                title: l10n.settingsServerSection,
                children: [
                  orbitaSettingsTile(
                    context,
                    icon: Ionicons.server_outline,
                    title: l10n.settingsServers,
                    subtitle: l10n.serverCount(serverCount),
                    onPress: () => _open(context, '/settings/servers'),
                  ),
                  orbitaSettingsTile(
                    context,
                    icon: Ionicons.git_branch_outline,
                    title: l10n.settingsGroups,
                    subtitle: l10n.settingsGroupsDesc,
                    onPress: () => _open(context, '/settings/groups'),
                  ),
                  orbitaSettingsTile(
                    context,
                    icon: Ionicons.key_outline,
                    title: l10n.keyManagement,
                    subtitle: l10n.keyManagementDesc,
                    onPress: () => _open(context, '/settings/keys'),
                  ),
                ],
              ),
              OrbitaSettingsTileGroup(
                title: l10n.settingsToolsSection,
                children: [
                  orbitaSettingsTile(
                    context,
                    icon: Ionicons.code_slash_outline,
                    title: l10n.settingsScripts,
                    subtitle: l10n.settingsScriptsDesc,
                    onPress: () => _open(context, '/settings/scripts'),
                  ),
                  orbitaSettingsTile(
                    context,
                    icon: Ionicons.extension_puzzle_outline,
                    title: l10n.settingsSnippets,
                    subtitle: l10n.settingsSnippetsDesc,
                    onPress: () => _open(context, '/settings/snippets'),
                  ),
                  orbitaSettingsTile(
                    context,
                    icon: Ionicons.swap_horizontal_outline,
                    title: l10n.settingsTransfer,
                    subtitle: l10n.settingsTransferDesc,
                    onPress: () => _open(context, '/settings/transfers'),
                  ),
                  orbitaSettingsTile(
                    context,
                    icon: Ionicons.git_network_outline,
                    title: l10n.settingsNetwork,
                    subtitle: l10n.settingsNetworkDesc,
                    onPress: () => _open(context, '/settings/network'),
                  ),
                ],
              ),
              OrbitaSettingsTileGroup(
                title: l10n.settingsSecuritySection,
                children: [
                  orbitaSettingsTile(
                    context,
                    icon: Ionicons.shield_checkmark_outline,
                    title: l10n.settingsSecurity,
                    subtitle: l10n.settingsSecurityDesc,
                    onPress: () => _open(context, '/settings/security'),
                  ),
                  orbitaSettingsTile(
                    context,
                    icon: Ionicons.sync_outline,
                    title: l10n.settingsSync,
                    subtitle: l10n.settingsSyncDesc,
                    onPress: () => _open(context, '/settings/backup-sync'),
                  ),
                ],
              ),
              OrbitaSettingsTileGroup(
                title: l10n.settingsAppSection,
                children: [
                  orbitaSettingsTile(
                    context,
                    icon: Ionicons.color_palette_outline,
                    title: l10n.settingsAppearance,
                    subtitle: l10n.settingsAppearanceDesc,
                    onPress: () => _open(context, '/settings/appearance'),
                  ),
                  orbitaSettingsTile(
                    context,
                    icon: Ionicons.speedometer_outline,
                    title: l10n.metricSettingsTitle,
                    subtitle: l10n.metricSettingsDesc,
                    onPress: () => _open(context, '/settings/metrics'),
                  ),
                  orbitaSettingsTile(
                    context,
                    icon: Ionicons.information_circle_outline,
                    title: l10n.settingsAbout,
                    subtitle: l10n.settingsAboutDesc,
                    onPress: () => _open(context, '/settings/about'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _open(BuildContext context, String path) {
    context.push(path);
  }
}
