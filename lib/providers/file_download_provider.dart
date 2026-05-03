import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbita/models/file_download_task.dart';
import 'package:orbita/models/remote_file_entry.dart';
import 'package:orbita/models/server.dart';
import 'package:orbita/models/ssh_key.dart';
import 'package:orbita/providers/settings_provider.dart';
import 'package:orbita/providers/sftp_file_provider.dart';
import 'package:orbita/services/sftp_file_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

final fileDownloadProvider =
    NotifierProvider<FileDownloadController, List<FileDownloadTask>>(
      FileDownloadController.new,
    );

class FileDownloadController extends Notifier<List<FileDownloadTask>> {
  static const _storageKey = 'file_download_tasks';
  final _controls = <String, _DownloadControl>{};

  @override
  List<FileDownloadTask> build() {
    final prefs = ref.read(sharedPrefsProvider);
    final tasks = decodeDownloadTasks(prefs.getString(_storageKey));
    final visibleTasks = tasks
        .where((task) => task.status != FileDownloadStatus.canceled)
        .toList();
    if (visibleTasks.length != tasks.length) {
      unawaited(
        prefs.setString(_storageKey, encodeDownloadTasks(visibleTasks)),
      );
    }
    return visibleTasks;
  }

  Future<void> add(Server server, SshKey? key, RemoteFileEntry entry) async {
    final localPath = await _createLocalPath(server.name, entry.name);
    final task = FileDownloadTask(
      id: const Uuid().v4(),
      serverId: server.id,
      serverName: server.name,
      remotePath: entry.path,
      fileName: entry.name,
      localPath: localPath,
      totalBytes: entry.size,
      downloadedBytes: 0,
      status: FileDownloadStatus.queued,
      createdAt: DateTime.now(),
    );
    state = [task, ...state];
    await _save();
    unawaited(_run(task, server, key));
  }

  Future<void> resume(FileDownloadTask task, Server server, SshKey? key) async {
    if (task.status == FileDownloadStatus.completed) return;
    _update(task.id, status: FileDownloadStatus.queued, error: null);
    await _save();
    unawaited(_run(_taskById(task.id), server, key));
  }

  Future<void> pause(String id) async {
    _controls[id]?.pause = true;
    _update(id, status: FileDownloadStatus.paused, error: null);
    await _save();
  }

  Future<void> cancel(String id) async {
    final task = _taskByIdOrNull(id);
    if (task == null) return;
    final control = _controls[id];
    control?.cancel = true;
    control?.deleteLocalPath = task.localPath;
    state = state.where((task) => task.id != id).toList();
    await _save();
    if (control == null) {
      await _deleteLocalFile(task.localPath);
    }
  }

  Future<void> deleteCompleted(String id) async {
    final task = _taskById(id);
    await _deleteLocalFile(task.localPath);
    state = state.where((task) => task.id != id).toList();
    await _save();
  }

  Future<void> _run(FileDownloadTask task, Server server, SshKey? key) async {
    if (_controls.containsKey(task.id)) return;
    final control = _DownloadControl();
    _controls[task.id] = control;
    final service = ref.read(sftpFileServiceProvider);
    final offset = await _localLength(task.localPath);
    _update(
      task.id,
      status: FileDownloadStatus.downloading,
      downloadedBytes: offset,
      error: null,
    );
    await _save();

    try {
      await service.downloadFile(
        server,
        remotePath: task.remotePath,
        localPath: task.localPath,
        offset: offset,
        key: key,
        shouldStop: () => control.pause || control.cancel,
        onProgress: (bytes) => _update(task.id, downloadedBytes: bytes),
      );
      _update(
        task.id,
        status: FileDownloadStatus.completed,
        downloadedBytes: task.totalBytes,
        completedAt: DateTime.now(),
      );
    } catch (error) {
      final status = control.cancel
          ? FileDownloadStatus.canceled
          : control.pause
          ? FileDownloadStatus.paused
          : FileDownloadStatus.failed;
      _update(task.id, status: status, error: control.pause ? null : '$error');
    } finally {
      if (control.cancel && control.deleteLocalPath != null) {
        await _deleteLocalFile(control.deleteLocalPath!);
      }
      _controls.remove(task.id);
      await _save();
    }
  }

  void _update(
    String id, {
    int? downloadedBytes,
    FileDownloadStatus? status,
    String? error,
    DateTime? completedAt,
  }) {
    state = [
      for (final task in state)
        task.id == id
            ? task.copyWith(
                downloadedBytes: downloadedBytes,
                status: status,
                error: error,
                completedAt: completedAt,
              )
            : task,
    ];
  }

  FileDownloadTask _taskById(String id) {
    return state.firstWhere((task) => task.id == id);
  }

  FileDownloadTask? _taskByIdOrNull(String id) {
    for (final task in state) {
      if (task.id == id) return task;
    }
    return null;
  }

  Future<void> _deleteLocalFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }

  Future<int> _localLength(String path) async {
    final file = File(path);
    if (!await file.exists()) return 0;
    return file.length();
  }

  Future<String> _createLocalPath(String serverName, String fileName) async {
    final base = await _downloadRootDirectory();
    final directory = Directory(
      '${base.path}${Platform.pathSeparator}Orbite'
      '${Platform.pathSeparator}${_safeFileName(serverName)}',
    );
    await directory.create(recursive: true);
    final safeName = _safeFileName(fileName);
    var candidate = File('${directory.path}${Platform.pathSeparator}$safeName');
    var index = 1;
    while (await candidate.exists()) {
      candidate = File(
        '${directory.path}${Platform.pathSeparator}'
        '${_duplicateFileName(safeName, index)}',
      );
      index += 1;
    }
    return candidate.path;
  }

  Future<Directory> _downloadRootDirectory() async {
    if (Platform.isAndroid) {
      final publicDownloads = Directory('/storage/emulated/0/Download');
      if (await publicDownloads.exists()) return publicDownloads;
    }
    return await getDownloadsDirectory() ??
        await getApplicationDocumentsDirectory();
  }

  String _safeFileName(String name) {
    final safe = name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
    return safe.isEmpty ? 'download' : safe;
  }

  String _duplicateFileName(String name, int index) {
    return duplicateRemoteEntryName(name, index);
  }

  Future<void> _save() async {
    final prefs = ref.read(sharedPrefsProvider);
    await prefs.setString(_storageKey, encodeDownloadTasks(state));
  }
}

class _DownloadControl {
  var pause = false;
  var cancel = false;
  String? deleteLocalPath;
}
