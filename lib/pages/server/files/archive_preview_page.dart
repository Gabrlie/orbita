import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/models/remote_file_entry.dart';
import 'package:orbita/providers/key_provider.dart';
import 'package:orbita/providers/server_monitor_provider.dart';
import 'package:orbita/providers/server_provider.dart';
import 'package:orbita/providers/sftp_file_provider.dart';
import 'package:orbita/pages/server/files/file_entry_tile.dart';
import 'package:orbita/pages/server/files/file_path_bar.dart';
import 'package:orbita/services/sftp_file_service.dart';
import 'package:orbita/widgets/common.dart';

class ArchivePreviewPage extends ConsumerStatefulWidget {
  final String serverId;
  final RemoteFileEntry entry;

  const ArchivePreviewPage({
    super.key,
    required this.serverId,
    required this.entry,
  });

  @override
  ConsumerState<ArchivePreviewPage> createState() => _ArchivePreviewPageState();
}

class _ArchivePreviewPageState extends ConsumerState<ArchivePreviewPage> {
  late Future<List<String>> _preview;
  var _currentPath = '/';

  @override
  void initState() {
    super.initState();
    _preview = _loadPreview();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(widget.entry.name)),
      body: FutureBuilder<List<String>>(
        future: _preview,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return EmptyState(
              icon: Ionicons.archive_outline,
              title: l10n.fileArchivePreviewFailed,
              subtitle: '${snapshot.error}',
            );
          }
          final paths = snapshot.data ?? const [];
          if (paths.isEmpty) {
            return EmptyState(
              icon: Ionicons.archive_outline,
              title: l10n.fileArchivePreviewEmpty,
            );
          }
          final entries = archivePreviewEntriesForPath(paths, _currentPath);
          final parent = createParentRemoteEntry(_currentPath);
          final visible = parent == null ? entries : [parent, ...entries];
          return Column(
            children: [
              FilePathBar(
                path: _displayPath,
                onTapPath: (path) => setState(() {
                  _currentPath = _previewPathFromDisplayPath(
                    path,
                    widget.entry.name,
                  );
                }),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: visible.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = visible[index];
                    return FileEntryTile(
                      entry: item,
                      onTap: item.isDirectory
                          ? () => setState(() => _currentPath = item.path)
                          : null,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String get _displayPath {
    return _currentPath == '/'
        ? '/${widget.entry.name}'
        : '/${widget.entry.name}${normalizeRemotePath(_currentPath)}';
  }

  Future<List<String>> _loadPreview() async {
    final server = ref.read(serverByIdProvider(widget.serverId));
    if (server == null) return const [];
    final key = await resolveServerKey(
      server,
      ref.read(keyListProvider.future),
    );
    final output = await ref
        .read(sftpFileServiceProvider)
        .previewArchive(server, entry: widget.entry, key: key);
    return parseArchivePreviewPaths(output);
  }
}

List<RemoteFileEntry> archivePreviewEntriesForPath(
  List<String> paths,
  String currentPath,
) {
  final current = normalizeRemotePath(currentPath);
  final entries = <String, RemoteFileEntry>{};
  for (final path in paths) {
    final directoryMarker = path.trim().replaceAll('\\', '/').endsWith('/');
    final item = normalizeArchivePreviewItemPath(path);
    if (item.isEmpty) continue;
    final segments = item.split('/').where((part) => part.isNotEmpty).toList();
    final currentSegments = current == '/'
        ? const <String>[]
        : current.substring(1).split('/');
    if (segments.length <= currentSegments.length) continue;
    var matches = true;
    for (var i = 0; i < currentSegments.length; i++) {
      if (segments[i] != currentSegments[i]) {
        matches = false;
        break;
      }
    }
    if (!matches) continue;
    final name = segments[currentSegments.length];
    if (name.trim().isEmpty) continue;
    final isDirectory =
        segments.length > currentSegments.length + 1 || directoryMarker;
    final entryPath = current == '/' ? '/$name' : '$current/$name';
    entries[entryPath] = RemoteFileEntry(
      name: name,
      path: entryPath,
      isDirectory: isDirectory,
    );
  }
  final sorted = entries.values.toList();
  sorted.sort((left, right) {
    if (left.isDirectory != right.isDirectory) return left.isDirectory ? -1 : 1;
    return left.name.toLowerCase().compareTo(right.name.toLowerCase());
  });
  return sorted;
}

List<String> parseArchivePreviewPaths(String output) {
  return output
      .split('\n')
      .map(archivePathFromPreviewLine)
      .where((path) => path.isNotEmpty)
      .toSet()
      .toList();
}

String archivePathFromPreviewLine(String line) {
  final trimmed = line.trim();
  if (trimmed.trim().isEmpty ||
      trimmed.startsWith('Archive:') ||
      trimmed.startsWith('Length') ||
      trimmed.startsWith('Date') ||
      trimmed.startsWith('Path =') ||
      trimmed.startsWith('Physical Size =') ||
      trimmed.startsWith('Scanning the drive') ||
      RegExp(r'^[-\s]+$').hasMatch(trimmed) ||
      trimmed.startsWith('----') ||
      trimmed.startsWith('----------------') ||
      RegExp(r'^\d+\s+files?,').hasMatch(trimmed) ||
      trimmed.endsWith(' files')) {
    return '';
  }
  final unzip = RegExp(
    r'^\s*\d+\s+\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2}\s+(.+)$',
  ).firstMatch(trimmed);
  if (unzip != null) return normalizeArchivePreviewItemPath(unzip.group(1)!);
  final sevenZip = RegExp(
    r'^\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2}\s+\S+\s+\d+\s+\d+\s+(.+)$',
  ).firstMatch(trimmed);
  if (sevenZip != null) {
    return normalizeArchivePreviewItemPath(sevenZip.group(1)!);
  }
  return normalizeArchivePreviewItemPath(trimmed);
}

String normalizeArchivePreviewItemPath(String path) {
  var value = path.trim().replaceAll('\\', '/');
  while (value.startsWith('./')) {
    value = value.substring(2);
  }
  while (value.startsWith('/')) {
    value = value.substring(1);
  }
  while (value.endsWith('/')) {
    value = value.substring(0, value.length - 1);
  }
  return value;
}

String _previewPathFromDisplayPath(String path, String archiveName) {
  final normalized = normalizeRemotePath(path);
  final root = '/$archiveName';
  if (normalized == root || normalized == '/') return '/';
  if (normalized.startsWith('$root/')) {
    return normalizeRemotePath(normalized.substring(root.length));
  }
  return normalized;
}
