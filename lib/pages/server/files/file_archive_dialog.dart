import 'package:flutter/material.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/models/remote_file_entry.dart';

class CompressOptions {
  final ArchiveFormat format;
  final String? password;

  const CompressOptions({required this.format, this.password});
}

Future<CompressOptions?> showCompressDialog(BuildContext context) {
  return showDialog<CompressOptions>(
    context: context,
    builder: (context) => const _CompressDialog(),
  );
}

Future<String?> showExtractPasswordDialog(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final controller = TextEditingController();
  var usePassword = false;
  final result = await showDialog<String>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(l10n.fileExtract),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.fileUsePassword),
              value: usePassword,
              onChanged: (value) => setState(() => usePassword = value),
            ),
            if (usePassword)
              TextField(
                controller: controller,
                obscureText: true,
                decoration: InputDecoration(labelText: l10n.password),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(context).pop(usePassword ? controller.text : ''),
            child: Text(l10n.commonConfirm),
          ),
        ],
      ),
    ),
  );
  controller.dispose();
  return result;
}

class _CompressDialog extends StatefulWidget {
  const _CompressDialog();

  @override
  State<_CompressDialog> createState() => _CompressDialogState();
}

class _CompressDialogState extends State<_CompressDialog> {
  var _format = ArchiveFormat.zip;
  var _usePassword = false;
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.fileCompress),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<ArchiveFormat>(
            initialValue: _format,
            decoration: InputDecoration(labelText: l10n.fileArchiveFormat),
            items: [
              for (final format in ArchiveFormat.values)
                DropdownMenuItem(
                  value: format,
                  child: Text(archiveFormatLabel(format)),
                ),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _format = value;
                if (_format != ArchiveFormat.zip) _usePassword = false;
              });
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.fileUsePassword),
            subtitle: Text(l10n.filePasswordWarning),
            value: _usePassword,
            onChanged: _format == ArchiveFormat.zip
                ? (value) => setState(() => _usePassword = value)
                : null,
          ),
          if (_usePassword)
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: l10n.password),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(
            CompressOptions(
              format: _format,
              password: _usePassword ? _passwordController.text : null,
            ),
          ),
          child: Text(l10n.commonConfirm),
        ),
      ],
    );
  }
}
