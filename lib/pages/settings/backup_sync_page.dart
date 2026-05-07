import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/pages/settings/backup_sync_widgets.dart';
import 'package:orbita/pages/settings/security/security_dialogs.dart';
import 'package:orbita/providers/backup_sync_provider.dart';
import 'package:orbita/providers/security_provider.dart';
import 'package:orbita/widgets/common.dart';

class BackupSyncPage extends ConsumerWidget {
  const BackupSyncPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(backupSyncProvider);
    final security = ref.watch(appSecurityProvider).value;

    return Scaffold(
      appBar: compactPageAppBar(
        context,
        title: l10n.backupSyncTitle,
        fallbackLocation: '/settings',
      ),
      body: TonalListBackground(
        child: settings.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('$error')),
          data: (backup) => ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              BackupPanel(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Ionicons.folder_open_outline),
                    title: Text(l10n.backupLocalFolder),
                    subtitle: Text(
                      backup.localFolder.isEmpty
                          ? l10n.backupLocalFolderUnset
                          : backup.localFolder,
                    ),
                    value: backup.localEnabled,
                    onChanged: backup.localFolder.isEmpty
                        ? null
                        : ref.read(backupSyncProvider.notifier).setLocalEnabled,
                  ),
                  ListTile(
                    leading: const Icon(Ionicons.folder_outline),
                    title: Text(l10n.backupChooseFolder),
                    onTap: ref
                        .read(backupSyncProvider.notifier)
                        .pickLocalFolder,
                  ),
                ],
              ),
              SectionHeader(
                title: l10n.backupRemoteSection,
                padding: const EdgeInsets.fromLTRB(12, 24, 12, 8),
              ),
              BackupPanel(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Ionicons.cloud_upload_outline),
                    title: Text(l10n.backupWebDav),
                    subtitle: Text(
                      backup.webdavUrl.isEmpty
                          ? l10n.backupWebDavUnset
                          : backup.webdavUrl,
                    ),
                    value: backup.webdavEnabled,
                    onChanged: backup.webdavUrl.isEmpty
                        ? null
                        : ref
                              .read(backupSyncProvider.notifier)
                              .setWebDavEnabled,
                  ),
                  ListTile(
                    leading: const Icon(Ionicons.settings_outline),
                    title: Text(l10n.backupWebDavConfig),
                    onTap: () => _configureWebDav(context, ref),
                  ),
                  ListTile(
                    leading: const Icon(Ionicons.pulse_outline),
                    title: Text(l10n.backupTestWebDav),
                    enabled: backup.webdavUrl.isNotEmpty,
                    onTap: () => _run(context, () {
                      return ref.read(backupSyncProvider.notifier).testWebDav();
                    }),
                  ),
                ],
              ),
              SectionHeader(
                title: l10n.backupOperations,
                padding: const EdgeInsets.fromLTRB(12, 24, 12, 8),
              ),
              BackupPanel(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Ionicons.sync_outline),
                    title: Text(l10n.backupAuto),
                    subtitle: Text(l10n.backupAutoDesc),
                    value: backup.autoBackupEnabled,
                    onChanged: security?.hasPassword == true
                        ? (value) => _setAuto(context, ref, value)
                        : null,
                  ),
                  ListTile(
                    leading: const Icon(Ionicons.archive_outline),
                    title: Text(l10n.backupManual),
                    subtitle: Text(l10n.backupPasswordRequired),
                    enabled: security?.hasPassword == true,
                    onTap: () => _manualBackup(context, ref),
                  ),
                  ListTile(
                    leading: const Icon(Ionicons.download_outline),
                    title: Text(l10n.backupRestoreLocal),
                    enabled: security?.hasPassword == true,
                    onTap: () => _restoreLocal(context, ref),
                  ),
                  ListTile(
                    leading: const Icon(Ionicons.cloud_download_outline),
                    title: Text(l10n.backupRestoreWebDav),
                    enabled:
                        security?.hasPassword == true && backup.webdavEnabled,
                    onTap: () => _restoreWebDav(context, ref),
                  ),
                ],
              ),
              if (backup.lastBackupAt != null || backup.lastError != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 18, 12, 0),
                  child: Text(
                    backup.lastError ??
                        l10n.backupLastAt('${backup.lastBackupAt}'),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> _askPassword(BuildContext context, String title) {
    return showDialog<String>(
      context: context,
      builder: (context) => SinglePasswordDialog(title: title),
    );
  }

  Future<void> _manualBackup(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final password = await _askPassword(context, l10n.backupManual);
    if (password == null) return;
    if (!context.mounted) return;
    await _run(context, () {
      return ref.read(backupSyncProvider.notifier).manualBackup(password);
    });
  }

  Future<void> _restoreLocal(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final password = await _askPassword(context, l10n.backupRestoreLocal);
    if (password == null) return;
    if (!context.mounted) return;
    await _run(context, () {
      return ref
          .read(backupSyncProvider.notifier)
          .restoreFromLocalFile(password);
    });
  }

  Future<void> _restoreWebDav(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final password = await _askPassword(context, l10n.backupRestoreWebDav);
    if (password == null) return;
    if (!context.mounted) return;
    await _run(context, () {
      return ref.read(backupSyncProvider.notifier).restoreFromWebDav(password);
    });
  }

  Future<void> _setAuto(
    BuildContext context,
    WidgetRef ref,
    bool enabled,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final password = enabled
        ? await _askPassword(context, l10n.backupAuto)
        : null;
    if (enabled && password == null) return;
    if (!context.mounted) return;
    await _run(context, () {
      return ref
          .read(backupSyncProvider.notifier)
          .setAutoBackup(enabled, password);
    });
  }

  Future<void> _configureWebDav(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<WebDavConfig>(
      context: context,
      builder: (context) => const WebDavConfigDialog(),
    );
    if (result == null) return;
    if (!context.mounted) return;
    await _run(context, () {
      return ref
          .read(backupSyncProvider.notifier)
          .setWebDavConfig(
            url: result.url,
            username: result.username,
            password: result.password,
            remotePath: result.remotePath,
          );
    });
  }

  Future<void> _run(BuildContext context, Future<void> Function() run) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await run();
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.backupOperationDone)));
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$error')));
    }
  }
}
