import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/models/app_security.dart';
import 'package:orbita/pages/settings/security/security_dialogs.dart';
import 'package:orbita/pages/settings/security/security_widgets.dart';
import 'package:orbita/providers/security_provider.dart';
import 'package:orbita/widgets/common.dart';

class SecurityPage extends ConsumerWidget {
  const SecurityPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(appSecurityProvider);

    return Scaffold(
      appBar: compactPageAppBar(
        context,
        title: l10n.securityTitle,
        fallbackLocation: '/settings',
      ),
      body: TonalListBackground(
        child: state.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('$error')),
          data: (security) => _SecurityContent(security: security),
        ),
      ),
    );
  }
}

class _SecurityContent extends ConsumerWidget {
  final AppSecurityState security;

  const _SecurityContent({required this.security});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        SectionHeader(
          title: l10n.securityCurrentTier,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        ),
        SecurityPanel(
          children: [
            SecurityInfoTile(
              icon: Ionicons.phone_portrait_outline,
              title: l10n.securityDeviceEncryption,
              subtitle: l10n.securityDeviceEncryptionDesc,
              trailing: const Icon(Ionicons.checkmark_circle_outline),
            ),
            SecurityInfoTile(
              icon: Ionicons.lock_closed_outline,
              title: l10n.securityAppPassword,
              subtitle: security.hasPassword
                  ? l10n.securityAppPasswordEnabled
                  : l10n.securityAppPasswordDisabled,
              trailing: FilledButton.tonal(
                onPressed: () => _showPasswordDialog(context, ref),
                child: Text(
                  security.hasPassword
                      ? l10n.securityChangePassword
                      : l10n.securitySetPassword,
                ),
              ),
            ),
          ],
        ),
        SectionHeader(
          title: l10n.securityUnlockSection,
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
        ),
        SecurityPanel(
          children: [
            SwitchListTile(
              secondary: const Icon(Ionicons.finger_print_outline),
              title: Text(l10n.securityBiometric),
              subtitle: Text(l10n.securityBiometricDesc),
              value: security.biometricEnabled,
              onChanged: security.hasPassword
                  ? (value) => _setBiometric(context, ref, value)
                  : null,
            ),
            ListTile(
              leading: const Icon(Ionicons.timer_outline),
              title: Text(l10n.securityLockPolicy),
              subtitle: Text(_lockPolicyText(l10n, security)),
              onTap: () => _showLockPolicyDialog(context, ref),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (security.hasPassword)
          OutlinedButton.icon(
            onPressed: () => _clearPassword(context, ref),
            icon: const Icon(Ionicons.trash_outline),
            label: Text(l10n.securityRemovePassword),
          ),
      ],
    );
  }

  String _lockPolicyText(AppLocalizations l10n, AppSecurityState state) {
    return switch (state.lockMode) {
      AppLockMode.never => l10n.securityLockNever,
      AppLockMode.onExit => l10n.securityLockOnExit,
      AppLockMode.afterDuration => l10n.securityLockAfterMinutes(
        state.lockAfterMinutes,
      ),
    };
  }

  Future<void> _setBiometric(
    BuildContext context,
    WidgetRef ref,
    bool enabled,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await ref
        .read(appSecurityProvider.notifier)
        .setBiometricEnabled(
          enabled: enabled,
          reason: l10n.securityBiometricReason,
        );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? l10n.securitySaved : l10n.securityBiometricFailed),
      ),
    );
  }

  Future<void> _showPasswordDialog(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final password = await showDialog<String>(
      context: context,
      builder: (context) => PasswordDialog(
        title: security.hasPassword
            ? l10n.securityChangePassword
            : l10n.securitySetPassword,
      ),
    );
    if (password == null) return;
    await ref.read(appSecurityProvider.notifier).setPassword(password);
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.securitySaved)));
  }

  Future<void> _clearPassword(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await verifySecurityPassword(
      context,
      ref,
      l10n.securityRemovePassword,
    );
    if (!ok) return;
    await ref.read(appSecurityProvider.notifier).clearPassword();
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.securitySaved)));
  }

  Future<void> _showLockPolicyDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final result = await showDialog<({AppLockMode mode, int minutes})>(
      context: context,
      builder: (context) => LockPolicyDialog(security: security),
    );
    if (result == null) return;
    await ref
        .read(appSecurityProvider.notifier)
        .setLockPolicy(result.mode, result.minutes);
  }
}
