import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbita/models/server_status.dart';
import 'package:orbita/providers/server_monitor_provider.dart';

final terminalMetricHistoryProvider =
    NotifierProvider.family<
      TerminalMetricHistoryNotifier,
      List<ServerStatus>,
      String
    >(TerminalMetricHistoryNotifier.new);

class TerminalMetricHistoryNotifier extends Notifier<List<ServerStatus>> {
  final String serverId;

  TerminalMetricHistoryNotifier(this.serverId);

  @override
  List<ServerStatus> build() {
    ref.listen<AsyncValue<ServerStatus?>>(serverStatusProvider(serverId), (
      _,
      next,
    ) {
      final status = next.value;
      if (status != null) record(status);
    });
    return const [];
  }

  void record(ServerStatus status) {
    if (state.isNotEmpty &&
        state.last.snapshot.timestamp.isAtSameMomentAs(
          status.snapshot.timestamp,
        )) {
      return;
    }
    final next = [...state, status];
    state = next.length <= 24 ? next : next.sublist(next.length - 24);
  }

  List<ServerStatus> visibleHistory(ServerStatus? status) {
    final history = [...state];
    if (status != null &&
        (history.isEmpty ||
            !history.last.snapshot.timestamp.isAtSameMomentAs(
              status.snapshot.timestamp,
            ))) {
      history.add(status);
    }
    return history.length <= 24 ? history : history.sublist(history.length - 24);
  }
}
