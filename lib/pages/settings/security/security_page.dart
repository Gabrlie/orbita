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
      appBar: AppBar(title: Text(l10n.securityTitle)),
      body: ListView(
        children: [
          SectionHeader(title: l10n.securityCurrentTier),
          ListTile(
            leading: Icon(
              Ionicons.phone_portrait_outline,
              color: theme.colorScheme.primary,
            ),
            title: Text(l10n.securityDeviceEncryption),
            subtitle: Text(l10n.securityDeviceEncryptionDesc),
            trailing: Icon(
              Ionicons.checkmark_circle_outline,
              color: theme.colorScheme.primary,
            ),
          ),

          SectionHeader(title: l10n.securityAdditional),
          ListTile(
            leading: Icon(Ionicons.lock_closed_outline, color: disabledColor),
            title: Text(
              l10n.securityAppPassword,
              style: TextStyle(color: disabledColor),
            ),
            subtitle: Text(
              l10n.comingSoon,
              style: TextStyle(color: disabledColor),
            ),
          ),
          ListTile(
            leading: Icon(Ionicons.finger_print_outline, color: disabledColor),
            title: Text(
              l10n.securityBiometric,
              style: TextStyle(color: disabledColor),
            ),
            subtitle: Text(
              l10n.comingSoon,
              style: TextStyle(color: disabledColor),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Ionicons.information_circle_outline,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.securityDeviceEncryptionDesc,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
