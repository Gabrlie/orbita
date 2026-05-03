import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:open_filex/open_filex.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/models/file_download_task.dart';
import 'package:orbita/providers/file_download_provider.dart';
import 'package:orbita/providers/key_provider.dart';
import 'package:orbita/providers/server_monitor_provider.dart';
import 'package:orbita/providers/server_provider.dart';
import 'package:orbita/utils/format_utils.dart';
import 'package:orbita/widgets/common.dart';

class DownloadCenterPage extends ConsumerWidget {
  const DownloadCenterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final tasks = ref.watch(fileDownloadProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.fileDownloadCenter)),
      body: tasks.isEmpty
          ? EmptyState(
              icon: Ionicons.download_outline,
              title: l10n.fileNoDownloads,
            )
          : ListView.separated(
              itemCount: tasks.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) =>
                  _DownloadTile(task: tasks[index]),
            ),
    );
  }
}

class _DownloadTile extends ConsumerWidget {
  final FileDownloadTask task;

  const _DownloadTile({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
      leading: Icon(_icon, color: Theme.of(context).colorScheme.primary),
      title: Text(task.fileName, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${task.serverName} · ${_statusText(l10n)}'),
          const SizedBox(height: 6),
          LinearProgressIndicator(value: task.progress.clamp(0, 1)),
          const SizedBox(height: 4),
          Text(
            '${formatBytes(task.downloadedBytes)} / ${formatBytes(task.totalBytes)}',
          ),
        ],
      ),
      isThreeLine: true,
      onTap: () => _handleTap(context, ref),
      onLongPress: () => _handleLongPress(context, ref),
    );
  }

  IconData get _icon {
    return switch (task.status) {
      FileDownloadStatus.completed => Ionicons.checkmark_circle_outline,
      FileDownloadStatus.failed => Ionicons.warning_outline,
      FileDownloadStatus.paused => Ionicons.pause_circle_outline,
      FileDownloadStatus.canceled => Ionicons.close_circle_outline,
      _ => Ionicons.download_outline,
    };
  }

  String _statusText(AppLocalizations l10n) {
    return switch (task.status) {
      FileDownloadStatus.queued => l10n.fileDownloadQueued,
      FileDownloadStatus.downloading => l10n.fileDownloading,
      FileDownloadStatus.paused => l10n.fileDownloadPaused,
      FileDownloadStatus.completed => l10n.fileDownloadCompleted,
      FileDownloadStatus.failed => task.error ?? l10n.fileDownloadFailed,
      FileDownloadStatus.canceled => l10n.fileDownloadCanceled,
    };
  }

  Future<void> _handleTap(BuildContext context, WidgetRef ref) async {
    if (task.status == FileDownloadStatus.completed) {
      await OpenFilex.open(task.localPath);
      return;
    }
    if (task.status == FileDownloadStatus.downloading) {
      await ref.read(fileDownloadProvider.notifier).pause(task.id);
      return;
    }
    if (task.status == FileDownloadStatus.paused ||
        task.status == FileDownloadStatus.failed) {
      await _resume(context, ref);
    }
  }

  Future<void> _handleLongPress(BuildContext context, WidgetRef ref) async {
    if (task.status == FileDownloadStatus.completed) {
      final l10n = AppLocalizations.of(context)!;
      final confirmed = await showConfirmDialog(
        context,
        title: l10n.fileDeleteLocalTitle,
        content: l10n.fileDeleteLocalContent(task.fileName),
        confirmLabel: l10n.commonDelete,
        destructive: true,
      );
      if (confirmed) {
        await ref.read(fileDownloadProvider.notifier).deleteCompleted(task.id);
      }
      return;
    }

    final choice = await showMenu<_DownloadAction>(
      context: context,
      position: const RelativeRect.fromLTRB(64, 120, 24, 0),
      items: [
        PopupMenuItem(
          value: _DownloadAction.pause,
          enabled: task.status == FileDownloadStatus.downloading,
          child: Text(AppLocalizations.of(context)!.filePause),
        ),
        PopupMenuItem(
          value: _DownloadAction.resume,
          enabled:
              task.status == FileDownloadStatus.paused ||
              task.status == FileDownloadStatus.failed,
          child: Text(AppLocalizations.of(context)!.fileResume),
        ),
        PopupMenuItem(
          value: _DownloadAction.cancel,
          enabled: task.status != FileDownloadStatus.canceled,
          child: Text(AppLocalizations.of(context)!.commonCancel),
        ),
      ],
    );
    if (!context.mounted) return;
    if (choice == _DownloadAction.pause) {
      await ref.read(fileDownloadProvider.notifier).pause(task.id);
    } else if (choice == _DownloadAction.resume) {
      await _resume(context, ref);
    } else if (choice == _DownloadAction.cancel) {
      await ref.read(fileDownloadProvider.notifier).cancel(task.id);
    }
  }

  Future<void> _resume(BuildContext context, WidgetRef ref) async {
    final server = ref.read(serverByIdProvider(task.serverId));
    if (server == null) return;
    final key = await resolveServerKey(
      server,
      ref.read(keyListProvider.future),
    );
    await ref.read(fileDownloadProvider.notifier).resume(task, server, key);
  }
}

enum _DownloadAction { pause, resume, cancel }
