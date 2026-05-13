import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../widgets/responsive_scaffold.dart';
import '../pages/lock/lock_page.dart';
import '../pages/home/home_page.dart';
import '../pages/server/server_detail_page.dart';
import '../pages/server/server_connection_test_page.dart';
import '../pages/server/server_form_page.dart';
import '../pages/server/logs/server_log_page.dart';
import '../pages/server/files/files_tabs_page.dart';
import '../pages/server/docker/docker_page.dart';
import '../pages/settings/settings_page.dart';
import '../pages/settings/about_page.dart';
import '../pages/settings/backup_sync_page.dart';
import '../pages/settings/server_groups_page.dart';
import '../pages/settings/server_list_page.dart';
import '../pages/settings/appearance/appearance_page.dart';
import '../pages/settings/security/security_page.dart';
import '../pages/settings/metrics/metric_settings_page.dart';
import '../pages/settings/network_settings_page.dart';
import '../pages/settings/transfer_settings_page.dart';
import '../pages/settings/keys/key_list_page.dart';
import '../pages/settings/keys/key_import_page.dart';
import '../pages/settings/keys/key_generate_page.dart';
import '../pages/scripts/scripts_library_page.dart';
import '../pages/scripts/script_editor_page.dart';
import '../pages/server/terminal/terminal_launch_mode.dart';
import '../pages/terminal/terminal_tabs_page.dart';
import '../pages/snippets/snippets_page.dart';

final router = GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(
      path: '/lock',
      builder: (context, state) => const LockPage(redirectOnUnlock: true),
    ),
    StatefulShellRoute(
      builder: (context, state, navigationShell) {
        final path = state.uri.path;
        return ResponsiveScaffold(
          navigationShell: navigationShell,
          hideNavigation: path.startsWith('/settings/'),
        );
      },
      navigatorContainerBuilder: (context, navigationShell, children) {
        return IndexedStack(
          index: navigationShell.currentIndex,
          children: children,
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
                  path: 'server/add',
                  builder: (context, state) =>
                      const ServerFormPage(returnPath: '/home'),
                ),
                GoRoute(
                  path: 'server/:id',
                  builder: (context, state) =>
                      ServerDetailPage(id: state.pathParameters['id']!),
                ),
                GoRoute(
                  path: 'server/:id/edit',
                  builder: (context, state) {
                    final id = state.pathParameters['id'];
                    return ServerFormPage(
                      serverId: id,
                      returnPath: id == null ? '/home' : '/home/server/$id',
                    );
                  },
                ),
                GoRoute(
                  path: 'server/:id/logs',
                  builder: (context, state) =>
                      ServerLogPage(serverId: state.pathParameters['id']!),
                ),
                GoRoute(
                  path: 'server/:id/test',
                  builder: (context, state) => ServerConnectionTestPage(
                    serverId: state.pathParameters['id']!,
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/files',
              builder: (context, state) => const FilesTabsPage(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) => FilesTabsPage(
                    initialServerId: state.pathParameters['id'],
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/terminal',
              builder: (context, state) => const TerminalTabsPage(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) => TerminalTabsPage(
                    initialServerId: state.pathParameters['id'],
                    initialLaunchMode: terminalLaunchModeFromQuery(
                      state.uri.queryParameters['mode'],
                    ),
                    initialUseRememberedMode:
                        state.uri.queryParameters['mode'] == null &&
                        state.uri.queryParameters['initial'] == null,
                    initialCommand: _decodeBase64Url(
                      state.uri.queryParameters['initial'],
                    ),
                    initialTitle: state.uri.queryParameters['title'],
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
              builder: (context, state) => const DockerPage(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) =>
                      DockerPage(initialServerId: state.pathParameters['id']),
                ),
              ],
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
                      builder: (context, state) =>
                          const ServerFormPage(returnPath: '/settings/servers'),
                    ),
                    GoRoute(
                      path: ':id/edit',
                      builder: (context, state) => ServerFormPage(
                        serverId: state.pathParameters['id'],
                        returnPath: '/settings/servers',
                      ),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'appearance',
                  builder: (context, state) => const AppearancePage(),
                ),
                GoRoute(
                  path: 'groups',
                  builder: (context, state) => const ServerGroupsPage(),
                ),
                GoRoute(
                  path: 'metrics',
                  builder: (context, state) => const MetricSettingsPage(),
                ),
                GoRoute(
                  path: 'network',
                  builder: (context, state) => const NetworkSettingsPage(),
                ),
                GoRoute(
                  path: 'transfers',
                  builder: (context, state) => const TransferSettingsPage(),
                ),
                GoRoute(
                  path: 'security',
                  builder: (context, state) => const SecurityPage(),
                ),
                GoRoute(
                  path: 'backup-sync',
                  builder: (context, state) => const BackupSyncPage(),
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
                  routes: [
                    GoRoute(
                      path: 'add',
                      builder: (context, state) => const ScriptEditorPage(),
                    ),
                    GoRoute(
                      path: ':id',
                      builder: (context, state) => ScriptEditorPage(
                        scriptId: state.pathParameters['id'],
                      ),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'snippets',
                  builder: (context, state) => const SnippetsPage(),
                ),
                GoRoute(
                  path: 'about',
                  builder: (context, state) => const AboutPage(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);

String? _decodeBase64Url(String? value) {
  if (value == null || value.isEmpty) return null;
  try {
    return utf8.decode(base64Url.decode(base64Url.normalize(value)));
  } catch (_) {
    return null;
  }
}
