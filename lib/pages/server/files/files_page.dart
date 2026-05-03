import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/models/remote_file_entry.dart';
import 'package:orbita/models/server.dart';
import 'package:orbita/models/ssh_key.dart';
import 'package:orbita/pages/server/files/archive_preview_page.dart';
import 'package:orbita/pages/server/files/download_center_page.dart';
import 'package:orbita/pages/server/files/file_archive_dialog.dart';
import 'package:orbita/pages/server/files/file_entry_actions_dialog.dart';
import 'package:orbita/pages/server/files/file_entry_tile.dart';
import 'package:orbita/pages/server/files/file_name_dialog.dart';
import 'package:orbita/pages/server/files/file_path_bar.dart';
import 'package:orbita/pages/server/files/file_text_editor_page.dart';
import 'package:orbita/pages/server/files/file_tool_install_dialog.dart';
import 'package:orbita/providers/file_download_provider.dart';
import 'package:orbita/providers/key_provider.dart';
import 'package:orbita/providers/server_monitor_provider.dart';
import 'package:orbita/providers/server_provider.dart';
import 'package:orbita/providers/sftp_file_provider.dart';
import 'package:orbita/providers/ssh_log_provider.dart';
import 'package:orbita/services/remote_file_command_builder.dart';
import 'package:orbita/services/sftp_file_service.dart';
import 'package:orbita/widgets/common.dart';

part 'files_page_actions.dart';
part 'files_page_archive_actions.dart';
part 'files_page_conflict_dialog.dart';
part 'files_page_widgets.dart';

class FilesPage extends ConsumerStatefulWidget {
  final String serverId;
  final bool showAppBar;

  const FilesPage({super.key, required this.serverId, this.showAppBar = true});

  @override
  ConsumerState<FilesPage> createState() => _FilesPageState();
}

class _FilesPageState extends ConsumerState<FilesPage> {
  var _currentPath = '/';
  var _entries = <RemoteFileEntry>[];
  var _isLoading = true;
  var _isMutating = false;
  var _loadRequestId = 0;
  RemoteFileEntry? _pendingEntry;
  FilePendingAction? _pendingAction;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDirectory('/'));
  }

  @override
  void didUpdateWidget(covariant FilesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.serverId != widget.serverId) {
      _currentPath = '/';
      _entries = [];
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadDirectory('/'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final server = ref.watch(serverByIdProvider(widget.serverId));
    final content = _buildContent(context, l10n, server);

    final page = widget.showAppBar
        ? Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Ionicons.chevron_back),
                onPressed: () => context.go('/files'),
              ),
              title: Text(server?.name ?? l10n.navFiles),
              actions: [_downloadButton(), _refreshButton(), _moreButton()],
            ),
            body: content,
          )
        : content;

    return PopScope(
      canPop: _currentPath == '/',
      onPopInvokedWithResult: (didPop, _) {
        if (didPop || _currentPath == '/') return;
        _loadDirectory(parentRemotePath(_currentPath));
      },
      child: page,
    );
  }

  void _setPendingAction(RemoteFileEntry entry, FilePendingAction action) {
    setState(() {
      _pendingEntry = entry;
      _pendingAction = action;
    });
  }

  void _clearPendingAction() {
    setState(() {
      _pendingEntry = null;
      _pendingAction = null;
    });
  }

  Future<void> _loadDirectory(String path) async {
    final server = ref.read(serverByIdProvider(widget.serverId));
    if (server == null || !mounted) return;
    final requestId = ++_loadRequestId;
    final normalizedPath = normalizeRemotePath(path);

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final log = SshLogger.fromWidget(ref, server.id);
    try {
      final service = ref.read(sftpFileServiceProvider);
      final key = await _resolveKey(server);
      log.info('SFTP list $normalizedPath');
      final entries = await service.listDirectory(
        server,
        key: key,
        path: normalizedPath,
      );
      if (!mounted || requestId != _loadRequestId) return;
      setState(() {
        _currentPath = normalizedPath;
        _entries = entries;
        _isLoading = false;
      });
    } catch (error) {
      log.error('SFTP list failed', '$error');
      if (!mounted || requestId != _loadRequestId) return;
      setState(() {
        _isLoading = false;
        _error = _FilesPageActions(this)._messageForError(error);
      });
    }
  }

  Future<void> _runMutation(
    Server server,
    Future<void> Function(SftpFileService service, SshKey? key) action,
  ) async {
    setState(() {
      _isMutating = true;
      _error = null;
    });

    final log = SshLogger.fromWidget(ref, server.id);
    try {
      final service = ref.read(sftpFileServiceProvider);
      final key = await _resolveKey(server);
      await action(service, key);
      await _loadDirectory(_currentPath);
    } catch (error) {
      log.error('SFTP mutation failed', '$error');
      if (!mounted) return;
      setState(() {
        _error = _FilesPageActions(this)._messageForError(error);
      });
    } finally {
      if (mounted) setState(() => _isMutating = false);
    }
  }

  Future<void> _runMutationWithEntries(
    Server server,
    Future<List<RemoteFileEntry>> Function(SftpFileService service, SshKey? key)
    action, {
    bool rethrowErrors = false,
  }) async {
    setState(() {
      _isMutating = true;
      _isLoading = true;
      _error = null;
    });

    final log = SshLogger.fromWidget(ref, server.id);
    try {
      final service = ref.read(sftpFileServiceProvider);
      final key = await _resolveKey(server);
      final entries = await action(service, key);
      if (!mounted) return;
      setState(() {
        _entries = entries;
        _isLoading = false;
      });
    } catch (error) {
      log.error('SFTP mutation failed', '$error');
      if (!mounted) return;
      if (rethrowErrors &&
          error is SftpFileException &&
          error.code == 'targetExists') {
        setState(() => _isLoading = false);
        rethrow;
      }
      setState(() {
        _isLoading = false;
        _error = _FilesPageActions(this)._messageForError(error);
      });
      if (rethrowErrors) rethrow;
    } finally {
      if (mounted) setState(() => _isMutating = false);
    }
  }

  Future<SshKey?> _resolveKey(Server server) {
    return resolveServerKey(server, ref.read(keyListProvider.future));
  }
}
