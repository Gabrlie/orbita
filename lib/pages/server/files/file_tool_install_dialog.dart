import 'package:flutter/material.dart';
import 'package:orbita/l10n/app_localizations.dart';

class FileToolInstallDialog extends StatefulWidget {
  final List<String> tools;
  final Future<void> Function(void Function(String chunk) onOutput) onInstall;

  const FileToolInstallDialog({
    super.key,
    required this.tools,
    required this.onInstall,
  });

  @override
  State<FileToolInstallDialog> createState() => _FileToolInstallDialogState();
}

class _FileToolInstallDialogState extends State<FileToolInstallDialog> {
  final _output = StringBuffer();
  final _scrollController = ScrollController();
  Object? _error;
  var _isRunning = true;

  @override
  void initState() {
    super.initState();
    widget
        .onInstall(_appendOutput)
        .then(
          (_) {
            if (!mounted) return;
            setState(() => _isRunning = false);
            _appendOutput(
              '\n${AppLocalizations.of(context)!.fileInstallSucceeded}',
            );
          },
          onError: (error) {
            if (!mounted) return;
            setState(() {
              _error = error;
              _isRunning = false;
            });
            _appendOutput(
              '\n${AppLocalizations.of(context)!.fileInstallFailed}: $error',
            );
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
      child: AlertDialog(
        title: Text(l10n.fileInstallingTools(widget.tools.join(', '))),
        content: SizedBox(
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
        actions: [
          if (_isRunning)
            const Padding(
              padding: EdgeInsetsDirectional.only(end: 12),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            FilledButton(
              onPressed: () => Navigator.of(context).pop(_error == null),
              child: Text(l10n.commonOk),
            ),
        ],
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
