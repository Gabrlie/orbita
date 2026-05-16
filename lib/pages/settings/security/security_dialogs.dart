import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/models/app_security.dart';
import 'package:orbita/providers/security_provider.dart';
import 'package:orbita/widgets/orbita_select_field.dart';
import 'package:orbita/widgets/orbita_forui.dart';

class PasswordDialog extends StatefulWidget {
  final String title;
  final Animation<double>? animation;

  const PasswordDialog({super.key, required this.title, this.animation});

  @override
  State<PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<PasswordDialog> {
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return OrbitaDialog(
      animation: widget.animation,
      title: widget.title,
      actions: [
        OrbitaDialogAction(
          label: l10n.commonCancel,
          variant: FButtonVariant.outline,
          onPress: () => Navigator.of(context).pop(),
        ),
        OrbitaDialogAction(
          label: l10n.commonSave,
          onPress: () => _submit(l10n),
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FTextField.password(
            control: FTextFieldControl.managed(controller: _password),
            label: Text(l10n.password),
          ),
          const SizedBox(height: 12),
          FTextField.password(
            control: FTextFieldControl.managed(controller: _confirm),
            label: Text(l10n.securityConfirmPassword),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
    );
  }

  void _submit(AppLocalizations l10n) {
    if (_password.text.length < 6) {
      setState(() => _error = l10n.securityPasswordTooShort);
      return;
    }
    if (_password.text != _confirm.text) {
      setState(() => _error = l10n.securityPasswordMismatch);
      return;
    }
    Navigator.of(context).pop(_password.text);
  }
}

class LockPolicyDialog extends StatefulWidget {
  final AppSecurityState security;
  final Animation<double>? animation;

  const LockPolicyDialog({super.key, required this.security, this.animation});

  @override
  State<LockPolicyDialog> createState() => _LockPolicyDialogState();
}

class _LockPolicyDialogState extends State<LockPolicyDialog> {
  late var _mode = widget.security.lockMode;
  late var _minutes = widget.security.lockAfterMinutes;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return OrbitaDialog(
      animation: widget.animation,
      title: l10n.securityLockPolicy,
      actions: [
        OrbitaDialogAction(
          label: l10n.commonCancel,
          variant: FButtonVariant.outline,
          onPress: () => Navigator.of(context).pop(),
        ),
        OrbitaDialogAction(
          label: l10n.commonSave,
          onPress: () =>
              Navigator.of(context).pop((mode: _mode, minutes: _minutes)),
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _modeTile(AppLockMode.never, l10n.securityLockNever),
          _modeTile(AppLockMode.onExit, l10n.securityLockOnExit),
          _modeTile(AppLockMode.afterDuration, l10n.securityLockAfterTitle),
          if (_mode == AppLockMode.afterDuration)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: OrbitaSelectField<int>(
                label: l10n.securityLockMinutes,
                value: _minutes,
                options: const [1, 5, 15, 30, 60, 120],
                labelBuilder: (minutes) => '$minutes',
                onChanged: (value) => setState(() => _minutes = value),
              ),
            ),
        ],
      ),
    );
  }

  Widget _modeTile(AppLockMode mode, String title) {
    final selected = _mode == mode;
    return FItem(
      prefix: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
      ),
      title: Text(title),
      selected: selected,
      onPress: () => _setMode(mode),
    );
  }

  void _setMode(AppLockMode? mode) {
    if (mode == null) return;
    setState(() => _mode = mode);
  }
}

Future<bool> verifySecurityPassword(
  BuildContext context,
  WidgetRef ref,
  String title,
) async {
  final l10n = AppLocalizations.of(context)!;
  final password = await showOrbitaDialog<String>(
    context: context,
    builder: (context, animation) =>
        SinglePasswordDialog(title: title, animation: animation),
  );
  if (password == null) return false;
  final key = await ref
      .read(appSecurityServiceProvider)
      .verifyPassword(password);
  if (key != null) return true;
  if (!context.mounted) return false;
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(l10n.securityInvalidPassword)));
  return false;
}

class SinglePasswordDialog extends StatefulWidget {
  final String title;
  final Animation<double>? animation;

  const SinglePasswordDialog({super.key, required this.title, this.animation});

  @override
  State<SinglePasswordDialog> createState() => _SinglePasswordDialogState();
}

class _SinglePasswordDialogState extends State<SinglePasswordDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return OrbitaDialog(
      animation: widget.animation,
      title: widget.title,
      actions: [
        OrbitaDialogAction(
          label: l10n.commonCancel,
          variant: FButtonVariant.outline,
          onPress: () => Navigator.of(context).pop(),
        ),
        OrbitaDialogAction(
          label: l10n.commonOk,
          onPress: () => Navigator.of(context).pop(_controller.text),
        ),
      ],
      child: FTextField.password(
        control: FTextFieldControl.managed(controller: _controller),
        label: Text(l10n.password),
        onSubmit: (_) => Navigator.of(context).pop(_controller.text),
      ),
    );
  }
}
