import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/models/app_security.dart';
import 'package:orbita/providers/security_provider.dart';
import 'package:orbita/widgets/orbita_select_field.dart';

class PasswordDialog extends StatefulWidget {
  final String title;

  const PasswordDialog({super.key, required this.title});

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
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _password,
            obscureText: true,
            decoration: InputDecoration(labelText: l10n.password),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _confirm,
            obscureText: true,
            decoration: InputDecoration(
              labelText: l10n.securityConfirmPassword,
            ),
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
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: () => _submit(l10n),
          child: Text(l10n.commonSave),
        ),
      ],
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

  const LockPolicyDialog({super.key, required this.security});

  @override
  State<LockPolicyDialog> createState() => _LockPolicyDialogState();
}

class _LockPolicyDialogState extends State<LockPolicyDialog> {
  late var _mode = widget.security.lockMode;
  late var _minutes = widget.security.lockAfterMinutes;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.securityLockPolicy),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _modeTile(AppLockMode.never, l10n.securityLockNever),
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
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.of(context).pop((mode: _mode, minutes: _minutes)),
          child: Text(l10n.commonSave),
        ),
      ],
    );
  }

  Widget _modeTile(AppLockMode mode, String title) {
    final selected = _mode == mode;
    return ListTile(
      leading: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
      ),
      title: Text(title),
      selected: selected,
      onTap: () => _setMode(mode),
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
  final password = await showDialog<String>(
    context: context,
    builder: (context) => SinglePasswordDialog(title: title),
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

  const SinglePasswordDialog({super.key, required this.title});

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
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        obscureText: true,
        decoration: InputDecoration(labelText: l10n.password),
        onSubmitted: (_) => Navigator.of(context).pop(_controller.text),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: Text(l10n.commonOk),
        ),
      ],
    );
  }
}
