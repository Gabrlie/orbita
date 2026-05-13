import 'dart:convert';

import 'package:orbita/models/file_download_task.dart';

enum FileTransferDirection { upload, download, server }

enum FileTransferSourceType { file, directory }

enum FileTransferPhase {
  queued,
  compressing,
  uploading,
  verifying,
  extracting,
  cleaning,
  downloading,
  paused,
  completed,
  failed,
  canceled,
}

class FileTransferTask {
  final String id;
  final String serverId;
  final String serverName;
  final String? sourceServerId;
  final String? sourceServerName;
  final String? sourceRemotePath;
  final FileTransferDirection direction;
  final FileTransferSourceType sourceType;
  final String name;
  final String remotePath;
  final String localPath;
  final String? remoteTempPath;
  final String? localTempPath;
  final int totalBytes;
  final int transferredBytes;
  final FileTransferPhase phase;
  final String? error;
  final DateTime createdAt;
  final DateTime? completedAt;

  const FileTransferTask({
    required this.id,
    required this.serverId,
    required this.serverName,
    required this.direction,
    required this.sourceType,
    required this.name,
    required this.remotePath,
    required this.localPath,
    required this.totalBytes,
    required this.transferredBytes,
    required this.phase,
    required this.createdAt,
    this.sourceServerId,
    this.sourceServerName,
    this.sourceRemotePath,
    this.remoteTempPath,
    this.localTempPath,
    this.error,
    this.completedAt,
  });

  double get progress {
    if (_isFixedProgressPhase) return _fixedPhaseProgress;
    if (totalBytes <= 0) return 0;
    return (transferredBytes / totalBytes).clamp(0, 1);
  }

  bool get isActive {
    return switch (phase) {
      FileTransferPhase.queued ||
      FileTransferPhase.compressing ||
      FileTransferPhase.uploading ||
      FileTransferPhase.verifying ||
      FileTransferPhase.extracting ||
      FileTransferPhase.cleaning ||
      FileTransferPhase.downloading => true,
      _ => false,
    };
  }

  bool get _isFixedProgressPhase {
    return sourceType == FileTransferSourceType.directory &&
        direction == FileTransferDirection.upload &&
        phase != FileTransferPhase.uploading;
  }

  double get _fixedPhaseProgress {
    return switch (phase) {
      FileTransferPhase.queued => 0,
      FileTransferPhase.compressing => 0.08,
      FileTransferPhase.verifying => 0.78,
      FileTransferPhase.extracting => 0.88,
      FileTransferPhase.cleaning => 0.96,
      FileTransferPhase.completed => 1,
      FileTransferPhase.failed || FileTransferPhase.canceled =>
        totalBytes <= 0 ? 0 : (transferredBytes / totalBytes).clamp(0, 1),
      _ => 0,
    };
  }

  FileTransferTask copyWith({
    String? remotePath,
    String? remoteTempPath,
    String? localTempPath,
    int? totalBytes,
    int? transferredBytes,
    FileTransferPhase? phase,
    String? error,
    DateTime? completedAt,
  }) {
    return FileTransferTask(
      id: id,
      serverId: serverId,
      serverName: serverName,
      sourceServerId: sourceServerId,
      sourceServerName: sourceServerName,
      sourceRemotePath: sourceRemotePath,
      direction: direction,
      sourceType: sourceType,
      name: name,
      remotePath: remotePath ?? this.remotePath,
      localPath: localPath,
      remoteTempPath: remoteTempPath ?? this.remoteTempPath,
      localTempPath: localTempPath ?? this.localTempPath,
      totalBytes: totalBytes ?? this.totalBytes,
      transferredBytes: transferredBytes ?? this.transferredBytes,
      phase: phase ?? this.phase,
      error: error,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'serverId': serverId,
    'serverName': serverName,
    'sourceServerId': sourceServerId,
    'sourceServerName': sourceServerName,
    'sourceRemotePath': sourceRemotePath,
    'direction': direction.name,
    'sourceType': sourceType.name,
    'name': name,
    'remotePath': remotePath,
    'localPath': localPath,
    'remoteTempPath': remoteTempPath,
    'localTempPath': localTempPath,
    'totalBytes': totalBytes,
    'transferredBytes': transferredBytes,
    'phase': phase.name,
    'error': error,
    'createdAt': createdAt.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
  };

  factory FileTransferTask.fromJson(Map<String, Object?> json) {
    return FileTransferTask(
      id: json['id'] as String,
      serverId: json['serverId'] as String,
      serverName: json['serverName'] as String,
      sourceServerId: json['sourceServerId'] as String?,
      sourceServerName: json['sourceServerName'] as String?,
      sourceRemotePath: json['sourceRemotePath'] as String?,
      direction: FileTransferDirection.values.firstWhere(
        (value) => value.name == json['direction'],
        orElse: () => FileTransferDirection.download,
      ),
      sourceType: FileTransferSourceType.values.firstWhere(
        (value) => value.name == json['sourceType'],
        orElse: () => FileTransferSourceType.file,
      ),
      name: json['name'] as String,
      remotePath: json['remotePath'] as String,
      localPath: json['localPath'] as String,
      remoteTempPath: json['remoteTempPath'] as String?,
      localTempPath: json['localTempPath'] as String?,
      totalBytes: json['totalBytes'] as int,
      transferredBytes: json['transferredBytes'] as int,
      phase: FileTransferPhase.values.firstWhere(
        (value) => value.name == json['phase'],
        orElse: () => FileTransferPhase.failed,
      ),
      error: json['error'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
    );
  }

  factory FileTransferTask.fromLegacyDownload(FileDownloadTask task) {
    return FileTransferTask(
      id: task.id,
      serverId: task.serverId,
      serverName: task.serverName,
      direction: FileTransferDirection.download,
      sourceType: FileTransferSourceType.file,
      name: task.fileName,
      remotePath: task.remotePath,
      localPath: task.localPath,
      totalBytes: task.totalBytes,
      transferredBytes: task.downloadedBytes,
      phase: _phaseFromLegacyStatus(task.status),
      error: task.error,
      createdAt: task.createdAt,
      completedAt: task.completedAt,
    );
  }
}

FileTransferPhase _phaseFromLegacyStatus(FileDownloadStatus status) {
  return switch (status) {
    FileDownloadStatus.queued => FileTransferPhase.queued,
    FileDownloadStatus.downloading => FileTransferPhase.downloading,
    FileDownloadStatus.paused => FileTransferPhase.paused,
    FileDownloadStatus.completed => FileTransferPhase.completed,
    FileDownloadStatus.failed => FileTransferPhase.failed,
    FileDownloadStatus.canceled => FileTransferPhase.canceled,
  };
}

List<FileTransferTask> decodeTransferTasks(String? value) {
  if (value == null || value.isEmpty) return [];
  final items = jsonDecode(value) as List<dynamic>;
  return items
      .map(
        (item) =>
            FileTransferTask.fromJson(Map<String, Object?>.from(item as Map)),
      )
      .toList();
}

String encodeTransferTasks(List<FileTransferTask> tasks) {
  return jsonEncode(tasks.map((task) => task.toJson()).toList());
}
