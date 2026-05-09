import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/providers/server_provider.dart';
import 'package:orbita/widgets/common.dart';

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
            padding: const EdgeInsets.only(top: 4, bottom: 24),
            children: [
              _SettingsSection(
                title: l10n.settingsServerSection,
                children: [
                  _SettingsItem(
                    icon: Ionicons.server_outline,
                    title: l10n.settingsServers,
                    subtitle: l10n.serverCount(serverCount),
                    onTap: () => _open(context, '/settings/servers'),
                  ),
                  _SettingsItem(
                    icon: Ionicons.git_branch_outline,
                    title: l10n.settingsGroups,
                    subtitle: l10n.settingsGroupsDesc,
                    onTap: () => _open(context, '/settings/groups'),
                  ),
                  _SettingsItem(
                    icon: Ionicons.key_outline,
                    title: l10n.keyManagement,
                    subtitle: l10n.keyManagementDesc,
                    onTap: () => _open(context, '/settings/keys'),
                  ),
                ],
              ),
              _SettingsSection(
                title: l10n.settingsToolsSection,
                children: [
                  _SettingsItem(
                    icon: Ionicons.code_slash_outline,
                    title: l10n.settingsScripts,
                    subtitle: l10n.settingsScriptsDesc,
                    onTap: () => _open(context, '/settings/scripts'),
                  ),
                  _SettingsItem(
                    icon: Ionicons.extension_puzzle_outline,
                    title: l10n.settingsSnippets,
                    subtitle: l10n.settingsSnippetsDesc,
                    onTap: () => _open(context, '/settings/snippets'),
                  ),
                  _SettingsItem(
                    icon: Ionicons.git_network_outline,
                    title: l10n.settingsNetwork,
                    subtitle: l10n.settingsNetworkDesc,
                    onTap: () => _open(context, '/settings/network'),
                  ),
                ],
              ),
              _SettingsSection(
                title: l10n.settingsSecuritySection,
                children: [
                  _SettingsItem(
                    icon: Ionicons.shield_checkmark_outline,
                    title: l10n.settingsSecurity,
                    subtitle: l10n.settingsSecurityDesc,
                    onTap: () => _open(context, '/settings/security'),
                  ),
                  _SettingsItem(
                    icon: Ionicons.sync_outline,
                    title: l10n.settingsSync,
                    subtitle: l10n.settingsSyncDesc,
                    onTap: () => _open(context, '/settings/backup-sync'),
                  ),
                ],
              ),
              _SettingsSection(
                title: l10n.settingsAppSection,
                children: [
                  _SettingsItem(
                    icon: Ionicons.color_palette_outline,
                    title: l10n.settingsAppearance,
                    subtitle: l10n.settingsAppearanceDesc,
                    onTap: () => _open(context, '/settings/appearance'),
                  ),
                  _SettingsItem(
                    icon: Ionicons.speedometer_outline,
                    title: l10n.metricSettingsTitle,
                    subtitle: l10n.metricSettingsDesc,
                    onTap: () => _open(context, '/settings/metrics'),
                  ),
                  _SettingsItem(
                    icon: Ionicons.information_circle_outline,
                    title: l10n.settingsAbout,
                    subtitle: l10n.settingsAboutDesc,
                    onTap: () => _open(context, '/settings/about'),
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

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: title,
          padding: const EdgeInsets.fromLTRB(28, 24, 24, 8),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Material(
            color: tonalItemColor(context),
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0)
                    const Divider(height: 1, indent: 24, endIndent: 24),
                  children[i],
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Icon(icon, color: theme.colorScheme.primary, size: 20),
      minLeadingWidth: 24,
      horizontalTitleGap: 14,
      title: Text(
        title,
        style: TextStyle(
          color: theme.colorScheme.onSurface,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text(
          subtitle,
          style: TextStyle(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 12,
            height: 1.25,
          ),
        ),
      ),
      trailing: onTap != null
          ? Icon(
              Ionicons.chevron_forward,
              color: theme.colorScheme.outline,
              size: 18,
            )
          : null,
      onTap: onTap,
    );
  }
}
