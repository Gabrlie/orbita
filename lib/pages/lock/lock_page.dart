import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/providers/security_provider.dart';

class LockPage extends ConsumerStatefulWidget {
  final bool redirectOnUnlock;

  const LockPage({super.key, this.redirectOnUnlock = false});

  @override
  ConsumerState<LockPage> createState() => _LockPageState();
}

class _LockPageState extends ConsumerState<LockPage> {
  final _controller = TextEditingController();
  var _busy = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final security = ref.watch(appSecurityProvider);
    final theme = Theme.of(context);

    if (security.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final state = security.value;
    if (state == null || !state.hasPassword) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted && widget.redirectOnUnlock) context.go('/home');
      });
      return const SizedBox.shrink();
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(
                    'assets/images/orbita_icon.png',
                    width: 86,
                    height: 86,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    l10n.appName,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 34),
                  TextField(
                    controller: _controller,
                    obscureText: true,
                    enabled: !_busy,
                    autofocus: true,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: l10n.password,
                      errorText: _error,
                      border: const OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _unlockWithPassword(l10n),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _busy ? null : () => _unlockWithPassword(l10n),
                    child: Text(_busy ? l10n.securityChecking : l10n.unlock),
                  ),
                  if (state.biometricEnabled) ...[
                    const SizedBox(height: 10),
                    TextButton.icon(
                      onPressed: _busy
                          ? null
                          : () => _unlockWithBiometrics(l10n),
                      icon: const Icon(Icons.fingerprint),
                      label: Text(l10n.useBiometrics),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _unlockWithPassword(AppLocalizations l10n) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final ok = await ref
        .read(appSecurityProvider.notifier)
        .unlockWithPassword(_controller.text);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = ok ? null : l10n.securityInvalidPassword;
    });
    if (ok && widget.redirectOnUnlock) context.go('/home');
  }

  Future<void> _unlockWithBiometrics(AppLocalizations l10n) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final ok = await ref
        .read(appSecurityProvider.notifier)
        .unlockWithBiometrics(l10n.securityBiometricReason);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = ok ? null : l10n.securityBiometricFailed;
    });
    if (ok && widget.redirectOnUnlock) context.go('/home');
  }
}
