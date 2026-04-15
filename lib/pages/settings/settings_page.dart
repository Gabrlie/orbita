import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/widgets/common.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final disabledColor = theme.colorScheme.onSurface.withAlpha(97);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navSettings)),
      body: ListView(
        children: [
          // -- Server Management --
          SectionHeader(title: l10n.settingsServerSection),
          ListTile(
            leading: const Icon(Icons.folder_copy_outlined),
            title: Text(l10n.settingsGroups),
            subtitle: Text(l10n.settingsGroupsDesc),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showDev(context, l10n),
          ),

          // -- Tools --
          SectionHeader(title: l10n.settingsToolsSection),
          ListTile(
            leading: const Icon(Icons.code),
            title: Text(l10n.settingsScripts),
            subtitle: Text(l10n.settingsScriptsDesc),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/settings/scripts'),
          ),
          ListTile(
            leading: const Icon(Icons.data_object),
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
            onTap: () => _showDev(context, l10n),
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
            leading: Icon(Icons.vpn_key_outlined, color: disabledColor),
            title: Text(l10n.settingsNetwork,
                style: TextStyle(color: disabledColor)),
            subtitle: Text(l10n.comingSoon,
                style: TextStyle(color: disabledColor)),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.inDevelopment)),
    );
  }
}
