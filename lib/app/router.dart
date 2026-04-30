import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';

import '../widgets/responsive_scaffold.dart';
import '../pages/lock/lock_page.dart';
import '../pages/home/home_page.dart';
import '../pages/home/home_search_page.dart';
import '../pages/server/server_detail_page.dart';
import '../pages/server/server_form_page.dart';
import '../pages/server/logs/server_log_page.dart';
import '../pages/settings/settings_page.dart';
import '../pages/settings/server_list_page.dart';
import '../pages/settings/appearance/appearance_page.dart';
import '../pages/settings/security/security_page.dart';
import '../pages/settings/keys/key_list_page.dart';
import '../pages/settings/keys/key_import_page.dart';
import '../pages/settings/keys/key_generate_page.dart';
import '../pages/scripts/scripts_library_page.dart';
import '../pages/server/terminal/terminal_launch_mode.dart';
import '../pages/server/terminal/terminal_page.dart';
import '../pages/terminal/terminal_server_picker_page.dart';
import '../pages/snippets/snippets_page.dart';
import '../widgets/common.dart';

final router = GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(path: '/lock', builder: (context, state) => const LockPage()),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ResponsiveScaffold(
          navigationShell: navigationShell,
          hideNavigation: state.uri.path.startsWith('/terminal/'),
        );
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomePage(),
              routes: [
                GoRoute(
                  path: 'search',
                  builder: (context, state) => const HomeSearchPage(),
                ),
                GoRoute(
                  path: 'server/add',
                  builder: (context, state) => const ServerFormPage(),
                ),
                GoRoute(
                  path: 'server/:id',
                  builder: (context, state) =>
                      ServerDetailPage(id: state.pathParameters['id']!),
                ),
                GoRoute(
                  path: 'server/:id/edit',
                  builder: (context, state) =>
                      ServerFormPage(serverId: state.pathParameters['id']),
                ),
                GoRoute(
                  path: 'server/:id/logs',
                  builder: (context, state) =>
                      ServerLogPage(serverId: state.pathParameters['id']!),
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
                icon: Ionicons.folder,
                title: AppLocalizations.of(context)!.navFiles,
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/terminal',
              builder: (context, state) => const TerminalServerPickerPage(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) => TerminalPage(
                    serverId: state.pathParameters['id']!,
                    launchMode: terminalLaunchModeFromQuery(
                      state.uri.queryParameters['mode'],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/docker',
              builder: (context, state) => _PlaceholderPage(
                icon: Ionicons.cube,
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
                  path: 'servers',
                  builder: (context, state) => const ServerListPage(),
                  routes: [
                    GoRoute(
                      path: 'add',
                      builder: (context, state) => const ServerFormPage(),
                    ),
                    GoRoute(
                      path: ':id/edit',
                      builder: (context, state) =>
                          ServerFormPage(serverId: state.pathParameters['id']),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'appearance',
                  builder: (context, state) => const AppearancePage(),
                ),
                GoRoute(
                  path: 'security',
                  builder: (context, state) => const SecurityPage(),
                ),
                GoRoute(
                  path: 'keys',
                  builder: (context, state) => const KeyListPage(),
                  routes: [
                    GoRoute(
                      path: 'import',
                      builder: (context, state) => const KeyImportPage(),
                    ),
                    GoRoute(
                      path: 'generate',
                      builder: (context, state) => const KeyGeneratePage(),
                    ),
                    GoRoute(
                      path: ':id/edit',
                      builder: (context, state) =>
                          KeyImportPage(keyId: state.pathParameters['id']),
                    ),
                  ],
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
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: EmptyState(
        icon: icon,
        title: l10n.noServersTitle,
        subtitle: l10n.noServersSubtitle,
      ),
    );
  }
}
