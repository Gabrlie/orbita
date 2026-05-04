import 'package:flutter/material.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/widgets/remote_script_output_dialog.dart';

class FileToolInstallDialog extends StatelessWidget {
  final List<String> tools;
  final Future<void> Function(void Function(String chunk) onOutput) onInstall;

  const FileToolInstallDialog({
    super.key,
    required this.tools,
    required this.onInstall,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return RemoteScriptOutputDialog(
      title: l10n.fileInstallingTools(tools.join(', ')),
      successMessage: l10n.fileInstallSucceeded,
      failureMessage: l10n.fileInstallFailed,
      onRun: onInstall,
    );
  }
}
