import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbita/models/server.dart';
import 'package:orbita/models/ssh_key.dart';
import 'package:orbita/models/remote_script.dart';
import 'package:orbita/providers/key_provider.dart';
import 'package:orbita/providers/server_monitor_provider.dart';
import 'package:orbita/providers/settings_provider.dart';
import 'package:orbita/providers/ssh_connection_provider.dart';
import 'package:orbita/services/remote_script_service.dart';
import 'package:uuid/uuid.dart';

const _userScriptsKey = 'remote_user_scripts';

final remoteScriptServiceProvider = Provider<RemoteScriptService>((ref) {
  return RemoteScriptService(ref.watch(sshConnectionManagerProvider));
});

Future<SshKey?> resolveRemoteScriptKey(WidgetRef ref, Server server) {
  return resolveServerKey(server, ref.read(keyListProvider.future));
}

final userScriptsProvider =
    NotifierProvider<UserScriptsNotifier, List<RemoteScript>>(
      UserScriptsNotifier.new,
    );

class UserScriptsNotifier extends Notifier<List<RemoteScript>> {
  @override
  List<RemoteScript> build() {
    final prefs = ref.read(sharedPrefsProvider);
    final raw = prefs.getString(_userScriptsKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return [
        for (final item in decoded)
          if (item is Map)
            RemoteScript.fromJson(Map<String, Object?>.from(item)),
      ];
    } catch (_) {
      return const [];
    }
  }

  Future<RemoteScript> add({
    required String name,
    required String description,
    required String command,
  }) async {
    final script = RemoteScript(
      id: const Uuid().v4(),
      name: name.trim(),
      description: description.trim(),
      command: command.trimRight(),
    );
    state = [...state, script];
    await _persist();
    return script;
  }

  Future<void> update(RemoteScript script) async {
    state = [
      for (final item in state)
        if (item.id == script.id) script else item,
    ];
    await _persist();
  }

  Future<void> delete(String id) async {
    state = [
      for (final item in state)
        if (item.id != id) item,
    ];
    await _persist();
  }

  Future<void> replaceAll(List<RemoteScript> scripts) async {
    state = scripts;
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = ref.read(sharedPrefsProvider);
    await prefs.setString(
      _userScriptsKey,
      jsonEncode([for (final script in state) script.toJson()]),
    );
  }
}
