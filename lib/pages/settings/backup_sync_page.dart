import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/pages/settings/backup_sync_actions.dart';
import 'package:orbita/pages/settings/backup_sync_widgets.dart';
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
    const actions = BackupSyncActions();

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
          data: (backup) {
            final hasPassword = security?.hasPassword == true;
            return ListView(
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
                          : ref
                                .read(backupSyncProvider.notifier)
                                .setLocalEnabled,
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
                            : '${backup.webdavUrl}\n${backup.webdavRemoteFolder}',
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
                      onTap: () =>
                          actions.configureWebDav(context, ref, backup),
                    ),
                    ListTile(
                      leading: const Icon(Ionicons.pulse_outline),
                      title: Text(l10n.backupTestWebDav),
                      enabled: backup.webdavUrl.isNotEmpty,
                      onTap: () => actions.run(
                        context,
                        () {
                          return ref
                              .read(backupSyncProvider.notifier)
                              .testWebDav();
                        },
                        successMessage: l10n.backupWebDavConnected,
                        errorMessageBuilder: (error) {
                          return l10n.backupWebDavFailed('$error');
                        },
                      ),
                    ),
                  ],
                ),
                SectionHeader(
                  title: l10n.backupOperations,
                  padding: const EdgeInsets.fromLTRB(12, 24, 12, 8),
                ),
                BackupPanel(
                  children: [
                    if (!hasPassword)
                      ListTile(
                        leading: const Icon(Ionicons.lock_closed_outline),
                        title: Text(l10n.backupPasswordSetupRequired),
                        subtitle: Text(l10n.backupPasswordSetupDesc),
                      ),
                    SwitchListTile(
                      secondary: const Icon(Ionicons.sync_outline),
                      title: Text(l10n.backupAuto),
                      subtitle: Text(
                        hasPassword
                            ? l10n.backupAutoDesc
                            : l10n.backupPasswordSetupRequired,
                      ),
                      value: hasPassword && backup.autoBackupEnabled,
                      onChanged: hasPassword
                          ? (value) => actions.setAuto(context, ref, value)
                          : null,
                    ),
                    ListTile(
                      leading: const Icon(Ionicons.time_outline),
                      title: Text(l10n.backupAutoTime),
                      subtitle: Text(
                        l10n.backupAutoTimeDesc(
                          _formatBackupTime(
                            context,
                            backup.autoBackupTimeMinutes,
                          ),
                        ),
                      ),
                      enabled: hasPassword && backup.autoBackupEnabled,
                      onTap: hasPassword && backup.autoBackupEnabled
                          ? () =>
                                actions.setAutoBackupTime(context, ref, backup)
                          : null,
                    ),
                    ListTile(
                      leading: const Icon(Ionicons.layers_outline),
                      title: Text(l10n.backupRetentionCount),
                      subtitle: Text(
                        l10n.backupRetentionDesc(backup.retentionCount),
                      ),
                      enabled: hasPassword,
                      onTap: hasPassword
                          ? () => actions.setRetention(context, ref, backup)
                          : null,
                    ),
                    ListTile(
                      leading: const Icon(Ionicons.archive_outline),
                      title: Text(l10n.backupManual),
                      subtitle: Text(l10n.backupPasswordRequired),
                      enabled: hasPassword,
                      onTap: hasPassword
                          ? () => actions.manualBackup(context, ref, backup)
                          : null,
                    ),
                    ListTile(
                      leading: const Icon(Ionicons.download_outline),
                      title: Text(l10n.backupRestoreLocal),
                      enabled: hasPassword,
                      onTap: hasPassword
                          ? () => actions.restoreLocal(context, ref)
                          : null,
                    ),
                    ListTile(
                      leading: const Icon(Ionicons.cloud_download_outline),
                      title: Text(l10n.backupRestoreWebDav),
                      enabled: hasPassword && backup.webdavEnabled,
                      onTap: hasPassword && backup.webdavEnabled
                          ? () => actions.restoreWebDav(context, ref, backup)
                          : null,
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
            );
          },
        ),
      ),
    );
  }

  String _formatBackupTime(BuildContext context, int minutes) {
    return TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60).format(context);
  }
}
