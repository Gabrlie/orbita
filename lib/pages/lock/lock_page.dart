import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/providers/settings_provider.dart';

class LockPage extends ConsumerWidget {
  const LockPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final hasPassword = ref.watch(hasPasswordProvider);

    // If no password set, redirect immediately.
    if (!hasPassword) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/home');
      });
      return const SizedBox.shrink();
    }

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.public, size: 80, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                l10n.appName,
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: 300,
                child: TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: l10n.password,
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 300,
                child: FilledButton(
                  onPressed: () {
                    ref.read(isUnlockedProvider.notifier).unlock();
                    context.go('/home');
                  },
                  child: Text(l10n.unlock),
                ),
              ),
              const SizedBox(height: 24),
              TextButton.icon(
                onPressed: () {
                  ref.read(isUnlockedProvider.notifier).unlock();
                  context.go('/home');
                },
                icon: const Icon(Icons.fingerprint),
                label: Text(l10n.useBiometrics),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
