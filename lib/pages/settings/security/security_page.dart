import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/models/app_security.dart';
import 'package:orbita/pages/settings/security/security_dialogs.dart';
import 'package:orbita/providers/security_provider.dart';
import 'package:orbita/widgets/common.dart';
import 'package:orbita/widgets/orbita_forui.dart';
import 'package:orbita/widgets/settings_tiles.dart';

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
        OrbitaSettingsTileGroup(
          title: l10n.securityCurrentTier,
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
          children: [
            orbitaSettingsTile(
              context,
              icon: Ionicons.phone_portrait_outline,
              title: l10n.securityDeviceEncryption,
              subtitle: l10n.securityDeviceEncryptionDesc,
              suffix: const Icon(Ionicons.checkmark_circle_outline),
            ),
            orbitaSettingsTile(
              context,
              icon: Ionicons.lock_closed_outline,
              title: l10n.securityAppPassword,
              subtitle: security.hasPassword
                  ? l10n.securityAppPasswordEnabled
                  : l10n.securityAppPasswordDisabled,
              suffix: FButton(
                variant: FButtonVariant.secondary,
                size: FButtonSizeVariant.sm,
                mainAxisSize: MainAxisSize.min,
                onPress: () => _showPasswordDialog(context, ref),
                child: Text(
                  security.hasPassword
                      ? l10n.securityChangePassword
                      : l10n.securitySetPassword,
                ),
              ),
            ),
          ],
        ),
        OrbitaSettingsTileGroup(
          title: l10n.securityUnlockSection,
          children: [
            orbitaSettingsSwitchTile(
              context,
              icon: Ionicons.finger_print_outline,
              title: l10n.securityBiometric,
              subtitle: l10n.securityBiometricDesc,
              value: security.biometricEnabled,
              enabled: security.hasPassword,
              onChanged: (value) => _setBiometric(context, ref, value),
            ),
            OrbitaSelectMenuTile<AppLockMode>(
              title: l10n.securityLockPolicy,
              value: security.lockMode,
              options: AppLockMode.values,
              labelBuilder: (mode) => _lockModeText(l10n, mode),
              subtitle: _lockPolicyText(l10n, security),
              prefix: const Icon(Ionicons.timer_outline),
              onChanged: (mode) => ref
                  .read(appSecurityProvider.notifier)
                  .setLockPolicy(mode, security.lockAfterMinutes),
            ),
            if (security.lockMode == AppLockMode.afterDuration)
              OrbitaSelectMenuTile<int>(
                title: l10n.securityLockMinutes,
                value: security.lockAfterMinutes,
                options: _lockMinuteOptions(security.lockAfterMinutes),
                labelBuilder: (minutes) => '$minutes',
                prefix: const Icon(Ionicons.hourglass_outline),
                onChanged: (minutes) => ref
                    .read(appSecurityProvider.notifier)
                    .setLockPolicy(AppLockMode.afterDuration, minutes),
              ),
          ],
        ),
        const SizedBox(height: 24),
        if (security.hasPassword)
          FButton(
            variant: FButtonVariant.destructive,
            mainAxisSize: MainAxisSize.max,
            onPress: () => _clearPassword(context, ref),
            prefix: const Icon(Ionicons.trash_outline),
            child: Text(l10n.securityRemovePassword),
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

  String _lockModeText(AppLocalizations l10n, AppLockMode mode) {
    return switch (mode) {
      AppLockMode.never => l10n.securityLockNever,
      AppLockMode.onExit => l10n.securityLockOnExit,
      AppLockMode.afterDuration => l10n.securityLockAfterTitle,
    };
  }

  List<int> _lockMinuteOptions(int current) {
    final options = {1, 5, 15, 30, 60, 120, 240, current}.toList();
    options.sort();
    return options;
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
    final password = await showOrbitaDialog<String>(
      context: context,
      builder: (context, animation) => PasswordDialog(
        title: security.hasPassword
            ? l10n.securityChangePassword
            : l10n.securitySetPassword,
        animation: animation,
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
}
