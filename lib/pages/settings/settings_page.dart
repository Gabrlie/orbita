import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/providers/server_provider.dart';
import 'package:orbita/widgets/common.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final disabledColor = theme.colorScheme.onSurface.withAlpha(97);
    final serverCount = ref.watch(serverListProvider).value?.length ?? 0;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navSettings)),
      body: ListView(
        children: [
          // -- Server Management --
          SectionHeader(title: l10n.settingsServerSection),
          ListTile(
            leading: const Icon(Icons.storage_outlined),
            title: Text(l10n.settingsServers),
            subtitle: Text(l10n.serverCount(serverCount)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/settings/servers'),
          ),
          ListTile(
            leading: const Icon(Icons.account_tree_outlined),
            title: Text(l10n.settingsGroups),
            subtitle: Text(l10n.settingsGroupsDesc),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showDev(context, l10n),
          ),
          ListTile(
            leading: const Icon(Icons.key_outlined),
            title: Text(l10n.keyManagement),
            subtitle: Text(l10n.keyManagementDesc),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/settings/keys'),
          ),

          // -- Tools --
          SectionHeader(title: l10n.settingsToolsSection),
          ListTile(
            leading: const Icon(Icons.code_outlined),
            title: Text(l10n.settingsScripts),
            subtitle: Text(l10n.settingsScriptsDesc),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/settings/scripts'),
          ),
          ListTile(
            leading: const Icon(Icons.data_object_outlined),
            title: Text(l10n.settingsSnippets),
            subtitle: Text(l10n.settingsSnippetsDesc),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/settings/snippets'),
          ),

          // -- Security & Sync --
          SectionHeader(title: l10n.settingsSecuritySection),
          ListTile(
            leading: const Icon(Icons.lock_outlined),
            title: Text(l10n.settingsSecurity),
            subtitle: Text(l10n.settingsSecurityDesc),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/settings/security'),
          ),
          ListTile(
            leading: const Icon(Icons.sync_outlined),
            title: Text(l10n.settingsSync),
            subtitle: Text(l10n.settingsSyncDesc),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showDev(context, l10n),
          ),

          // -- Application --
          SectionHeader(title: l10n.settingsAppSection),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: Text(l10n.settingsAppearance),
            subtitle: Text(l10n.settingsAppearanceDesc),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/settings/appearance'),
          ),
          ListTile(
            leading: Icon(Icons.hub_outlined, color: disabledColor),
            title: Text(
              l10n.settingsNetwork,
              style: TextStyle(color: disabledColor),
            ),
            subtitle: Text(
              l10n.comingSoon,
              style: TextStyle(color: disabledColor),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outlined),
            title: Text(l10n.settingsAbout),
            subtitle: Text(l10n.settingsAboutDesc),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showDev(context, l10n),
          ),
        ],
      ),
    );
  }

  void _showDev(BuildContext context, AppLocalizations l10n) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.inDevelopment)));
  }
}
