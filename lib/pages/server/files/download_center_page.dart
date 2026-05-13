import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:open_filex/open_filex.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/models/file_transfer_task.dart';
import 'package:orbita/providers/file_transfer_provider.dart';
import 'package:orbita/providers/key_provider.dart';
import 'package:orbita/providers/server_monitor_provider.dart';
import 'package:orbita/providers/server_provider.dart';
import 'package:orbita/utils/format_utils.dart';
import 'package:orbita/widgets/common.dart';

part 'transfer_center_widgets.dart';

class TransferCenterPage extends ConsumerStatefulWidget {
  const TransferCenterPage({super.key});

  @override
  ConsumerState<TransferCenterPage> createState() => _TransferCenterPageState();
}

class _TransferCenterPageState extends ConsumerState<TransferCenterPage> {
  var _filter = _TransferFilter.all;
  final _promptedFallbackTaskIds = <String>{};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    ref.listen<List<FileTransferTask>>(fileTransferProvider, (previous, next) {
      for (final task in next) {
        if (task.direction == FileTransferDirection.server &&
            task.phase != FileTransferPhase.failed) {
          _promptedFallbackTaskIds.remove(task.id);
        }
        final wasFailed =
            previous?.where((item) => item.id == task.id).firstOrNull?.phase ==
            FileTransferPhase.failed;
        if (_shouldPromptLocalRelay(task) && !wasFailed) {
          _scheduleLocalRelayPrompt(task);
          break;
        }
      }
    });
    final tasks = ref.watch(fileTransferProvider);
    for (final task in tasks) {
      if (_shouldPromptLocalRelay(task)) {
        _scheduleLocalRelayPrompt(task);
        break;
      }
    }
    final visible = tasks.where(_matchesFilter).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.fileTransferCenter),
        actions: [
          IconButton(
            tooltip: l10n.transferSettingsTitle,
            icon: const Icon(Ionicons.settings_outline),
            onPressed: () => context.push('/settings/transfers'),
          ),
        ],
      ),
      body: tasks.isEmpty
          ? EmptyState(
              icon: Ionicons.swap_vertical_outline,
              title: l10n.fileNoTransfers,
            )
          : Column(
              children: [
                _TransferSummary(tasks: tasks),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: SegmentedButton<_TransferFilter>(
                    segments: [
                      ButtonSegment(
                        value: _TransferFilter.all,
                        label: Text(l10n.all),
                      ),
                      ButtonSegment(
                        value: _TransferFilter.upload,
                        label: Text(l10n.fileUpload),
                      ),
                      ButtonSegment(
                        value: _TransferFilter.download,
                        label: Text(l10n.fileDownload),
                      ),
                      ButtonSegment(
                        value: _TransferFilter.server,
                        label: Text(l10n.fileTransferCenter),
                      ),
                    ],
                    selected: {_filter},
                    onSelectionChanged: (value) =>
                        setState(() => _filter = value.single),
                  ),
                ),
                Expanded(
                  child: visible.isEmpty
                      ? EmptyState(
                          icon: Ionicons.swap_vertical_outline,
                          title: l10n.fileNoTransfers,
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.only(bottom: 16),
                          itemCount: visible.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) =>
                              _TransferTile(task: visible[index]),
                        ),
                ),
              ],
            ),
    );
  }

  bool _matchesFilter(FileTransferTask task) {
    return switch (_filter) {
      _TransferFilter.all => true,
      _TransferFilter.upload => task.direction == FileTransferDirection.upload,
      _TransferFilter.download =>
        task.direction == FileTransferDirection.download,
      _TransferFilter.server => task.direction == FileTransferDirection.server,
    };
  }

  bool _shouldPromptLocalRelay(FileTransferTask task) {
    return task.direction == FileTransferDirection.server &&
        task.phase == FileTransferPhase.failed &&
        !_promptedFallbackTaskIds.contains(task.id);
  }

  void _scheduleLocalRelayPrompt(FileTransferTask task) {
    _promptedFallbackTaskIds.add(task.id);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _confirmLocalRelayFallback(task);
      }
    });
  }

  Future<void> _confirmLocalRelayFallback(FileTransferTask task) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.fileServerTransferFallbackTitle,
      content: l10n.fileServerTransferFallbackContent,
      confirmLabel: l10n.fileServerTransferFallbackConfirm,
    );
    if (!confirmed || !mounted) return;
    final latest = ref
        .read(fileTransferProvider)
        .where((item) => item.id == task.id)
        .firstOrNull;
    if (latest == null || latest.direction != FileTransferDirection.server) {
      return;
    }
    final targetServer = ref.read(serverByIdProvider(latest.serverId));
    final sourceServerId = latest.sourceServerId;
    if (targetServer == null || sourceServerId == null) return;
    final sourceServer = ref.read(serverByIdProvider(sourceServerId));
    if (sourceServer == null) return;
    final keys = ref.read(keyListProvider.future);
    final targetKey = await resolveServerKey(targetServer, keys);
    final sourceKey = await resolveServerKey(sourceServer, keys);
    await ref
        .read(fileTransferProvider.notifier)
        .fallbackServerTransferViaLocal(
          task: latest,
          sourceServer: sourceServer,
          sourceKey: sourceKey,
          targetServer: targetServer,
          targetKey: targetKey,
        );
  }
}

class _TransferTile extends ConsumerWidget {
  final FileTransferTask task;

