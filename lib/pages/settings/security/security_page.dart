import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/widgets/common.dart';

class SecurityPage extends StatelessWidget {
  const SecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final disabledColor = theme.colorScheme.onSurface.withAlpha(97);

    return Scaffold(
      appBar: compactPageAppBar(
        context,
        title: l10n.securityTitle,
        fallbackLocation: '/settings',
      ),
      body: TonalListBackground(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            SectionHeader(
              title: l10n.securityCurrentTier,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            ),
            Card(
              margin: EdgeInsets.zero,
              color: tonalItemColor(context),
              surfaceTintColor: Colors.transparent,
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 4,
                ),
                leading: Icon(
                  Ionicons.phone_portrait_outline,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                minLeadingWidth: 24,
                title: Text(
                  l10n.securityDeviceEncryption,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(l10n.securityDeviceEncryptionDesc),
                trailing: Icon(
                  Ionicons.checkmark_circle_outline,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
            ),

            SectionHeader(
              title: l10n.securityAdditional,
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            ),
            Card(
              margin: EdgeInsets.zero,
              color: tonalItemColor(context),
              surfaceTintColor: Colors.transparent,
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 4,
                    ),
                    leading: Icon(
                      Ionicons.lock_closed_outline,
                      color: disabledColor,
                      size: 20,
                    ),
                    minLeadingWidth: 24,
                    title: Text(
                      l10n.securityAppPassword,
                      style: TextStyle(
                        color: disabledColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      l10n.comingSoon,
                      style: TextStyle(color: disabledColor),
                    ),
                  ),
                  const Divider(height: 1, indent: 24, endIndent: 24),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 4,
                    ),
                    leading: Icon(
                      Ionicons.finger_print_outline,
                      color: disabledColor,
                      size: 20,
                    ),
                    minLeadingWidth: 24,
                    title: Text(
                      l10n.securityBiometric,
                      style: TextStyle(
                        color: disabledColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      l10n.comingSoon,
                      style: TextStyle(color: disabledColor),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: tonalItemColor(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Row(
                children: [
                  Icon(
                    Ionicons.information_circle_outline,
                    color: theme.colorScheme.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      l10n.securityDeviceEncryptionDesc,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
