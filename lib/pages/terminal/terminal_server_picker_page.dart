import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/models/server.dart';
import 'package:orbita/pages/server/terminal/terminal_launch_mode.dart';
import 'package:orbita/providers/remote_script_provider.dart';
import 'package:orbita/providers/server_provider.dart';
import 'package:orbita/widgets/action_sheet.dart';
import 'package:orbita/widgets/common.dart';
import 'package:orbita/widgets/os_icon.dart';
import 'package:orbita/widgets/remote_script_output_dialog.dart';

class TerminalServerPickerPage extends ConsumerWidget {
  const TerminalServerPickerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final serversAsync = ref.watch(serverListProvider);

    return Scaffold(
      appBar: AppBar(),
      body: serversAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (servers) {
          if (servers.isEmpty) {
            return EmptyState(
              icon: Ionicons.terminal,
              title: l10n.noServersTitle,
              subtitle: l10n.noServersSubtitle,
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: servers.length,
            itemBuilder: (context, index) {
              return _TerminalServerTile(server: servers[index]);
            },
          );
        },
      ),
    );
  }
}

class _TerminalServerTile extends ConsumerWidget {
  final Server server;

  const _TerminalServerTile({required this.server});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      elevation: 3,
      shadowColor: theme.colorScheme.shadow.withAlpha(32),
      surfaceTintColor: Colors.transparent,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openTerminal(context),
        onLongPress: () => _showConnectionMenu(context, ref),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              OsIcon(type: server.osType, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      server.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${server.host}:${server.port}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Ionicons.chevron_forward,
                size: 20,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConnectionMenu(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    showActionSheet(
      context,
      title: l10n.terminalConnectOptions,
      items: [
        ActionSheetItem(
          icon: Ionicons.terminal_outline,
          label: l10n.actionConnect,
          onTap: () => _openTerminal(context),
        ),
        ActionSheetItem(
          icon: Ionicons.layers_outline,
          label: l10n.terminalConnectTmux,
          onTap: () => unawaited(_openTmuxTerminal(context, ref)),
        ),
      ],
    );
  }

  Future<void> _openTmuxTerminal(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final service = ref.read(remoteScriptServiceProvider);
    final key = await resolveRemoteScriptKey(ref, server);
    final missing = await service.missingTools(
      server,
      tools: const ['tmux'],
      key: key,
    );
    if (missing.isNotEmpty) {
      if (!context.mounted) return;
      final confirmed = await showConfirmDialog(
        context,
        title: l10n.terminalTmuxUnavailable,
        content: l10n.scriptInstallTmuxPrompt,
        confirmLabel: l10n.fileInstallTools,
      );
      if (!confirmed || !context.mounted) return;
      final script = service
          .builtInScripts(
            archiveName: l10n.scriptInstallArchiveTools,
            archiveDescription: l10n.scriptInstallArchiveToolsDesc,
            dockerName: l10n.scriptInstallDocker,
            dockerDescription: l10n.scriptInstallDockerDesc,
            tmuxName: l10n.scriptInstallTmux,
            tmuxDescription: l10n.scriptInstallTmuxDesc,
            mirrorName: l10n.scriptChangeMirror,
            mirrorDescription: l10n.scriptChangeMirrorDesc,
            mirrorSelectTitle: l10n.scriptSelectMirror,
            mirrorTunaLabel: l10n.scriptMirrorTuna,
            mirrorUstcLabel: l10n.scriptMirrorUstc,
            mirrorAliyunLabel: l10n.scriptMirrorAliyun,
            mirrorTencentLabel: l10n.scriptMirrorTencent,
            mirrorHuaweiLabel: l10n.scriptMirrorHuawei,
          )
          .firstWhere((script) => script.id == 'install-tmux');
      final success = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => RemoteScriptOutputDialog(
          title: l10n.scriptRunningOn(script.name, server.name),
          successMessage: l10n.scriptRunSucceeded,
          failureMessage: l10n.scriptRunFailed,
          onRun: (onOutput) =>
              service.run(server, script: script, key: key, onOutput: onOutput),
        ),
      );
      if (success != true || !context.mounted) return;
    }
    if (context.mounted) {
      _openTerminal(context, mode: TerminalLaunchMode.tmux);
    }
  }

  void _openTerminal(
    BuildContext context, {
    TerminalLaunchMode mode = TerminalLaunchMode.direct,
  }) {
    final queryMode = terminalLaunchModeToQuery(mode);
    final location = Uri(
      path: '/terminal/${server.id}',
      queryParameters: queryMode == null ? null : {'mode': queryMode},
    ).toString();
    context.go(location);
  }
}
