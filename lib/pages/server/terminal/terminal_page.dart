import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/models/server.dart';
import 'package:orbita/models/ssh_key.dart';
import 'package:orbita/pages/server/terminal/terminal_body.dart';
import 'package:orbita/pages/server/terminal/terminal_dashboard.dart';
import 'package:orbita/pages/server/terminal/terminal_extra_key_controller.dart';
import 'package:orbita/pages/server/terminal/terminal_launch_mode.dart';
import 'package:orbita/pages/server/terminal/terminal_platform.dart';
import 'package:orbita/providers/key_provider.dart';
import 'package:orbita/providers/remote_script_provider.dart';
import 'package:orbita/providers/server_monitor_provider.dart';
import 'package:orbita/providers/server_provider.dart';
import 'package:orbita/providers/server_refresh_provider.dart';
import 'package:orbita/providers/ssh_connection_provider.dart';
import 'package:orbita/providers/ssh_log_provider.dart';
import 'package:orbita/services/ssh_connection_manager.dart';
import 'package:orbita/services/ssh_service.dart';
import 'package:orbita/widgets/common.dart';
import 'package:orbita/widgets/remote_script_output_dialog.dart';
import 'package:xterm/xterm.dart';

part 'terminal_connection.dart';

class TerminalPage extends ConsumerStatefulWidget {
  final String serverId;
  final bool showAppBar;
  final TerminalLaunchMode launchMode;
  final String? initialCommand;
  final String? title;

  const TerminalPage({
    super.key,
    required this.serverId,
    this.showAppBar = true,
    this.launchMode = TerminalLaunchMode.direct,
    this.initialCommand,
    this.title,
  });

  @override
  ConsumerState<TerminalPage> createState() => _TerminalPageState();
}

class _TerminalPageState extends ConsumerState<TerminalPage> {
  late final Terminal _terminal;
  late final TerminalExtraKeyController _extraKeyController;

  final _subscriptions = <StreamSubscription<String>>[];

  SshConnectionLease? _connectionLease;
  SshShellSession? _shell;
  String? _title;
  bool _connecting = true;

  @override
  void initState() {
    super.initState();
    _terminal = Terminal(
      platform: terminalPlatform(),
      onOutput: _writeToShell,
      onResize: _resizeShell,
    );
    _extraKeyController = TerminalExtraKeyController(_handleExtraKeyOutput);
    WidgetsBinding.instance.addPostFrameCallback((_) => _connect());
  }

