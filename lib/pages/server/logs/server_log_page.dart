import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/models/ssh_log.dart';
import 'package:orbita/providers/server_provider.dart';
import 'package:orbita/providers/ssh_log_provider.dart';
import 'package:orbita/widgets/common.dart';

class ServerLogPage extends ConsumerWidget {
  final String serverId;

  const ServerLogPage({super.key, required this.serverId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final server = ref.watch(serverByIdProvider(serverId));
    final logs = ref.watch(sshLogProvider(serverId)).reversed.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          server == null
              ? l10n.serverLogsTitle
              : '${server.name} · ${l10n.serverLogsTitle}',
        ),
      ),
      body: logs.isEmpty
          ? EmptyState(
              icon: Icons.receipt_long_outlined,
              title: l10n.serverLogsEmpty,
              subtitle: l10n.serverLogsEmptySubtitle,
            )
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: logs.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                return _LogEntryTile(entry: logs[index]);
              },
            ),
    );
  }
}

class _LogEntryTile extends StatelessWidget {
  final SshLogEntry entry;

  const _LogEntryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final color = _levelColor(theme, entry.level);
    final detail = entry.detail;

    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_levelIcon(entry.level), size: 18, color: color),
                const SizedBox(width: 8),
                Text(
                  _levelLabel(l10n, entry.level),
                  style: theme.textTheme.labelMedium?.copyWith(color: color),
                ),
                const Spacer(),
                Text(
                  _formatTime(entry.timestamp),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(entry.message, style: theme.textTheme.bodyMedium),
            if (detail != null && detail.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: SelectableText(
                  detail,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _levelColor(ThemeData theme, SshLogLevel level) {
    return switch (level) {
      SshLogLevel.info => theme.colorScheme.primary,
      SshLogLevel.error => theme.colorScheme.error,
      SshLogLevel.command => theme.colorScheme.tertiary,
    };
  }

  IconData _levelIcon(SshLogLevel level) {
    return switch (level) {
      SshLogLevel.info => Icons.info_outline,
      SshLogLevel.error => Icons.error_outline,
      SshLogLevel.command => Icons.code,
    };
  }

  String _levelLabel(AppLocalizations l10n, SshLogLevel level) {
    return switch (level) {
      SshLogLevel.info => l10n.serverLogLevelInfo,
      SshLogLevel.error => l10n.serverLogLevelError,
      SshLogLevel.command => l10n.serverLogLevelCommand,
    };
  }

  String _formatTime(DateTime time) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    return '${twoDigits(time.hour)}:${twoDigits(time.minute)}:${twoDigits(time.second)}';
  }
}
