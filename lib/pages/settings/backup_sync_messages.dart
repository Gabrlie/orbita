import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/models/backup_models.dart';

OverlayEntry? _activeBackupMessage;
Timer? _activeBackupMessageTimer;

void showBackupSyncMessage(
  BuildContext context,
  String message, {
  FAlertVariant variant = FAlertVariant.primary,
}) {
  _activeBackupMessage?.remove();
  _activeBackupMessageTimer?.cancel();

  final overlay = Overlay.of(context);
  final top = MediaQuery.paddingOf(context).top + 12;
  final entry = OverlayEntry(
    builder: (context) => Positioned(
      top: top,
      left: 16,
      right: 16,
      child: SafeArea(
        bottom: false,
        child: FAlert(
          variant: variant,
          icon: Icon(
            variant == FAlertVariant.destructive
                ? Ionicons.alert_circle_outline
                : Ionicons.information_circle_outline,
          ),
          title: Text(message),
        ),
      ),
    ),
  );
  _activeBackupMessage = entry;
  overlay.insert(entry);
  _activeBackupMessageTimer = Timer(const Duration(seconds: 2), () {
    entry.remove();
    if (_activeBackupMessage == entry) _activeBackupMessage = null;
  });
}

String backupSyncMessageFor(Object error, AppLocalizations l10n) {
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
