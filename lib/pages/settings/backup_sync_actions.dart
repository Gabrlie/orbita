import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/models/backup_models.dart';
import 'package:orbita/pages/settings/backup_sync_widgets.dart';
import 'package:orbita/pages/settings/security/security_dialogs.dart';
import 'package:orbita/providers/backup_sync_provider.dart';

class BackupSyncActions {
  const BackupSyncActions();

  Future<void> manualBackup(
    BuildContext context,
    WidgetRef ref,
    BackupSettings backup,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    if (!_hasConfiguredTarget(backup)) {
      _showMessage(context, l10n.backupNoTarget);
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
      _showMessage(context, l10n.backupWebDavUnset);
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
    final picked = await showTimePicker(context: context, initialTime: current);
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
    final result = await showDialog<WebDavConfig>(
      context: context,
      builder: (context) => WebDavConfigDialog(
        url: backup.webdavUrl,
        username: backup.webdavUsername,
        remoteFolder: backup.webdavRemoteFolder,
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
      _showMessage(context, successMessage ?? l10n.backupOperationDone);
    } catch (error) {
      if (!context.mounted) return;
      _showMessage(
        context,
        errorMessageBuilder?.call(error) ?? _messageFor(error, l10n),
      );
    }
  }

  void showPasswordRequired(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    _showMessage(context, l10n.backupPasswordSetupRequired);
  }

  Future<String?> _askPassword(BuildContext context, String title) {
    return showDialog<String>(
      context: context,
      builder: (context) => SinglePasswordDialog(title: title),
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
        _showMessage(context, l10n.backupRestoreDone);
        return;
      }
    } catch (error) {
      if (!context.mounted) return;
      _showMessage(context, l10n.backupRestoreFailed(_messageFor(error, l10n)));
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
          l10n.backupRestoreFailed(_messageFor(error, l10n)),
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
        _showMessage(context, l10n.backupNoBackups);
        return null;
      }
      return showDialog<BackupEntry>(
        context: context,
        builder: (context) => BackupSelectDialog(
          title: l10n.backupSelectBackup,
          entries: entries,
        ),
      );
    } catch (error) {
      if (context.mounted) _showMessage(context, _messageFor(error, l10n));
      return null;
    }
  }

  bool _hasConfiguredTarget(BackupSettings backup) {
    return (backup.localEnabled && backup.localFolder.isNotEmpty) ||
        (backup.webdavEnabled && backup.webdavUrl.isNotEmpty);
  }

  void _showMessage(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  String _messageFor(Object error, AppLocalizations l10n) {
    if (error is BackupException) {
      return switch (error.message) {
        BackupException.invalidPassword => l10n.backupInvalidPassword,
        BackupException.invalidSnapshot => l10n.backupInvalidSnapshot,
        BackupException.noTarget => l10n.backupNoTarget,
        BackupException.passwordRequired => l10n.backupPasswordSetupRequired,
        _ => error.message,
      };
    }
    return '$error';
  }
}
