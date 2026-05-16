part of 'terminal_tabs_page.dart';

extension _TerminalTabsTmux on _TerminalTabsPageState {
  List<OrbitaMenuAction<String>> _connectionMenuActions(AppLocalizations l10n) =>
      [
        OrbitaMenuAction(
          value: 'direct',
          icon: Ionicons.terminal_outline,
          label: l10n.terminalConnectDirect,
        ),
        OrbitaMenuAction(
          value: 'tmux',
          icon: Ionicons.layers_outline,
          label: l10n.terminalReuseTmuxShort,
        ),
        OrbitaMenuAction(
          value: 'edit',
          icon: Ionicons.create_outline,
          label: l10n.commonEdit,
          dividerBefore: true,
        ),
        OrbitaMenuAction(
          value: 'delete',
          icon: Ionicons.trash_outline,
          label: l10n.commonDelete,
          destructive: true,
        ),
      ];

  void _handleConnectionMenuAction(
    BuildContext context,
    WidgetRef ref,
    Server server,
    String value,
  ) {
    if (!context.mounted) return;
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
      final success = await showOrbitaDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context, animation) => RemoteScriptOutputDialog(
          title: l10n.scriptRunningOn(script.name, server.name),
          successMessage: l10n.scriptRunSucceeded,
          failureMessage: l10n.scriptRunFailed,
          onRun: (onOutput) =>
              service.run(server, script: script, key: key, onOutput: onOutput),
          animation: animation,
        ),
      );
      if (success != true || !context.mounted) return;
    }
    _assignServer(server.id, launchMode: TerminalLaunchMode.tmux);
  }
}
