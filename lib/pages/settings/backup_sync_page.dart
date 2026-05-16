import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/pages/settings/backup_sync_actions.dart';
import 'package:orbita/providers/backup_sync_provider.dart';
import 'package:orbita/providers/security_provider.dart';
import 'package:orbita/widgets/common.dart';
import 'package:orbita/widgets/orbita_forui.dart';
import 'package:orbita/widgets/settings_tiles.dart';

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
                if (!hasPassword)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
                    child: FAlert(
                      variant: FAlertVariant.destructive,
                      icon: const Icon(Ionicons.lock_closed_outline),
                      title: Text(l10n.backupPasswordSetupRequired),
                      subtitle: Text(l10n.backupPasswordSetupDesc),
                    ),
                  ),
                if (backup.lastBackupAt != null || backup.lastError != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
                    child: FAlert(
                      variant: backup.lastError == null
                          ? FAlertVariant.primary
                          : FAlertVariant.destructive,
                      icon: Icon(
                        backup.lastError == null
                            ? Ionicons.checkmark_circle_outline
                            : Ionicons.alert_circle_outline,
                      ),
                      title: Text(
                        backup.lastError == null
                            ? l10n.backupOperationDone
                            : l10n.commonActionFailed,
                      ),
                      subtitle: Text(
                        backup.lastError ??
                            l10n.backupLastAt('${backup.lastBackupAt}'),
                      ),
                    ),
                  ),
                OrbitaSettingsTileGroup(
                  title: l10n.backupLocalFolder,
                  padding: EdgeInsets.zero,
                  children: [
                    orbitaSettingsSwitchTile(
                      context,
                      icon: Ionicons.folder_open_outline,
                      title: l10n.backupLocalFolder,
                      subtitle: backup.localFolder.isEmpty
                          ? l10n.backupLocalFolderUnset
                          : backup.localFolder,
                      value: backup.localEnabled,
                      enabled: backup.localFolder.isNotEmpty,
                      onChanged: ref
                          .read(backupSyncProvider.notifier)
                          .setLocalEnabled,
                    ),
                    orbitaSettingsTile(
                      context,
                      icon: Ionicons.folder_outline,
                      title: l10n.backupChooseFolder,
                      onPress: ref
                          .read(backupSyncProvider.notifier)
                          .pickLocalFolder,
                    ),
                  ],
                ),
                OrbitaSettingsTileGroup(
                  title: l10n.backupRemoteSection,
                  children: [
                    orbitaSettingsSwitchTile(
                      context,
                      icon: Ionicons.cloud_upload_outline,
                      title: l10n.backupWebDav,
                      subtitle: backup.webdavUrl.isEmpty
                          ? l10n.backupWebDavUnset
                          : '${backup.webdavUrl}\n${backup.webdavRemoteFolder}',
                      value: backup.webdavEnabled,
                      enabled: backup.webdavUrl.isNotEmpty,
                      onChanged: ref
                          .read(backupSyncProvider.notifier)
                          .setWebDavEnabled,
                    ),
                    orbitaSettingsTile(
                      context,
                      icon: Ionicons.settings_outline,
                      title: l10n.backupWebDavConfig,
                      onPress: () =>
                          actions.configureWebDav(context, ref, backup),
                    ),
                    orbitaSettingsTile(
                      context,
                      icon: Ionicons.pulse_outline,
                      title: l10n.backupTestWebDav,
                      enabled: backup.webdavUrl.isNotEmpty,
                      onPress: () => actions.run(
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
                OrbitaSettingsTileGroup(
                  title: l10n.backupOperations,
                  children: [
                    orbitaSettingsSwitchTile(
                      context,
                      icon: Ionicons.sync_outline,
                      title: l10n.backupAuto,
                      subtitle: hasPassword
                          ? l10n.backupAutoDesc
                          : l10n.backupPasswordSetupRequired,
                      value: hasPassword && backup.autoBackupEnabled,
                      enabled: hasPassword,
                      onChanged: (value) => actions.setAuto(context, ref, value),
                    ),
                    OrbitaSelectMenuTile<int>(
                      title: l10n.backupRetentionCount,
                      value: backup.retentionCount,
                      options: _retentionOptions(backup.retentionCount),
                      labelBuilder: (count) => '$count',
                      subtitle: l10n.backupRetentionDesc(
                        backup.retentionCount,
                      ),
                      prefix: const Icon(Ionicons.layers_outline),
                      enabled: hasPassword,
                      onChanged: ref
                          .read(backupSyncProvider.notifier)
                          .setRetentionCount,
                    ),
                    orbitaSettingsTile(
                      context,
                      icon: Ionicons.archive_outline,
                      title: l10n.backupManual,
                      subtitle: l10n.backupPasswordRequired,
                      enabled: hasPassword,
                      onPress: hasPassword
                          ? () => actions.manualBackup(context, ref, backup)
                          : null,
                    ),
                    orbitaSettingsTile(
                      context,
                      icon: Ionicons.download_outline,
                      title: l10n.backupRestoreLocal,
                      enabled: hasPassword,
                      onPress: hasPassword
                          ? () => actions.restoreLocal(context, ref)
                          : null,
                    ),
                    orbitaSettingsTile(
                      context,
                      icon: Ionicons.cloud_download_outline,
                      title: l10n.backupRestoreWebDav,
                      enabled: hasPassword && backup.webdavEnabled,
                      onPress: hasPassword && backup.webdavEnabled
                          ? () => actions.restoreWebDav(context, ref, backup)
                          : null,
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<int> _retentionOptions(int current) {
    final options = {1, 2, 3, 5, 7, 10, 20, 50, 100, current}.toList();
    options.sort();
    return options;
  }
}
