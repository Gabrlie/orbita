import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/pages/settings/about_update_panel.dart';
import 'package:orbita/providers/update_provider.dart';
import 'package:orbita/widgets/common.dart';

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
            SectionHeader(
              title: l10n.updateTitle,
              padding: const EdgeInsets.fromLTRB(12, 24, 12, 8),
            ),
            const AboutUpdatePanel(),
            SectionHeader(
              title: l10n.aboutOverview,
              padding: const EdgeInsets.fromLTRB(12, 24, 12, 8),
            ),
            _AboutPanel(
              children: [
                _AboutTile(
                  icon: Ionicons.shield_checkmark_outline,
                  title: l10n.aboutPrivacyTitle,
                  subtitle: l10n.aboutPrivacyDesc,
                ),
                _AboutTile(
                  icon: Ionicons.git_branch_outline,
                  title: l10n.aboutCrossPlatformTitle,
                  subtitle: l10n.aboutCrossPlatformDesc,
                ),
                _AboutTile(
                  icon: Ionicons.server_outline,
                  title: l10n.aboutNoAgentTitle,
                  subtitle: l10n.aboutNoAgentDesc,
                ),
              ],
            ),
            SectionHeader(
              title: l10n.aboutTechStack,
              padding: const EdgeInsets.fromLTRB(12, 24, 12, 8),
            ),
            _AboutPanel(
              children: const [
                _AboutTile(
                  icon: Ionicons.layers_outline,
                  title: 'Flutter',
                  subtitle: 'Material Design 3 / Riverpod',
                ),
                _AboutTile(
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

class _AboutPanel extends StatelessWidget {
  final List<Widget> children;

  const _AboutPanel({required this.children});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: tonalItemColor(context),
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const Divider(height: 1, indent: 20, endIndent: 20),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _AboutTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _AboutTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      leading: Icon(icon, color: theme.colorScheme.primary, size: 20),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}