  const _TransferTile({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        child: ListTile(
          leading: Icon(_icon, color: colorScheme.primary),
          title: Text(task.name, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  Chip(
                    label: Text(_phaseText(l10n)),
                    visualDensity: VisualDensity.compact,
                  ),
                  Text(_serverText(l10n)),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: task.progress),
              const SizedBox(height: 4),
              Text(
                '${formatBytes(task.transferredBytes)} / '
                '${formatBytes(task.totalBytes)}',
              ),
              if (task.phase == FileTransferPhase.failed &&
                  task.error != null) ...[
                const SizedBox(height: 4),
                Text(
                  task.error!,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colorScheme.error),
                ),
              ],
              Text(
                task.direction == FileTransferDirection.download
                    ? task.remotePath
                    : task.direction == FileTransferDirection.server
                    ? '${task.sourceRemotePath ?? ''} -> ${task.remotePath}'
                    : task.localPath,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          isThreeLine: true,
          onTap: () => _handleTap(context, ref),
          onLongPress: () => _showActions(context, ref),
        ),
      ),
    );
  }

  IconData get _icon {
    if (task.direction == FileTransferDirection.upload) {
      return task.sourceType == FileTransferSourceType.directory
          ? Ionicons.cloud_upload_outline
          : Ionicons.arrow_up_circle_outline;
    }
    if (task.direction == FileTransferDirection.server) {
      return Ionicons.swap_horizontal_outline;
    }
    return Ionicons.arrow_down_circle_outline;
  }

  String _serverText(AppLocalizations l10n) {
    if (task.direction != FileTransferDirection.server) return task.serverName;
    final source = task.sourceServerName ?? l10n.fileServerMissing;
    return '$source -> ${task.serverName}';
  }

  String _phaseText(AppLocalizations l10n) {
    return switch (task.phase) {
      FileTransferPhase.queued => l10n.fileTransferQueued,
      FileTransferPhase.compressing => l10n.fileTransferCompressing,
      FileTransferPhase.uploading => l10n.fileUploading,
      FileTransferPhase.verifying => l10n.fileTransferVerifying,
      FileTransferPhase.extracting => l10n.fileTransferExtracting,
      FileTransferPhase.cleaning => l10n.fileTransferCleaning,
      FileTransferPhase.downloading => l10n.fileDownloading,
      FileTransferPhase.paused => l10n.fileDownloadPaused,
      FileTransferPhase.completed => l10n.fileDownloadCompleted,
      FileTransferPhase.failed => l10n.fileDownloadFailed,
      FileTransferPhase.canceled => l10n.fileDownloadCanceled,
    };
  }

  Future<void> _handleTap(BuildContext context, WidgetRef ref) async {
    if (task.direction == FileTransferDirection.download &&
        task.phase == FileTransferPhase.completed) {
      await OpenFilex.open(task.localPath);
      return;
    }
    if (task.direction != FileTransferDirection.server && task.isActive) {
      await ref.read(fileTransferProvider.notifier).pause(task.id);
      return;
    }
    if ((task.direction != FileTransferDirection.server &&
            task.phase == FileTransferPhase.paused) ||
        task.phase == FileTransferPhase.failed) {
      await _resume(ref);
    }
  }

  Future<void> _showActions(BuildContext context, WidgetRef ref) async {
    final choice = await showMenu<_TransferAction>(
      context: context,
      position: const RelativeRect.fromLTRB(64, 120, 24, 0),
      items: [
        PopupMenuItem(
          value: _TransferAction.pause,
          enabled:
              task.direction != FileTransferDirection.server && task.isActive,
          child: Text(AppLocalizations.of(context)!.filePause),
        ),
        PopupMenuItem(
          value: _TransferAction.resume,
          enabled:
              (task.direction != FileTransferDirection.server &&
                  task.phase == FileTransferPhase.paused) ||
              task.phase == FileTransferPhase.failed,
          child: Text(AppLocalizations.of(context)!.fileResume),
        ),
        PopupMenuItem(
          value: _TransferAction.cancel,
          enabled: task.isActive || task.phase == FileTransferPhase.paused,
          child: Text(AppLocalizations.of(context)!.commonCancel),
        ),
        PopupMenuItem(
          value: _TransferAction.delete,
          child: Text(AppLocalizations.of(context)!.commonDelete),
        ),
      ],
    );
    if (choice == null) return;
    final notifier = ref.read(fileTransferProvider.notifier);
    switch (choice) {
      case _TransferAction.pause:
        await notifier.pause(task.id);
      case _TransferAction.resume:
        await _resume(ref);
      case _TransferAction.cancel:
        await notifier.cancel(task.id);
      case _TransferAction.delete:
        await notifier.deleteTask(task.id);
    }
  }

  Future<void> _resume(WidgetRef ref) async {
    final server = ref.read(serverByIdProvider(task.serverId));
    if (server == null) return;
    if (task.direction == FileTransferDirection.server) {
      final sourceServerId = task.sourceServerId;
      if (sourceServerId == null) return;
      final sourceServer = ref.read(serverByIdProvider(sourceServerId));
      if (sourceServer == null) return;
      final keys = ref.read(keyListProvider.future);
      final targetKey = await resolveServerKey(server, keys);
      final sourceKey = await resolveServerKey(sourceServer, keys);
      await ref
          .read(fileTransferProvider.notifier)
          .resumeServerTransfer(
            task: task,
            sourceServer: sourceServer,
            sourceKey: sourceKey,
            targetServer: server,
            targetKey: targetKey,
          );
      return;
    }
    final key = await resolveServerKey(
      server,
      ref.read(keyListProvider.future),
    );
    await ref.read(fileTransferProvider.notifier).resume(task, server, key);
  }
}

enum _TransferFilter { all, upload, download, server }

enum _TransferAction { pause, resume, cancel, delete }
