import 'package:flutter/material.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/widgets/common.dart';

class BackupPanel extends StatelessWidget {
  final List<Widget> children;

  const BackupPanel({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: tonalItemColor(context),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const Divider(height: 1, indent: 24, endIndent: 24),
            children[i],
          ],
        ],
      ),
    );
  }
}

class WebDavConfig {
  final String url;
  final String username;
  final String password;
  final String remotePath;

  const WebDavConfig(this.url, this.username, this.password, this.remotePath);
}

class WebDavConfigDialog extends StatefulWidget {
  const WebDavConfigDialog({super.key});

  @override
  State<WebDavConfigDialog> createState() => _WebDavConfigDialogState();
}

class _WebDavConfigDialogState extends State<WebDavConfigDialog> {
  final _url = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _remotePath = TextEditingController(text: '/orbita-backup.json');

  @override
  void dispose() {
    _url.dispose();
    _username.dispose();
    _password.dispose();
    _remotePath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.backupWebDavConfig),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _url,
              decoration: InputDecoration(labelText: l10n.backupWebDavUrl),
            ),
            TextField(
              controller: _username,
              decoration: InputDecoration(labelText: l10n.backupWebDavUsername),
            ),
            TextField(
              controller: _password,
              obscureText: true,
              decoration: InputDecoration(labelText: l10n.password),
            ),
            TextField(
              controller: _remotePath,
              decoration: InputDecoration(labelText: l10n.backupWebDavPath),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(
            WebDavConfig(
              _url.text,
              _username.text,
              _password.text,
              _remotePath.text,
            ),
          ),
          child: Text(l10n.commonSave),
        ),
      ],
    );
  }
}
