import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/models/server.dart';
import 'package:orbita/models/ssh_key.dart';
import 'package:orbita/providers/key_provider.dart';
import 'package:orbita/providers/server_monitor_provider.dart';
import 'package:orbita/providers/server_provider.dart';
import 'package:orbita/providers/sftp_file_provider.dart';
import 'package:orbita/providers/ssh_log_provider.dart';
import 'package:orbita/services/sftp_file_service.dart';
import 'package:orbita/widgets/common.dart';
import 'package:syntax_highlight/syntax_highlight.dart';

class FileTextEditorPage extends ConsumerStatefulWidget {
  final String serverId;
  final String path;
  final String fileName;

  const FileTextEditorPage({
    super.key,
    required this.serverId,
    required this.path,
    required this.fileName,
  });

  @override
  ConsumerState<FileTextEditorPage> createState() => _FileTextEditorPageState();
}

class _FileTextEditorPageState extends ConsumerState<FileTextEditorPage> {
  late final TextEditingController _plainController;
  CodeEditorController? _codeController;
  var _isLoading = true;
  var _isSaving = false;
  var _isDirty = false;
  String? _error;

  TextEditingController get _controller => _codeController ?? _plainController;

  @override
  void initState() {
    super.initState();
    _plainController = TextEditingController()
      ..addListener(() {
        if (!_isDirty) setState(() => _isDirty = true);
      });
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadFile());
  }

  @override
  void dispose() {
    _plainController.dispose();
    _codeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final server = ref.watch(serverByIdProvider(widget.serverId));

    return PopScope(
      canPop: !_isDirty || _isSaving,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop || !_isDirty || _isSaving) return;
        final discard = await showConfirmDialog(
          context,
          title: l10n.fileDiscardTitle,
          content: l10n.fileDiscardContent,
          confirmLabel: l10n.fileDiscardConfirm,
          destructive: true,
        );
        if (discard && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.fileName),
          actions: [
            IconButton(
              tooltip: l10n.commonSave,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Ionicons.save_outline),
              onPressed: _isDirty && !_isSaving && !_isLoading && server != null
                  ? () => _saveFile(server)
                  : null,
            ),
          ],
        ),
        body: _buildBody(l10n, server),
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n, Server? server) {
    if (server == null) {
      return EmptyState(
        icon: Ionicons.warning_outline,
        title: l10n.fileServerMissing,
        subtitle: l10n.fileServerMissingSubtitle,
      );
    }

    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(l10n.fileLoadingFile),
          ],
        ),
      );
    }

    if (_error != null) {
      return EmptyState(
        icon: Ionicons.warning_outline,
        title: l10n.fileLoadFailed,
        subtitle: _error,
      );
    }

    const textStyle = TextStyle(fontFamily: 'JetBrains Mono', fontSize: 14);
    if (_codeController != null) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: CodeEditor(textStyle: textStyle, controller: _codeController!),
      );
    }

    return TextField(
      controller: _plainController,
      expands: true,
      maxLines: null,
      minLines: null,
      keyboardType: TextInputType.multiline,
      textAlignVertical: TextAlignVertical.top,
      style: textStyle,
      decoration: InputDecoration(
        border: InputBorder.none,
        contentPadding: const EdgeInsets.all(16),
        hintText: widget.path,
      ),
    );
  }

  Future<void> _loadFile() async {
    final server = ref.read(serverByIdProvider(widget.serverId));
    if (server == null) return;
    final log = SshLogger.fromWidget(ref, server.id);

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final service = ref.read(sftpFileServiceProvider);
      final key = await _resolveKey(server);
      log.info('SFTP read ${widget.path}');
      final content = await service.readTextFile(
        server,
        path: widget.path,
        key: key,
      );
      if (!mounted) return;
      await _setupController(content);
      setState(() {
        _isLoading = false;
        _isDirty = false;
      });
    } catch (error) {
      log.error('SFTP read failed', '$error');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = _messageForError(error);
      });
    }
  }

  Future<void> _saveFile(Server server) async {
    final l10n = AppLocalizations.of(context)!;
    final log = SshLogger.fromWidget(ref, server.id);
    setState(() => _isSaving = true);

    try {
      final service = ref.read(sftpFileServiceProvider);
      final key = await _resolveKey(server);
      log.info('SFTP write ${widget.path}');
      await service.writeTextFile(
        server,
        path: widget.path,
        content: _controller.text,
        key: key,
      );
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _isDirty = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.fileSaveSuccess)));
    } catch (error) {
      log.error('SFTP write failed', '$error');
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${l10n.fileSaveFailed}: $error')));
    }
  }

  Future<SshKey?> _resolveKey(Server server) {
    return resolveServerKey(server, ref.read(keyListProvider.future));
  }

  String _messageForError(Object error) {
    final l10n = AppLocalizations.of(context)!;
    if (error is SftpFileException) {
      return switch (error.code) {
        'tooLarge' => l10n.fileTooLarge,
        'binary' => l10n.fileBinaryUnsupported,
        _ => '$error',
      };
    }
    return '$error';
  }

  Future<void> _setupController(String content) async {
    final language = _languageForFileName(widget.fileName);
    if (language == null) {
      _plainController.text = content;
      return;
    }

    try {
      await Highlighter.initialize([language]);
      final lightTheme = await HighlighterTheme.loadLightTheme();
      final darkTheme = await HighlighterTheme.loadDarkTheme();
      final controller =
          CodeEditorController(
            text: content,
            lightHighlighter: Highlighter(
              language: language,
              theme: lightTheme,
            ),
            darkHighlighter: Highlighter(language: language, theme: darkTheme),
          )..addListener(() {
            if (!_isDirty) setState(() => _isDirty = true);
          });
      _codeController?.dispose();
      _codeController = controller;
    } catch (_) {
      _plainController.text = content;
    }
  }

  String? _languageForFileName(String fileName) {
    final normalized = fileName.toLowerCase();
    if (normalized.endsWith('.dart')) return 'dart';
    if (normalized.endsWith('.yaml') || normalized.endsWith('.yml')) {
      return 'yaml';
    }
    if (normalized.endsWith('.json')) return 'json';
    if (normalized.endsWith('.js')) return 'javascript';
    if (normalized.endsWith('.ts')) return 'typescript';
    if (normalized.endsWith('.html')) return 'html';
    if (normalized.endsWith('.css')) return 'css';
    if (normalized.endsWith('.py')) return 'python';
    if (normalized.endsWith('.go')) return 'go';
    if (normalized.endsWith('.rs')) return 'rust';
    if (normalized.endsWith('.java')) return 'java';
    if (normalized.endsWith('.kt')) return 'kotlin';
    if (normalized.endsWith('.sql')) return 'sql';
    return null;
  }
}
