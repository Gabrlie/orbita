import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbita/models/command_snippet.dart';
import 'package:orbita/models/backup_models.dart';
import 'package:orbita/models/remote_script.dart';
import 'package:orbita/models/server.dart';
import 'package:orbita/models/server_group.dart';
import 'package:orbita/models/ssh_key.dart';
import 'package:orbita/providers/command_snippet_provider.dart';
import 'package:orbita/providers/key_provider.dart';
import 'package:orbita/providers/remote_script_provider.dart';
import 'package:orbita/providers/server_group_provider.dart';
import 'package:orbita/providers/server_provider.dart';

Future<Map<String, Object?>> buildBackupSnapshot(Ref ref) async {
  return {
    'schema': 1,
    'createdAt': DateTime.now().toUtc().toIso8601String(),
    'servers': [
      for (final server in await ref.read(serverListProvider.future))
        server.toJson(),
    ],
    'keys': [
      for (final key in await ref.read(keyListProvider.future)) key.toJson(),
    ],
    'groups': ref.read(serverGroupProvider).toJson(),
    'scripts': [
      for (final script in ref.read(userScriptsProvider)) script.toJson(),
    ],
    'snippets': [
      for (final snippet in ref.read(commandSnippetProvider)) snippet.toJson(),
    ],
  };
}

Future<void> restoreBackupSnapshot(
  Ref ref,
  Map<String, Object?> snapshot,
) async {
  validateBackupSnapshot(snapshot);
  late final List<Server> servers;
  late final List<SshKey> keys;
  late final ServerGroupState groups;
  late final List<RemoteScript> scripts;
  late final List<CommandSnippet> snippets;
  try {
    servers = _decodeList(snapshot['servers'], Server.fromJson);
    keys = _decodeList(snapshot['keys'], SshKey.fromJson);
    groups = ServerGroupState.fromJson(
      Map<String, dynamic>.from(snapshot['groups'] as Map),
    );
    scripts = _decodeList(
      snapshot['scripts'],
      (json) => RemoteScript.fromJson(Map<String, Object?>.from(json)),
    );
    snippets = _decodeList(snapshot['snippets'], CommandSnippet.fromJson);
  } catch (_) {
    throw const BackupException(BackupException.invalidSnapshot);
  }
  await ref.read(serverListProvider.notifier).replaceAll(servers);
  await ref.read(keyListProvider.notifier).replaceAll(keys);
  await ref.read(serverGroupProvider.notifier).replaceAll(groups);
  await ref.read(userScriptsProvider.notifier).replaceAll(scripts);
  await ref.read(commandSnippetProvider.notifier).replaceAll(snippets);
}

void validateBackupSnapshot(Map<String, Object?> snapshot) {
  final schema = snapshot['schema'];
  final createdAt = snapshot['createdAt'];
  if (schema != 1 || createdAt is! String || createdAt.isEmpty) {
    throw const BackupException(BackupException.invalidSnapshot);
  }
  for (final key in const ['servers', 'keys', 'scripts', 'snippets']) {
    if (snapshot[key] is! List) {
      throw const BackupException(BackupException.invalidSnapshot);
    }
  }
  if (snapshot['groups'] is! Map) {
    throw const BackupException(BackupException.invalidSnapshot);
  }
}

List<T> _decodeList<T>(
  Object? raw,
  T Function(Map<String, dynamic> json) decode,
) {
  final list = raw as List;
  return [for (final item in list) decode(_decodeMap(item))];
}

Map<String, dynamic> _decodeMap(Object? raw) {
  if (raw is! Map) throw const FormatException('invalid backup item');
  return Map<String, dynamic>.from(raw);
}
