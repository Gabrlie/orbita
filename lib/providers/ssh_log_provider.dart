import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbita/models/ssh_log.dart';

/// Global SSH log store keyed by serverId.
final _sshLogStoreProvider =
    NotifierProvider<_SshLogStoreNotifier, Map<String, List<SshLogEntry>>>(
  _SshLogStoreNotifier.new,
);

class _SshLogStoreNotifier
    extends Notifier<Map<String, List<SshLogEntry>>> {
  @override
  Map<String, List<SshLogEntry>> build() => {};

  void add(String serverId, SshLogEntry entry) {
    final logs = <SshLogEntry>[...(state[serverId] ?? []), entry];
    state = {
      ...state,
      serverId: logs.length > 200 ? logs.sublist(logs.length - 200) : logs,
    };
  }

  void clear(String serverId) {
    state = {...state, serverId: <SshLogEntry>[]};
  }
}

/// Per-server log accessor (read-only).
final sshLogProvider =
    Provider.family<List<SshLogEntry>, String>((ref, serverId) {
  return ref.watch(_sshLogStoreProvider)[serverId] ?? [];
});

/// Utility class for adding logs from other providers.
class SshLogger {
  final Ref _ref;
  final String _serverId;

  SshLogger(this._ref, this._serverId);

  void add(SshLogEntry entry) {
    _ref.read(_sshLogStoreProvider.notifier).add(_serverId, entry);
  }

  void info(String message) => add(SshLogEntry.info(message));
  void error(String message, [String? detail]) =>
      add(SshLogEntry.error(message, detail));
  void command(String cmd, String output) =>
      add(SshLogEntry.command(cmd, output));
}
