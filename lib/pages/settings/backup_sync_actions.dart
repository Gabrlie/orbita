import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/models/backup_models.dart';
import 'package:orbita/pages/settings/backup_sync_messages.dart';
import 'package:orbita/pages/settings/backup_sync_time_picker.dart';
import 'package:orbita/pages/settings/backup_sync_widgets.dart';
import 'package:orbita/pages/settings/security/security_dialogs.dart';
import 'package:orbita/providers/backup_sync_provider.dart';
import 'package:orbita/widgets/orbita_forui.dart';

class BackupSyncActions {
  const BackupSyncActions();

  Future<void> manualBackup(
    BuildContext context,
    WidgetRef ref,
    BackupSettings backup,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    if (!_hasConfiguredTarget(backup)) {
      showBackupSyncMessage(
        context,
        l10n.backupNoTarget,
        variant: FAlertVariant.destructive,
      );
      return;
    }
    await run(context, () {
      return ref.read(backupSyncProvider.notifier).manualBackup();
    });
  }

  Future<void> restoreLocal(BuildContext context, WidgetRef ref) async {
    final entry = await _selectBackup(
      context,
      () => ref.read(backupSyncProvider.notifier).listLocalBackups(),
    );
    if (entry == null || !context.mounted) return;
    await _restoreSelected(context, ref, entry);
  }

  Future<void> restoreWebDav(
    BuildContext context,
    WidgetRef ref,
    BackupSettings backup,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    if (!backup.webdavEnabled || backup.webdavUrl.isEmpty) {
      showBackupSyncMessage(
        context,
        l10n.backupWebDavUnset,
        variant: FAlertVariant.destructive,
      );
      return;
    }
    final entry = await _selectBackup(
      context,
      () => ref.read(backupSyncProvider.notifier).listWebDavBackups(),
    );
    if (entry == null || !context.mounted) return;
    await _restoreSelected(context, ref, entry);
  }

  Future<void> setAuto(
    BuildContext context,
    WidgetRef ref,
    bool enabled,
  ) async {
    if (!enabled) {
      await run(context, () {
        return ref.read(backupSyncProvider.notifier).setAutoBackup(false);
      });
      return;
    }
    await run(context, () {
      return ref.read(backupSyncProvider.notifier).setAutoBackup(true);
    });
  }

  Future<void> setAutoBackupTime(
    BuildContext context,
    WidgetRef ref,
    BackupSettings backup,
  ) async {
    final current = TimeOfDay(
      hour: backup.autoBackupTimeMinutes ~/ 60,
      minute: backup.autoBackupTimeMinutes % 60,
    );
    final picked = await pickBackupAutoTime(context, current);
    if (picked == null || !context.mounted) return;
    await run(context, () {
      return ref
          .read(backupSyncProvider.notifier)
          .setAutoBackupTime(picked.hour * 60 + picked.minute);
    });
  }

  Future<void> configureWebDav(
    BuildContext context,
    WidgetRef ref,
    BackupSettings backup,
  ) async {
    final result = await showOrbitaDialog<WebDavConfig>(
      context: context,
      builder: (context, animation) => WebDavConfigDialog(
        url: backup.webdavUrl,
        username: backup.webdavUsername,
        remoteFolder: backup.webdavRemoteFolder,
        animation: animation,
      ),
    );
    if (result == null || !context.mounted) return;
    await run(context, () {
      return ref
          .read(backupSyncProvider.notifier)
          .setWebDavConfig(
            url: result.url,
            username: result.username,
            password: result.password,
            remoteFolder: result.remoteFolder,
          );
    });
  }

  Future<void> run(
    BuildContext context,
    Future<void> Function() action, {
    String? successMessage,
    String Function(Object error)? errorMessageBuilder,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await action();
      if (!context.mounted) return;
      showBackupSyncMessage(
        context,
        successMessage ?? l10n.backupOperationDone,
      );
    } catch (error) {
      if (!context.mounted) return;
      showBackupSyncMessage(
        context,
        errorMessageBuilder?.call(error) ?? backupSyncMessageFor(error, l10n),
        variant: FAlertVariant.destructive,
      );
    }
  }

  void showPasswordRequired(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showBackupSyncMessage(
      context,
      l10n.backupPasswordSetupRequired,
      variant: FAlertVariant.destructive,
    );
  }

  Future<String?> _askPassword(BuildContext context, String title) {
    return showOrbitaDialog<String>(
      context: context,
      builder: (context, animation) =>
          SinglePasswordDialog(title: title, animation: animation),
    );
  }

  Future<void> _restoreSelected(
    BuildContext context,
    WidgetRef ref,
    BackupEntry entry,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final restored = await ref
          .read(backupSyncProvider.notifier)
          .restoreBackupSilently(entry);
      if (!context.mounted) return;
      if (restored) {
        showBackupSyncMessage(context, l10n.backupRestoreDone);
        return;
      }
    } catch (error) {
      if (!context.mounted) return;
      showBackupSyncMessage(
        context,
        l10n.backupRestoreFailed(backupSyncMessageFor(error, l10n)),
        variant: FAlertVariant.destructive,
      );
      return;
    }

    final password = await _askPassword(
      context,
      l10n.backupRestorePasswordPrompt,
    );
    if (password == null || !context.mounted) return;
    await run(
      context,
      () {
        return ref
            .read(backupSyncProvider.notifier)
            .restoreBackup(entry, password);
      },
      successMessage: l10n.backupRestoreDone,
      errorMessageBuilder: (error) =>
          l10n.backupRestoreFailed(backupSyncMessageFor(error, l10n)),
    );
  }

  Future<BackupEntry?> _selectBackup(
    BuildContext context,
    Future<List<BackupEntry>> Function() load,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final entries = await load();
      if (!context.mounted) return null;
      if (entries.isEmpty) {
        showBackupSyncMessage(
          context,
          l10n.backupNoBackups,
          variant: FAlertVariant.destructive,
        );
        return null;
      }
      return showOrbitaDialog<BackupEntry>(
        context: context,
        builder: (context, animation) => BackupSelectDialog(
          title: l10n.backupSelectBackup,
          entries: entries,
          animation: animation,
        ),
      );
    } catch (error) {
      if (context.mounted) {
        showBackupSyncMessage(
          context,
          backupSyncMessageFor(error, l10n),
          variant: FAlertVariant.destructive,
        );
      }
      return null;
    }
  }

  bool _hasConfiguredTarget(BackupSettings backup) {
    return (backup.localEnabled && backup.localFolder.isNotEmpty) ||
        (backup.webdavEnabled && backup.webdavUrl.isNotEmpty);
  }
}
