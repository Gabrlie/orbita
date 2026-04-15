import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:orbita/l10n/app_localizations.dart';

import '../widgets/responsive_scaffold.dart';
import '../pages/lock/lock_page.dart';
import '../pages/home/home_page.dart';
import '../pages/server/server_detail_page.dart';
import '../pages/settings/settings_page.dart';
import '../pages/settings/appearance/appearance_page.dart';
import '../pages/scripts/scripts_library_page.dart';
import '../pages/snippets/snippets_page.dart';

final router = GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(
      path: '/lock',
      builder: (context, state) => const LockPage(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ResponsiveScaffold(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomePage(),
              routes: [
                GoRoute(
                  path: 'server/:id',
                  builder: (context, state) =>
                      ServerDetailPage(id: state.pathParameters['id']!),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/files',
              builder: (context, state) => _PlaceholderPage(
                icon: Icons.folder_outlined,
                title: AppLocalizations.of(context)!.navFiles,
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/terminal',
              builder: (context, state) => _PlaceholderPage(
                icon: Icons.terminal,
                title: AppLocalizations.of(context)!.navTerminal,
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/docker',
              builder: (context, state) => _PlaceholderPage(
                icon: Icons.widgets_outlined,
                title: AppLocalizations.of(context)!.navDocker,
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsPage(),
              routes: [
                GoRoute(
                  path: 'appearance',
                  builder: (context, state) => const AppearancePage(),
                ),
                GoRoute(
                  path: 'scripts',
                  builder: (context, state) => const ScriptsLibraryPage(),
                ),
                GoRoute(
                  path: 'snippets',
                  builder: (context, state) => const SnippetsPage(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);

class _PlaceholderPage extends StatelessWidget {
  final IconData icon;
  final String title;

  const _PlaceholderPage({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(l10n.noServersTitle, style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(l10n.noServersSubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                )),
          ],
        ),
      ),
    );
  }
}
