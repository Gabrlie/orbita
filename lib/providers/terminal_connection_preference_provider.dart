import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbita/pages/server/terminal/terminal_launch_mode.dart';
import 'package:orbita/providers/settings_provider.dart';

const _keyTerminalLaunchPreferences = 'terminal_launch_preferences';

final terminalConnectionPreferenceProvider =
    NotifierProvider<
      TerminalConnectionPreferenceNotifier,
      Map<String, TerminalLaunchMode>
    >(TerminalConnectionPreferenceNotifier.new);

class TerminalConnectionPreferenceNotifier
    extends Notifier<Map<String, TerminalLaunchMode>> {
  @override
  Map<String, TerminalLaunchMode> build() {
    final prefs = ref.read(sharedPrefsProvider);
    final raw = prefs.getString(_keyTerminalLaunchPreferences);
    if (raw == null || raw.isEmpty) return const {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return {
        for (final entry in decoded.entries)
          entry.key: terminalLaunchModeFromQuery(entry.value?.toString()),
      };
    } catch (_) {
      return const {};
    }
  }

  TerminalLaunchMode modeFor(String serverId) {
    return state[serverId] ?? TerminalLaunchMode.direct;
  }

  Future<void> setMode(String serverId, TerminalLaunchMode mode) async {
    state = {...state, serverId: mode};
    final encoded = {
      for (final entry in state.entries)
        entry.key: terminalLaunchModeToQuery(entry.value) ?? 'direct',
    };
    await ref
        .read(sharedPrefsProvider)
        .setString(_keyTerminalLaunchPreferences, jsonEncode(encoded));
  }
}
