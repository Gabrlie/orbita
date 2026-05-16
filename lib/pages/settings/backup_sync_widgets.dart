import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/models/backup_models.dart';
import 'package:orbita/widgets/orbita_forui.dart';

class WebDavConfig {
  final String url;
  final String username;
  final String password;
  final String remoteFolder;

  const WebDavConfig(this.url, this.username, this.password, this.remoteFolder);
}

class WebDavConfigDialog extends StatefulWidget {
  final String url;
  final String username;
  final String remoteFolder;
  final Animation<double>? animation;

  const WebDavConfigDialog({
    super.key,
    this.url = '',
    this.username = '',
    this.remoteFolder = '/orbita',
    this.animation,
  });

  @override
  State<WebDavConfigDialog> createState() => _WebDavConfigDialogState();
}

class _WebDavConfigDialogState extends State<WebDavConfigDialog> {
  late final _url = TextEditingController(text: widget.url);
  late final _username = TextEditingController(text: widget.username);
  final _password = TextEditingController();
  late final _remoteFolder = TextEditingController(
    text: widget.remoteFolder.isEmpty ? '/orbita' : widget.remoteFolder,
  );

  @override
  void dispose() {
    _url.dispose();
    _username.dispose();
    _password.dispose();
    _remoteFolder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return OrbitaDialog(
      animation: widget.animation,
      title: l10n.backupWebDavConfig,
      actions: [
        OrbitaDialogAction(
          label: l10n.commonCancel,
          variant: FButtonVariant.outline,
          onPress: () => Navigator.of(context).pop(),
        ),
        OrbitaDialogAction(
          label: l10n.commonSave,
          onPress: () => Navigator.of(context).pop(
            WebDavConfig(
              _url.text,
              _username.text,
              _password.text,
              _remoteFolder.text,
            ),
          ),
        ),
      ],
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FTextField(
              control: FTextFieldControl.managed(controller: _url),
              label: Text(l10n.backupWebDavUrl),
            ),
            const SizedBox(height: 12),
            FTextField(
              control: FTextFieldControl.managed(controller: _username),
              label: Text(l10n.backupWebDavUsername),
            ),
            const SizedBox(height: 12),
            FTextField.password(
              control: FTextFieldControl.managed(controller: _password),
              label: Text(l10n.password),
            ),
            const SizedBox(height: 12),
            FTextField(
              control: FTextFieldControl.managed(controller: _remoteFolder),
              label: Text(l10n.backupWebDavFolder),
            ),
          ],
        ),
      ),
    );
  }
}

class BackupSelectDialog extends StatelessWidget {
  final String title;
  final List<BackupEntry> entries;
  final Animation<double>? animation;

  const BackupSelectDialog({
    super.key,
    required this.title,
    required this.entries,
    this.animation,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final formatter = MaterialLocalizations.of(context);
    return OrbitaDialog(
      animation: animation,
      title: title,
      actions: [
        OrbitaDialogAction(
          label: l10n.commonCancel,
          variant: FButtonVariant.outline,
          onPress: () => Navigator.of(context).pop(),
        ),
      ],
      child: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListView.separated(
              shrinkWrap: true,
              itemCount: entries.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final entry = entries[index];
                final icon = entry.location == BackupLocation.local
                    ? Ionicons.folder_outline
                    : Ionicons.cloud_outline;
                final date = formatter.formatFullDate(entry.modifiedAt);
                final time = formatter.formatTimeOfDay(
                  TimeOfDay.fromDateTime(entry.modifiedAt),
                );
                return FItem(
                  prefix: Icon(icon),
                  title: Text(entry.name),
                  subtitle: Text('$date $time'),
                  onPress: () => Navigator.of(context).pop(entry),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
