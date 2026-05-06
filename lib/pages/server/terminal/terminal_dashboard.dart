import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/pages/server/server_metric_sections.dart';
import 'package:orbita/providers/server_monitor_provider.dart';
import 'package:orbita/providers/server_provider.dart';
import 'package:orbita/providers/terminal_metric_history_provider.dart';
import 'package:orbita/widgets/common.dart';

class TerminalDashboard extends ConsumerWidget {
  final String serverId;

  const TerminalDashboard({super.key, required this.serverId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final server = ref.watch(serverByIdProvider(serverId));
    final statusAsync = ref.watch(serverStatusProvider(serverId));
    ref.watch(terminalMetricHistoryProvider(serverId));

    if (server == null) {
      return EmptyState(
        icon: Ionicons.warning_outline,
        title: l10n.fileServerMissing,
        subtitle: l10n.fileServerMissingSubtitle,
      );
    }

    final status = statusAsync.value;
    final history = ref
        .read(terminalMetricHistoryProvider(serverId).notifier)
        .visibleHistory(status);
    return TonalListBackground(
      child: ServerMetricSections(
        server: server,
        status: status,
        history: history,
        statusMessage: _statusMessage(l10n, statusAsync),
        showTools: false,
      ),
    );
  }

  String? _statusMessage(AppLocalizations l10n, AsyncValue<dynamic> async) {
    if (async.isLoading) return l10n.sshConnecting;
    if (async.hasError) return '${l10n.sshConnectionFailed}: ${async.error}';
    if (async.value == null) return l10n.sshDisconnected;
    return null;
  }
}
