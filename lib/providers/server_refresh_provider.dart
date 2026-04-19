import 'package:flutter_riverpod/flutter_riverpod.dart';

final serverRefreshControllerProvider =
    NotifierProvider<ServerRefreshController, Map<String, int>>(
      ServerRefreshController.new,
    );

final serverRefreshProvider = Provider.family<int, String>((ref, serverId) {
  return ref.watch(serverRefreshControllerProvider)[serverId] ?? 0;
});

class ServerRefreshController extends Notifier<Map<String, int>> {
  @override
  Map<String, int> build() => {};

  void refreshServer(String serverId) {
    state = {...state, serverId: (state[serverId] ?? 0) + 1};
  }

  void refreshAll(Iterable<String> serverIds) {
    final next = {...state};
    for (final serverId in serverIds) {
      next[serverId] = (next[serverId] ?? 0) + 1;
    }
    state = next;
  }
}
