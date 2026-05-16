part of 'terminal_page.dart';

extension _TerminalActions on _TerminalPageState {
  void _openDashboard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => Scaffold(
          appBar: compactPageAppBar(context, title: l10n.terminalDashboard),
          body: TerminalDashboard(serverId: widget.serverId),
        ),
      ),
    );
  }

  void _insertSnippet(String command) {
    _terminal.textInput(command);
  }

  Future<void> _promptInstallTmux(Server server, SshKey? key) async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.terminalTmuxUnavailable,
      content: l10n.scriptInstallTmuxPrompt,
      confirmLabel: l10n.fileInstallTools,
    );
    if (!confirmed || !mounted) return;
    final service = ref.read(remoteScriptServiceProvider);
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
    if (success == true && mounted) {
      await _connect();
    }
  }
}
