import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/widgets/orbita_forui.dart';

class RemoteScriptOutputDialog extends StatefulWidget {
  final String title;
  final String successMessage;
  final String failureMessage;
  final Future<void> Function(void Function(String chunk) onOutput) onRun;
  final Animation<double>? animation;

  const RemoteScriptOutputDialog({
    super.key,
    required this.title,
    required this.successMessage,
    required this.failureMessage,
    required this.onRun,
    this.animation,
  });

  @override
  State<RemoteScriptOutputDialog> createState() =>
      _RemoteScriptOutputDialogState();
}

class _RemoteScriptOutputDialogState extends State<RemoteScriptOutputDialog> {
  final _output = StringBuffer();
  final _scrollController = ScrollController();
  Object? _error;
  var _isRunning = true;

  @override
  void initState() {
    super.initState();
    widget
        .onRun(_appendOutput)
        .then(
          (_) {
            if (!mounted) return;
            setState(() => _isRunning = false);
            _appendOutput('\n${widget.successMessage}');
          },
          onError: (error) {
            if (!mounted) return;
            setState(() {
              _error = error;
              _isRunning = false;
            });
            _appendOutput('\n${widget.failureMessage}: $error');
          },
        );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    return PopScope(
      canPop: !_isRunning,
      child: OrbitaDialog(
        animation: widget.animation,
        title: widget.title,
        actions: [
          if (_isRunning)
            const SizedBox(width: 28, height: 28, child: FProgress())
          else
            OrbitaDialogAction(
              label: l10n.commonOk,
              onPress: () => Navigator.of(context).pop(_error == null),
            ),
        ],
        child: SizedBox(
          width: 520,
          height: 320,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              child: SelectableText(
                _output.isEmpty ? l10n.fileInstallWaiting : _output.toString(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                  height: 1.35,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _appendOutput(String chunk) {
    if (!mounted || chunk.isEmpty) return;
    setState(() => _output.write(chunk));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }
}
