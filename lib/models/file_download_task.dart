import 'dart:convert';

enum FileDownloadStatus {
  queued,
  downloading,
  paused,
  completed,
  failed,
  canceled,
}

class FileDownloadTask {
  final String id;
  final String serverId;
  final String serverName;
  final String remotePath;
  final String fileName;
  final String localPath;
  final int totalBytes;
  final int downloadedBytes;
  final FileDownloadStatus status;
  final String? error;
  final DateTime createdAt;
  final DateTime? completedAt;

  const FileDownloadTask({
    required this.id,
    required this.serverId,
    required this.serverName,
    required this.remotePath,
    required this.fileName,
    required this.localPath,
    required this.totalBytes,
    required this.downloadedBytes,
    required this.status,
    required this.createdAt,
    this.error,
    this.completedAt,
  });

  double get progress {
    if (totalBytes <= 0) return 0;
    return downloadedBytes / totalBytes;
  }

  bool get isActive {
    return status == FileDownloadStatus.queued ||
        status == FileDownloadStatus.downloading;
  }

  FileDownloadTask copyWith({
    int? downloadedBytes,
    FileDownloadStatus? status,
    String? error,
    DateTime? completedAt,
  }) {
    return FileDownloadTask(
      id: id,
      serverId: serverId,
      serverName: serverName,
      remotePath: remotePath,
      fileName: fileName,
      localPath: localPath,
      totalBytes: totalBytes,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      status: status ?? this.status,
      error: error,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'serverId': serverId,
    'serverName': serverName,
    'remotePath': remotePath,
    'fileName': fileName,
    'localPath': localPath,
    'totalBytes': totalBytes,
    'downloadedBytes': downloadedBytes,
    'status': status.name,
    'error': error,
    'createdAt': createdAt.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
  };

  factory FileDownloadTask.fromJson(Map<String, Object?> json) {
    return FileDownloadTask(
      id: json['id'] as String,
      serverId: json['serverId'] as String,
      serverName: json['serverName'] as String,
      remotePath: json['remotePath'] as String,
      fileName: json['fileName'] as String,
      localPath: json['localPath'] as String,
      totalBytes: json['totalBytes'] as int,
      downloadedBytes: json['downloadedBytes'] as int,
      status: FileDownloadStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => FileDownloadStatus.failed,
      ),
      error: json['error'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
    );
  }
}

List<FileDownloadTask> decodeDownloadTasks(String? value) {
  if (value == null || value.isEmpty) return [];
  final items = jsonDecode(value) as List<dynamic>;
  return items
      .map(
        (item) =>
            FileDownloadTask.fromJson(Map<String, Object?>.from(item as Map)),
      )
      .toList();
}

String encodeDownloadTasks(List<FileDownloadTask> tasks) {
  return jsonEncode(tasks.map((task) => task.toJson()).toList());
}
