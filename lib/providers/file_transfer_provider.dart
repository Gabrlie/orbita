import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart' as crypto_hash;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbita/models/file_download_task.dart';
import 'package:orbita/models/file_transfer_task.dart';
import 'package:orbita/models/remote_file_entry.dart';
import 'package:orbita/models/server.dart';
import 'package:orbita/models/ssh_key.dart';
import 'package:orbita/providers/settings_provider.dart';
import 'package:orbita/providers/sftp_file_provider.dart';
import 'package:orbita/services/local_directory_archive_service.dart';
import 'package:orbita/services/sftp_file_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

part 'file_transfer_provider_helpers.dart';
part 'file_transfer_provider_operations.dart';
part 'file_transfer_provider_server_operations.dart';

final fileTransferProvider =
    NotifierProvider<FileTransferController, List<FileTransferTask>>(
      FileTransferController.new,
    );

class FileTransferController extends Notifier<List<FileTransferTask>> {
  static const _storageKey = 'file_transfer_tasks';
  static const _legacyDownloadKey = 'file_download_tasks';
  final _controls = <String, _TransferControl>{};

  SftpFileService get _sftpService => ref.read(sftpFileServiceProvider);

  @override
  List<FileTransferTask> build() {
    final prefs = ref.read(sharedPrefsProvider);
    final stored = prefs.getString(_storageKey);
    if (stored != null && stored.isNotEmpty) {
      return decodeTransferTasks(
        stored,
      ).where((task) => task.phase != FileTransferPhase.canceled).toList();
    }
    final legacy = decodeDownloadTasks(prefs.getString(_legacyDownloadKey))
        .map(FileTransferTask.fromLegacyDownload)
        .where((task) => task.phase != FileTransferPhase.canceled)
        .toList();
    if (legacy.isNotEmpty) {
      unawaited(prefs.setString(_storageKey, encodeTransferTasks(legacy)));
    }
    return legacy;
  }

  Future<bool> addDownload(
    Server server,
    SshKey? key,
    RemoteFileEntry entry, {
    String? localPath,
  }) async {
    final settings = ref.read(transferSettingsProvider);
    final targetPath =
        localPath ?? await _createLocalPath(server.name, entry.name, settings);
    if (targetPath == null) return false;
    final task = FileTransferTask(
      id: const Uuid().v4(),
      serverId: server.id,
      serverName: server.name,
      direction: FileTransferDirection.download,
      sourceType: FileTransferSourceType.file,
      name: entry.name,
      remotePath: entry.path,
      localPath: targetPath,
      totalBytes: entry.size,
      transferredBytes: 0,
      phase: FileTransferPhase.queued,
      createdAt: DateTime.now(),
    );
    await _addAndRun(task, server, key);
    return true;
  }

  Future<void> addFileUpload(
    Server server,
    SshKey? key, {
    required String localPath,
    required String remotePath,
    required bool overwrite,
  }) async {
    final file = File(localPath);
    final id = const Uuid().v4();
    final tempPath = '$remotePath.orbita-upload-$id.part';
    final task = FileTransferTask(
      id: id,
      serverId: server.id,
      serverName: server.name,
      direction: FileTransferDirection.upload,
      sourceType: FileTransferSourceType.file,
      name: remotePath.split('/').last,
      remotePath: remotePath,
      localPath: localPath,
      remoteTempPath: tempPath,
      totalBytes: await file.length(),
      transferredBytes: 0,
      phase: FileTransferPhase.queued,
      createdAt: DateTime.now(),
    );
    await _addAndRun(task, server, key, overwrite: overwrite);
  }

  Future<void> addDirectoryUpload(
    Server server,
    SshKey? key, {
    required String directoryPath,
    required String remoteDirectory,
    required String rootName,
    required bool overwrite,
  }) async {
    final id = const Uuid().v4();
    final archive = joinRemotePath(
      remoteDirectory,
      '.orbita-upload-$id.tar.gz',
    );
    final task = FileTransferTask(
      id: id,
      serverId: server.id,
      serverName: server.name,
      direction: FileTransferDirection.upload,
      sourceType: FileTransferSourceType.directory,
      name: rootName,
      remotePath: joinRemotePath(remoteDirectory, rootName),
      localPath: directoryPath,
      remoteTempPath: '$archive.part',
      totalBytes: 0,
      transferredBytes: 0,
      phase: FileTransferPhase.queued,
      createdAt: DateTime.now(),
    );
    await _addAndRun(task, server, key, overwrite: overwrite);
  }