  @override
  void dispose() {
    _disposeShell();
    _releaseConnection();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant TerminalPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.serverId != widget.serverId ||
        oldWidget.launchMode != widget.launchMode ||
        oldWidget.initialCommand != widget.initialCommand) {
      unawaited(_connect());
    }
  }

  Future<void> _connect() async {
    final l10n = AppLocalizations.of(context)!;
    final server = ref.read(serverByIdProvider(widget.serverId));
    if (server == null) return;

    final log = SshLogger.fromWidget(ref, server.id);
    _disposeShell();
    _releaseConnection();

    setState(() {
      _title = widget.title ?? server.name;
      _connecting = true;
    });
    _terminal.write('${l10n.sshConnecting}\r\n');

    SshKey? key;
    try {
      key = await resolveServerKey(server, ref.read(keyListProvider.future));
      if (server.authType == AuthType.key && key == null) {
        throw StateError(l10n.authNoKey);
      }

      log.info('Opening terminal for ${server.host}:${server.port}');
      _shell = await _openShellWithRetry(server, key, log, l10n);

      _terminal.buffer.clear();
      _terminal.buffer.setCursor(0, 0);
      _listenToShell(_shell!);

      if (widget.launchMode == TerminalLaunchMode.tmux) {
        final sessionName = tmuxSessionNameForServer(server);
        _terminal.write('${l10n.terminalTmuxAttaching(sessionName)}\r\n');
        _shell!.write(utf8.encode('tmux new-session -A -s $sessionName\n'));
        log.info('Attached tmux session $sessionName');
      }

      final initialCommand = widget.initialCommand?.trim();
      if (initialCommand != null && initialCommand.isNotEmpty) {
        _shell!.write(utf8.encode('$initialCommand\n'));
        log.info('Sent initial terminal command');
      }

      log.info('Terminal shell opened');
      ref
          .read(serverRefreshControllerProvider.notifier)
          .refreshServer(server.id);

      if (!mounted) return;
      setState(() => _connecting = false);
    } catch (error) {
      log.error('Terminal connection failed', '$error');
      _disposeShell();
      _releaseConnection();
      _terminal.write('${l10n.sshConnectionFailed}: $error\r\n');
      if (widget.launchMode == TerminalLaunchMode.tmux &&
          '$error'.contains(l10n.terminalTmuxUnavailable)) {
        await _promptInstallTmux(server, key);
      }
      if (mounted) {
        setState(() => _connecting = false);
      }
    }
  }

  void _listenToShell(SshShellSession shell) {
    _subscriptions
      ..add(
        shell.stdout
            .cast<List<int>>()
            .transform(utf8.decoder)
            .listen(_terminal.write),
      )
      ..add(
        shell.stderr
            .cast<List<int>>()
            .transform(utf8.decoder)
            .listen(_terminal.write),
      );

    shell.done.then((_) {
      if (!mounted) return;
      _terminal.write(
        '\r\n${AppLocalizations.of(context)!.sshDisconnected}\r\n',
      );
    });
  }

  void _disposeShell() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    _shell?.close();
    _shell = null;
  }

  void _releaseConnection() {
    _connectionLease?.release();
    _connectionLease = null;
  }

  void _writeToShell(String data) {
    _shell?.write(utf8.encode(data));
  }

  void _resizeShell(int columns, int rows, int pixelWidth, int pixelHeight) {
    _shell?.resizeTerminal(columns, rows, pixelWidth, pixelHeight);
  }

  void _handleExtraKeyOutput(TerminalExtraKeyOutput output) {
    if (output.text != null) {
      final text = output.text!;
      if (text.length == 1 && (output.ctrl || output.alt)) {
        _terminal.charInput(
          text.codeUnitAt(0),
          ctrl: output.ctrl,
          alt: output.alt,
        );
      } else {
        _terminal.textInput(text);
      }
    } else if (output.key != null) {
      _terminal.keyInput(
        mapSemanticKey(output.key!),
        ctrl: output.ctrl,
        alt: output.alt,
      );
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _handleExtraKey(TerminalExtraKey key) {
    _extraKeyController.press(key);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final server = ref.watch(serverByIdProvider(widget.serverId));
    final title = _title ?? server?.name ?? l10n.navTerminal;
    final touchPlatform = isTouchPlatform();

    if (server == null) {
      return EmptyState(
        icon: Ionicons.terminal,
        title: l10n.noServersTitle,
        subtitle: l10n.noServersSubtitle,
      );
    }

    final body = TerminalBody(
      serverId: widget.serverId,
      terminal: _terminal,
      showExtraKeys: touchPlatform,
      showDesktopDashboard: !touchPlatform,
      connecting: _connecting,
      ctrlEnabled: _extraKeyController.ctrlEnabled,
      altEnabled: _extraKeyController.altEnabled,
      onExtraKey: _handleExtraKey,
    );

    if (!widget.showAppBar) {
      return body;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: const BackButton(),
        actions: [
          if (touchPlatform)
            IconButton(
              tooltip: l10n.terminalDashboard,
              icon: const Icon(Ionicons.ellipsis_horizontal),
              onPressed: () => _openDashboard(context),
            ),
        ],
      ),
      body: body,
    );
  }

  void _openDashboard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text(l10n.terminalDashboard)),
          body: TerminalDashboard(serverId: widget.serverId),
        ),
      ),
    );
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
    if (success == true && mounted) {
      await _connect();
    }
  }
}
