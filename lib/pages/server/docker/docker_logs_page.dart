import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/providers/docker_provider.dart';
import 'package:orbita/providers/server_provider.dart';

class DockerLogsPage extends ConsumerStatefulWidget {
  final String serverId;
  final String title;
  final String command;

  const DockerLogsPage({
    super.key,
    required this.serverId,
    required this.title,
    required this.command,
  });

  @override
  ConsumerState<DockerLogsPage> createState() => _DockerLogsPageState();
}

class _DockerLogsPageState extends ConsumerState<DockerLogsPage> {
  final _output = StringBuffer();
  var _running = false;
  var _stopRequested = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  @override
  void dispose() {
    _stopRequested = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            tooltip: l10n.dockerCopyOutput,
            icon: const Icon(Ionicons.copy_outline),
            onPressed: _output.isEmpty
                ? null
                : () => Clipboard.setData(
                    ClipboardData(text: _output.toString()),
                  ),
          ),
          IconButton(
            tooltip: _running ? l10n.dockerStopStream : l10n.commonRefresh,
            icon: Icon(
              _running ? Ionicons.stop_outline : Ionicons.refresh_outline,
            ),
            onPressed: _running ? _stop : _start,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_error != null)
            MaterialBanner(
              content: Text(_error!),
              actions: [
                TextButton(
                  onPressed: () => setState(() => _error = null),
                  child: Text(l10n.commonOk),
                ),
              ],
            ),
          if (_running)
            const LinearProgressIndicator(minHeight: 2)
          else
            const SizedBox(height: 2),
          Expanded(
            child: SingleChildScrollView(
              reverse: true,
              padding: const EdgeInsets.all(14),
              child: SelectableText(
                _output.isEmpty ? l10n.fileInstallWaiting : _output.toString(),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: 'JetBrains Mono',
                  height: 1.35,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _start() async {
    if (_running) return;
    final l10n = AppLocalizations.of(context)!;
    final server = ref.read(serverByIdProvider(widget.serverId));
    if (server == null) {
      setState(() => _error = l10n.fileServerMissing);
      return;
    }

    setState(() {
      _running = true;
      _stopRequested = false;
      _error = null;
      _output.clear();
    });

    try {
      final key = await resolveDockerKey(ref, server);
      await ref
          .read(dockerServiceProvider)
          .streamLogs(
            server,
            command: widget.command,
            key: key,
            shouldStop: () => _stopRequested,
            onOutput: (chunk) {
              if (!mounted) return;
              setState(() => _output.write(chunk));
            },
          );
    } catch (error) {
      if (!mounted || _stopRequested) return;
      setState(() => _error = '${l10n.dockerActionFailed}: $error');
    } finally {
      if (mounted) {
        setState(() => _running = false);
      }
    }
  }

  void _stop() {
    setState(() => _stopRequested = true);
  }
}