  Future<void> resume(
    FileTransferTask task,
    Server server,
    SshKey? key, {
    bool overwrite = false,
  }) async {
    if (task.phase == FileTransferPhase.completed) return;
    _update(task.id, phase: FileTransferPhase.queued, error: null);
    await _save();
    unawaited(_run(_taskById(task.id), server, key, overwrite: overwrite));
  }

  Future<void> pause(String id) async {
    _controls[id]?.pause = true;
    _update(id, phase: FileTransferPhase.paused, error: null);
    await _save();
  }

  Future<void> cancel(String id) async {
    final task = _taskByIdOrNull(id);
    if (task == null) return;
    _controls[id]?.cancel = true;
    _update(id, phase: FileTransferPhase.canceled, error: null);
    await _cleanupTask(task);
    await _save();
  }

  Future<void> deleteTask(String id) async {
    final task = _taskByIdOrNull(id);
    if (task == null) return;
    await _cleanupTask(task, deleteDownload: true);
    state = state.where((task) => task.id != id).toList();
    await _save();
  }

  Future<void> _addAndRun(
    FileTransferTask task,
    Server server,
    SshKey? key, {
    bool overwrite = false,
  }) async {
    await _addTask(task);
    unawaited(_run(task, server, key, overwrite: overwrite));
  }

  Future<void> _addTask(FileTransferTask task) async {
    state = [task, ...state];
    await _save();
  }

  Future<void> _run(
    FileTransferTask task,
    Server server,
    SshKey? key, {
    bool overwrite = false,
  }) async {
    if (_controls.containsKey(task.id)) return;
    final control = _TransferControl();
    _controls[task.id] = control;
    try {
      switch (task.direction) {
        case FileTransferDirection.download:
          await _runDownload(task, server, key, control);
        case FileTransferDirection.upload:
          task.sourceType == FileTransferSourceType.directory
              ? await _runDirectoryUpload(task, server, key, control, overwrite)
              : await _runFileUpload(task, server, key, control, overwrite);
        case FileTransferDirection.server:
          throw StateError('Server transfers cannot resume from one endpoint');
      }
    } catch (error) {
      final phase = control.cancel
          ? FileTransferPhase.canceled
          : control.pause
          ? FileTransferPhase.paused
          : FileTransferPhase.failed;
      if (phase == FileTransferPhase.failed) {
        _logTransferFailure(task, error);
      }
      _update(
        task.id,
        phase: phase,
        error: control.pause ? null : _errorMessage(error),
      );
      if (control.cancel) {
        final latest = _taskByIdOrNull(task.id) ?? task;
        await _cleanupUploadTaskRemote(latest, server, key);
        await _cleanupTask(latest);
      }
    } finally {
      _controls.remove(task.id);
      await _save();
    }
  }

  void _complete(String id, int bytes) {
    _update(
      id,
      phase: FileTransferPhase.completed,
      transferredBytes: bytes,
      completedAt: DateTime.now(),
      error: null,
    );
  }

  void _update(
    String id, {
    String? remotePath,
    String? remoteTempPath,
    String? localTempPath,
    int? totalBytes,
    int? transferredBytes,
    FileTransferPhase? phase,
    String? error,
    DateTime? completedAt,
  }) {
    state = [
      for (final task in state)
        task.id == id
            ? task.copyWith(
                remotePath: remotePath,
                remoteTempPath: remoteTempPath,
                localTempPath: localTempPath,
                totalBytes: totalBytes,
                transferredBytes: transferredBytes,
                phase: phase,
                error: error,
                completedAt: completedAt,
              )
            : task,
    ];
  }

  FileTransferTask _taskById(String id) {
    return state.firstWhere((task) => task.id == id);
  }

  FileTransferTask? _taskByIdOrNull(String id) {
    for (final task in state) {
      if (task.id == id) return task;
    }
    return null;
  }

  Future<void> _save() async {
    final prefs = ref.read(sharedPrefsProvider);
    await prefs.setString(_storageKey, encodeTransferTasks(state));
  }

  String _errorMessage(Object error) {
    if (error is SftpFileException) {
      final details = error.details?.trim();
      if (details != null && details.isNotEmpty) {
        return details.length > 1200
            ? '${details.substring(0, 1200)}...'
            : details;
      }
    }
    return '$error';
  }

  void _logTransferFailure(FileTransferTask task, Object error) {
    final source = task.direction == FileTransferDirection.download
        ? task.remotePath
        : task.sourceRemotePath ?? task.localPath;
    debugPrint(
      'Orbita transfer failed: id=${task.id} '
      'direction=${task.direction.name} source=$source '
      'target=${task.remotePath} error=${_errorMessage(error)}',
    );
  }
}

class _TransferControl {
  var pause = false;
  var cancel = false;
}
