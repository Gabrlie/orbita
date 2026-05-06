part of 'terminal_tabs_page.dart';

extension _TerminalTabsTmux on _TerminalTabsPageState {
  void _showConnectionMenu(
    BuildContext context,
    WidgetRef ref,
    Server server,
    Offset position,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final relativeRect = RelativeRect.fromRect(
      Rect.fromLTWH(position.dx, position.dy, 0, 0),
      Offset.zero & overlay.size,
    );

    showMenu<String>(
      context: context,
      position: relativeRect,
      items: [
        _terminalMenuItem(
          'direct',
          Ionicons.terminal_outline,
          l10n.terminalConnectDirect,
        ),
        _terminalMenuItem(
          'tmux',
          Ionicons.layers_outline,
          l10n.terminalReuseTmuxShort,
        ),
        const PopupMenuDivider(),
        _terminalMenuItem('edit', Ionicons.create_outline, l10n.commonEdit),
        PopupMenuItem(
          value: 'delete',
          height: 44,
          child: Row(
            children: [
              Icon(
                Ionicons.trash_outline,
                size: 18,
                color: theme.colorScheme.error,
              ),
              const SizedBox(width: 10),
              Text(
                l10n.commonDelete,
                style: TextStyle(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == null || !context.mounted) return;
      switch (value) {
        case 'direct':
          _assignServer(server.id, launchMode: TerminalLaunchMode.direct);
        case 'tmux':
          unawaited(_openTmuxTerminal(context, ref, server));
        case 'edit':
          context.go('/settings/servers/${server.id}/edit');
        case 'delete':
          _confirmDeleteServer(context, ref, server);
      }
    });
  }

  PopupMenuItem<String> _terminalMenuItem(
    String value,
    IconData icon,
    String label,
  ) {
    return PopupMenuItem(
      value: value,
      height: 44,
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteServer(
    BuildContext context,
    WidgetRef ref,
    Server server,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.deleteServerTitle,
      content: l10n.deleteServerContent(server.name),
      confirmLabel: l10n.commonDelete,
      destructive: true,
    );
    if (confirmed) {
      ref.read(serverListProvider.notifier).deleteServer(server.id);
    }
  }

  Future<void> _openTmuxTerminal(
    BuildContext context,
    WidgetRef ref,
    Server server,
  ) async {
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
    _assignServer(server.id, launchMode: TerminalLaunchMode.tmux);
  }
}
