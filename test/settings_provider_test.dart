import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbita/models/app_theme_seed.dart';
import 'package:orbita/models/server.dart';
import 'package:orbita/providers/command_snippet_provider.dart';
import 'package:orbita/providers/remote_script_provider.dart';
import 'package:orbita/providers/server_group_provider.dart';
import 'package:orbita/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('theme seed defaults to indigo and persists changes', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    expect(container.read(themeSeedProvider), AppThemeSeed.indigo);

    await container.read(themeSeedProvider.notifier).set(AppThemeSeed.teal);

    expect(container.read(themeSeedProvider), AppThemeSeed.teal);
    expect(prefs.getString('theme_seed'), 'teal');
  });

  test('theme seed falls back to indigo for unknown stored values', () async {
    SharedPreferences.setMockInitialValues({'theme_seed': 'unknown'});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    expect(container.read(themeSeedProvider), AppThemeSeed.indigo);
  });

  test('dynamic color defaults to enabled and persists changes', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    expect(container.read(dynamicColorProvider), isTrue);

    await container.read(dynamicColorProvider.notifier).set(false);

    expect(container.read(dynamicColorProvider), isFalse);
    expect(prefs.getBool('dynamic_color'), isFalse);
  });

  test('stored theme mode and locale still load from preferences', () async {
    SharedPreferences.setMockInitialValues({
      'theme_mode': 'dark',
      'locale': 'en',
    });
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    expect(container.read(themeModeProvider), ThemeMode.dark);
    expect(container.read(localeProvider)?.languageCode, 'en');
  });

  test('terminal appearance defaults and persists changes', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    expect(
      container.read(terminalAppearanceProvider),
      const TerminalAppearance(
        fontFamily: TerminalFontFamily.jetbrainsMono,
        customFontFamily: '',
        fontSize: 14,
        foregroundColor: Color(0xFFECEFF4),
        backgroundColor: Color(0xFF0B1020),
      ),
    );

    const appearance = TerminalAppearance(
      fontFamily: TerminalFontFamily.custom,
      customFontFamily: 'Cascadia Mono',
      fontSize: 16,
      foregroundColor: Color(0xFFFFFFFF),
      backgroundColor: Color(0xFF111111),
    );

    await container.read(terminalAppearanceProvider.notifier).set(appearance);

    expect(container.read(terminalAppearanceProvider), appearance);
    expect(prefs.getString('terminal_font_family'), 'custom');
    expect(prefs.getString('terminal_custom_font_family'), 'Cascadia Mono');
    expect(prefs.getDouble('terminal_font_size'), 16);
    expect(prefs.getInt('terminal_foreground_color'), 0xFFFFFFFF);
    expect(prefs.getInt('terminal_background_color'), 0xFF111111);
  });

  test('metric settings default, clamp, and persist changes', () async {
    SharedPreferences.setMockInitialValues({
      'metric_refresh_interval_seconds': 1,
      'metric_ssh_connect_timeout_seconds': 99,
      'metric_keep_alive_interval_seconds': 2,
    });
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    expect(
      container.read(metricSettingsProvider),
      const MetricSettings(
        refreshIntervalSeconds: 3,
        sshConnectTimeoutSeconds: 60,
        keepAliveIntervalSeconds: 5,
        autoReconnect: true,
      ),
    );

    await container
        .read(metricSettingsProvider.notifier)
        .set(
          const MetricSettings(
            refreshIntervalSeconds: 15,
            sshConnectTimeoutSeconds: 12,
            keepAliveIntervalSeconds: 45,
            autoReconnect: false,
          ),
        );

    expect(
      container.read(metricSettingsProvider),
      const MetricSettings(
        refreshIntervalSeconds: 15,
        sshConnectTimeoutSeconds: 12,
        keepAliveIntervalSeconds: 45,
        autoReconnect: false,
      ),
    );
    expect(prefs.getInt('metric_refresh_interval_seconds'), 15);
    expect(prefs.getInt('metric_ssh_connect_timeout_seconds'), 12);
    expect(prefs.getInt('metric_keep_alive_interval_seconds'), 45);
    expect(prefs.getBool('metric_auto_reconnect'), isFalse);
  });

  test('transfer settings default and persist changes', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    expect(container.read(transferSettingsProvider), const TransferSettings());

    const settings = TransferSettings(
      toolPreference: TransferToolPreference.localRelay,
      duplicateAction: TransferDuplicateAction.overwrite,
      downloadDirectory: 'D:/Downloads/Orbita',
      askDownloadLocation: true,
    );

    await container.read(transferSettingsProvider.notifier).set(settings);

    expect(container.read(transferSettingsProvider), settings);
    expect(prefs.getString('transfer_tool'), 'localRelay');
    expect(prefs.getString('transfer_duplicate_action'), 'overwrite');
    expect(
      prefs.getString('transfer_download_directory'),
      'D:/Downloads/Orbita',
    );
    expect(prefs.getBool('transfer_ask_download_location'), isTrue);
  });

  test('user scripts persist through shared preferences', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    final script = await container
        .read(userScriptsProvider.notifier)
        .add(
          name: 'Update app',
          description: 'Run updater',
          command: 'echo ok',
        );

    expect(container.read(userScriptsProvider), hasLength(1));
    expect(prefs.getString('remote_user_scripts'), contains('Update app'));

    await container
        .read(userScriptsProvider.notifier)
        .update(script.copyWith(name: 'Updated app'));

    expect(container.read(userScriptsProvider).single.name, 'Updated app');

    await container.read(userScriptsProvider.notifier).delete(script.id);

    expect(container.read(userScriptsProvider), isEmpty);
  });

  test('command snippets persist and can be searched', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    await container
        .read(commandSnippetProvider.notifier)
        .add(name: 'Disk', command: 'df -h');

    final snippets = container.read(commandSnippetProvider);
    expect(snippets, hasLength(1));
    expect(filterCommandSnippets(snippets, 'disk df'), hasLength(1));
  });

  test('server grouping preserves custom group and server order', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    final notifier = container.read(serverGroupProvider.notifier);
    await notifier.addGroup('Prod');
    await notifier.addGroup('Dev');
    final groups = container.read(serverGroupProvider).groups;
    await notifier.reorderGroup(groups.last.id, groups.first.id);
    await notifier.moveServer(serverId: 'server-1', groupId: groups.first.id);
    await notifier.moveServer(
      serverId: 'server-2',
      groupId: groups.first.id,
      beforeServerId: 'server-1',
    );

    final buckets = groupServersForDisplay(
      servers: const [
        Server(id: 'server-1', name: 'A', host: 'a', username: 'root'),
        Server(id: 'server-2', name: 'B', host: 'b', username: 'root'),
      ],
      groupState: container.read(serverGroupProvider),
      unnamedGroupName: 'Unnamed',
    );

    expect(buckets.map((bucket) => bucket.name), ['Dev', 'Prod']);
    expect(buckets[1].servers.map((server) => server.id), [
      'server-2',
      'server-1',
    ]);
  });
}
