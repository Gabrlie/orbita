import 'package:flutter/material.dart';
import 'package:orbita/l10n/app_localizations.dart';

Future<String?> showFileNameDialog(
  BuildContext context, {
  required String title,
  required String label,
  String initialValue = '',
}) async {
  final l10n = AppLocalizations.of(context)!;

  final result = await showDialog<String>(
    context: context,
    builder: (context) => _FileNameDialog(
      title: title,
      label: label,
      initialValue: initialValue,
      cancelLabel: l10n.commonCancel,
      confirmLabel: l10n.commonConfirm,
    ),
  );

  if (result == null || result.trim().isEmpty) return null;
  return result.trim();
}

class _FileNameDialog extends StatefulWidget {
  final String title;
  final String label;
  final String initialValue;
  final String cancelLabel;
  final String confirmLabel;

  const _FileNameDialog({
    required this.title,
    required this.label,
    required this.initialValue,
    required this.cancelLabel,
    required this.confirmLabel,
  });

  @override
  State<_FileNameDialog> createState() => _FileNameDialogState();
}

class _FileNameDialogState extends State<_FileNameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(labelText: widget.label),
        textInputAction: TextInputAction.done,
        onSubmitted: (_) {
          Navigator.of(context).pop(_controller.text.trim());
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(widget.cancelLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}
