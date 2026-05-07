import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/models/backup_models.dart';
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
  final String remoteFolder;

  const WebDavConfig(this.url, this.username, this.password, this.remoteFolder);
}

class WebDavConfigDialog extends StatefulWidget {
  final String url;
  final String username;
  final String remoteFolder;

  const WebDavConfigDialog({
    super.key,
    this.url = '',
    this.username = '',
    this.remoteFolder = '/orbita',
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
            const SizedBox(height: 12),
            TextField(
              controller: _username,
              decoration: InputDecoration(labelText: l10n.backupWebDavUsername),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _password,
              obscureText: true,
              decoration: InputDecoration(labelText: l10n.password),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _remoteFolder,
              decoration: InputDecoration(labelText: l10n.backupWebDavFolder),
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
              _remoteFolder.text,
            ),
          ),
          child: Text(l10n.commonSave),
        ),
      ],
    );
  }
}

class BackupSelectDialog extends StatelessWidget {
  final String title;
  final List<BackupEntry> entries;

  const BackupSelectDialog({
    super.key,
    required this.title,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = MaterialLocalizations.of(context);
    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.separated(
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
            return ListTile(
              leading: Icon(icon),
              title: Text(entry.name),
              subtitle: Text('$date $time'),
              onTap: () => Navigator.of(context).pop(entry),
            );
          },
        ),
      ),
    );
  }
}

class BackupRetentionDialog extends StatefulWidget {
  final int initialValue;

  const BackupRetentionDialog({super.key, required this.initialValue});

  @override
  State<BackupRetentionDialog> createState() => _BackupRetentionDialogState();
}

class _BackupRetentionDialogState extends State<BackupRetentionDialog> {
  late final _controller = TextEditingController(
    text: widget.initialValue.toString(),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.backupRetentionTitle),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: l10n.backupRetentionCount,
          helperText: l10n.backupRetentionHelp,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: () {
            final count = int.tryParse(_controller.text) ?? widget.initialValue;
            Navigator.of(context).pop(count);
          },
          child: Text(l10n.commonSave),
        ),
      ],
    );
  }
}
