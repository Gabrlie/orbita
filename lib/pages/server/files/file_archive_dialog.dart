import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/models/remote_file_entry.dart';
import 'package:orbita/widgets/orbita_forui.dart';

class CompressOptions {
  final ArchiveFormat format;
  final String? password;

  const CompressOptions({required this.format, this.password});
}

Future<CompressOptions?> showCompressDialog(BuildContext context) {
  return showOrbitaDialog<CompressOptions>(
    context: context,
    builder: (context, animation) => _CompressDialog(animation: animation),
  );
}

Future<String?> showExtractPasswordDialog(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final controller = TextEditingController();
  final result = await showOrbitaDialog<String>(
    context: context,
    builder: (context, animation) => OrbitaDialog(
      animation: animation,
      title: l10n.fileExtract,
      actions: [
        OrbitaDialogAction(
          label: l10n.commonCancel,
          variant: FButtonVariant.outline,
          onPress: () => Navigator.of(context).pop(),
        ),
        OrbitaDialogAction(
          label: l10n.fileExtract,
          onPress: () => Navigator.of(context).pop(controller.text),
        ),
      ],
      child: FTextField.password(
        control: FTextFieldControl.managed(controller: controller),
        label: Text(l10n.password),
      ),
    ),
  );
  controller.dispose();
  return result;
}

class _CompressDialog extends StatefulWidget {
  final Animation<double> animation;

  const _CompressDialog({required this.animation});

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
    return OrbitaDialog(
      animation: widget.animation,
      title: l10n.fileCompress,
      actions: [
        OrbitaDialogAction(
          label: l10n.commonCancel,
          variant: FButtonVariant.outline,
          onPress: () => Navigator.of(context).pop(),
        ),
        OrbitaDialogAction(
          label: l10n.fileCompress,
          onPress: () => Navigator.of(context).pop(
            CompressOptions(
              format: _format,
              password: _format == ArchiveFormat.zip && _usePassword
                  ? _passwordController.text
                  : null,
            ),
          ),
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          OrbitaSelectMenuTile<ArchiveFormat>(
            title: l10n.fileArchiveFormat,
            value: _format,
            options: ArchiveFormat.values,
            labelBuilder: archiveFormatLabel,
            onChanged: (value) {
              setState(() {
                _format = value;
                if (_format != ArchiveFormat.zip) _usePassword = false;
              });
            },
          ),
          const SizedBox(height: 12),
          if (_format == ArchiveFormat.zip)
            OrbitaSelectMenuTile<bool>(
              title: l10n.fileUsePassword,
              value: _usePassword,
              options: const [false, true],
              labelBuilder: (value) =>
                  value ? l10n.fileWithPassword : l10n.fileNoPassword,
              subtitle: l10n.filePasswordWarning,
              onChanged: (value) => setState(() => _usePassword = value),
            ),
          if (_format == ArchiveFormat.zip && _usePassword)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: FTextField.password(
                control: FTextFieldControl.managed(
                  controller: _passwordController,
                ),
                label: Text(l10n.password),
              ),
            ),
        ],
      ),
    );
  }
}
