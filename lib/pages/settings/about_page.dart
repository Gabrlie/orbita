import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/pages/settings/about_update_panel.dart';
import 'package:orbita/providers/update_provider.dart';
import 'package:orbita/widgets/common.dart';
import 'package:orbita/widgets/settings_tiles.dart';

class AboutPage extends ConsumerWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final version = ref
        .watch(packageInfoProvider)
        .maybeWhen(
          data: (info) => '${info.version}+${info.buildNumber}',
          orElse: () => '1.0.2+3',
        );

    return Scaffold(
      appBar: compactPageAppBar(
        context,
        title: l10n.settingsAbout,
        fallbackLocation: '/settings',
      ),
      body: TonalListBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Material(
              color: tonalItemColor(context),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        'assets/images/orbita_icon.png',
                        width: 52,
                        height: 52,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.appName,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.aboutVersion(version),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AboutUpdatePanel(title: l10n.updateTitle),
            OrbitaSettingsTileGroup(
              title: l10n.aboutOverview,
              children: [
                orbitaSettingsTile(
                  context,
                  icon: Ionicons.shield_checkmark_outline,
                  title: l10n.aboutPrivacyTitle,
                  subtitle: l10n.aboutPrivacyDesc,
                ),
                orbitaSettingsTile(
                  context,
                  icon: Ionicons.git_branch_outline,
                  title: l10n.aboutCrossPlatformTitle,
                  subtitle: l10n.aboutCrossPlatformDesc,
                ),
                orbitaSettingsTile(
                  context,
                  icon: Ionicons.server_outline,
                  title: l10n.aboutNoAgentTitle,
                  subtitle: l10n.aboutNoAgentDesc,
                ),
              ],
            ),
            OrbitaSettingsTileGroup(
              title: l10n.aboutTechStack,
              children: [
                orbitaSettingsTile(
                  context,
                  icon: Ionicons.layers_outline,
                  title: 'Flutter',
                  subtitle: 'Material Design 3 / Riverpod',
                ),
                orbitaSettingsTile(
                  context,
                  icon: Ionicons.terminal_outline,
                  title: 'SSH / SFTP',
                  subtitle: 'dartssh2',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
