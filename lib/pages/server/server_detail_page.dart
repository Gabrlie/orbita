import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/models/server_status.dart';
import 'package:orbita/pages/server/server_metric_sections.dart';
import 'package:orbita/providers/server_monitor_provider.dart';
import 'package:orbita/providers/server_provider.dart';
import 'package:orbita/widgets/common.dart';

class ServerDetailPage extends ConsumerStatefulWidget {
  final String id;

  const ServerDetailPage({super.key, required this.id});

  @override
  ConsumerState<ServerDetailPage> createState() => _ServerDetailPageState();
}

class _ServerDetailPageState extends ConsumerState<ServerDetailPage> {
  final _history = <ServerStatus>[];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final server = ref.watch(serverByIdProvider(widget.id));
    final statusAsync = ref.watch(serverStatusProvider(widget.id));
    ref.listen<AsyncValue<ServerStatus?>>(serverStatusProvider(widget.id), (
      _,
      next,
    ) {
      final status = next.value;
      if (status != null) _recordStatus(status);
    });

    if (server == null) {
      return Scaffold(
        appBar: AppBar(),
        body: EmptyState(
          icon: Ionicons.warning_outline,
          title: l10n.fileServerMissing,
          subtitle: l10n.fileServerMissingSubtitle,
        ),
      );
    }

    final status = statusAsync.value;
    final history = _visibleHistory(status);
    final message = _statusMessage(l10n, statusAsync);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: l10n.commonCancel,
          icon: const Icon(Ionicons.chevron_back_outline),
          onPressed: () => context.go('/home'),
        ),
        title: Text(server.name),
        actions: [
          IconButton(
            tooltip: l10n.actionFileManager,
            icon: const Icon(Ionicons.folder_outline),
            onPressed: () => context.go('/files/${widget.id}'),
          ),
          IconButton(
            tooltip: l10n.actionConnect,
            icon: const Icon(Ionicons.terminal_outline),
            onPressed: () => context.go('/terminal/${widget.id}'),
          ),
          IconButton(
            tooltip: l10n.actionEdit,
            icon: const Icon(Ionicons.settings_outline),
            onPressed: () => context.go('/home/server/${widget.id}/edit'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(serverStatusProvider(widget.id)),
        child: ServerMetricSections(
          server: server,
          status: status,
          history: history,
          statusMessage: message,
          onOpenCommand: (command, title) =>
              _openTerminalCommand(context, command: command, title: title),
        ),
      ),
    );
  }

  String? _statusMessage(AppLocalizations l10n, AsyncValue<dynamic> async) {
    if (async.isLoading) return l10n.sshConnecting;
    if (async.hasError) return '${l10n.sshConnectionFailed}: ${async.error}';
    if (async.value == null) return l10n.sshDisconnected;
    return null;
  }

  void _recordStatus(ServerStatus status) {
    if (_history.isNotEmpty &&
        _history.last.snapshot.timestamp.isAtSameMomentAs(
          status.snapshot.timestamp,
        )) {
      return;
    }
    setState(() {
      _history.add(status);
      if (_history.length > 24) {
        _history.removeRange(0, _history.length - 24);
      }
    });
  }

  List<ServerStatus> _visibleHistory(ServerStatus? status) {
    final history = List<ServerStatus>.of(_history);
    if (status != null &&
        (history.isEmpty ||
            !history.last.snapshot.timestamp.isAtSameMomentAs(
              status.snapshot.timestamp,
            ))) {
      history.add(status);
    }
    if (history.length <= 24) return history;
    return history.sublist(history.length - 24);
  }

  void _openTerminalCommand(
    BuildContext context, {
    required String command,
    required String title,
  }) {
    final encoded = base64Url.encode(utf8.encode(command));
    final uri = Uri(
      path: '/terminal/${widget.id}',
      queryParameters: {'initial': encoded, 'title': title},
    );
    context.go(uri.toString());
  }
}
