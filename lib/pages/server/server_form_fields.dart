import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:orbita/l10n/app_localizations.dart';

class ServerDirectEndpointFields extends StatelessWidget {
  final TextEditingController hostController;
  final TextEditingController portController;

  const ServerDirectEndpointFields({
    super.key,
    required this.hostController,
    required this.portController,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 520) {
          return Column(
            children: [
              _ServerHostField(controller: hostController),
              const SizedBox(height: 12),
              ServerPortField(controller: portController),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: _ServerHostField(controller: hostController),
            ),
            const SizedBox(width: 12),
            Expanded(child: ServerPortField(controller: portController)),
          ],
        );
      },
    );
  }
}

class ServerPortField extends StatelessWidget {
  final TextEditingController controller;

  const ServerPortField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FTextFormField(
      control: FTextFieldControl.managed(controller: controller),
      label: Text(l10n.serverPort),
      keyboardType: TextInputType.number,
      validator: (v) {
        final p = int.tryParse(v ?? '');
        if (p == null || p < 1 || p > 65535) {
          return l10n.validationInvalidPort;
        }
        return null;
      },
    );
  }
}

class _ServerHostField extends StatelessWidget {
  final TextEditingController controller;

  const _ServerHostField({required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FTextFormField(
      control: FTextFieldControl.managed(controller: controller),
      label: Text(l10n.serverHost),
      validator: (v) {
        if (v == null || v.trim().isEmpty) {
          return l10n.validationRequired;
        }
        if (v.contains(' ')) {
          return l10n.validationInvalidHost;
        }
        return null;
      },
    );
  }
}
