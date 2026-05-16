import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/widgets/orbita_forui.dart';

Future<String?> showFileNameDialog(
  BuildContext context, {
  required String title,
  required String label,
  String initialValue = '',
}) async {
  final l10n = AppLocalizations.of(context)!;

  final result = await showOrbitaDialog<String>(
    context: context,
    builder: (context, animation) => _FileNameDialog(
      title: title,
      label: label,
      initialValue: initialValue,
      cancelLabel: l10n.commonCancel,
      confirmLabel: l10n.commonConfirm,
      animation: animation,
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
  final Animation<double> animation;

  const _FileNameDialog({
    required this.title,
    required this.label,
    required this.initialValue,
    required this.cancelLabel,
    required this.confirmLabel,
    required this.animation,
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
    return OrbitaDialog(
      animation: widget.animation,
      title: widget.title,
      actions: [
        OrbitaDialogAction(
          label: widget.cancelLabel,
          variant: FButtonVariant.outline,
          onPress: () => Navigator.of(context).pop(),
        ),
        OrbitaDialogAction(
          label: widget.confirmLabel,
          onPress: () => Navigator.of(context).pop(_controller.text.trim()),
        ),
      ],
      child: FTextField(
        control: FTextFieldControl.managed(controller: _controller),
        autofocus: true,
        label: Text(widget.label),
        textInputAction: TextInputAction.done,
        onSubmit: (_) {
          Navigator.of(context).pop(_controller.text.trim());
        },
      ),
    );
  }
}
