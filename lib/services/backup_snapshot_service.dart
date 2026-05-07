import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbita/models/command_snippet.dart';
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
  await ref
      .read(serverListProvider.notifier)
      .replaceAll(_decodeList(snapshot['servers'], Server.fromJson));
  await ref
      .read(keyListProvider.notifier)
      .replaceAll(_decodeList(snapshot['keys'], SshKey.fromJson));
  await ref
      .read(serverGroupProvider.notifier)
      .replaceAll(
        ServerGroupState.fromJson(
          Map<String, dynamic>.from(snapshot['groups'] as Map? ?? const {}),
        ),
      );
  await ref
      .read(userScriptsProvider.notifier)
      .replaceAll(
        _decodeList(
          snapshot['scripts'],
          (json) => RemoteScript.fromJson(Map<String, Object?>.from(json)),
        ),
      );
  await ref
      .read(commandSnippetProvider.notifier)
      .replaceAll(_decodeList(snapshot['snippets'], CommandSnippet.fromJson));
}

List<T> _decodeList<T>(
  Object? raw,
  T Function(Map<String, dynamic> json) decode,
) {
  return [
    for (final item in raw as List? ?? const [])
      if (item is Map) decode(Map<String, dynamic>.from(item)),
  ];
}
