enum UpdateDownloadStatus {
  idle,
  checking,
  verifying,
  downloading,
  installing,
  completed,
  error,
}

class ReleaseAsset {
  final String name;
  final String architecture;
  final String downloadUrl;
  final String? sha256Url;
  final int size;

  const ReleaseAsset({
    required this.name,
    required this.architecture,
    required this.downloadUrl,
    this.sha256Url,
    this.size = 0,
  });

  Map<String, Object?> toJson() => {
    'name': name,
    'architecture': architecture,
    'downloadUrl': downloadUrl,
    'sha256Url': sha256Url,
    'size': size,
  };

  factory ReleaseAsset.fromJson(Map<String, Object?> json) {
    return ReleaseAsset(
      name: json['name'] as String? ?? '',
      architecture: json['architecture'] as String? ?? '',
      downloadUrl: json['downloadUrl'] as String? ?? '',
      sha256Url: json['sha256Url'] as String?,
      size: json['size'] as int? ?? 0,
    );
  }
}

class UpdateInfo {
  final String currentVersion;
  final String currentBuild;
  final String remoteVersion;
  final String tagName;
  final String releaseUrl;
  final String releaseNotes;
  final bool hasUpdate;
  final bool isSkipped;
  final ReleaseAsset? matchedAsset;
  final List<ReleaseAsset> assets;

  const UpdateInfo({
    required this.currentVersion,
    required this.currentBuild,
    required this.remoteVersion,
    required this.tagName,
    required this.releaseUrl,
    required this.releaseNotes,
    required this.hasUpdate,
    this.isSkipped = false,
    this.matchedAsset,
    this.assets = const [],
  });

  Map<String, Object?> toJson() => {
    'currentVersion': currentVersion,
    'currentBuild': currentBuild,
    'remoteVersion': remoteVersion,
    'tagName': tagName,
    'releaseUrl': releaseUrl,
    'releaseNotes': releaseNotes,
    'hasUpdate': hasUpdate,
    'isSkipped': isSkipped,
    'matchedAsset': matchedAsset?.toJson(),
    'assets': assets.map((asset) => asset.toJson()).toList(),
  };

  factory UpdateInfo.fromJson(Map<String, Object?> json) {
    return UpdateInfo(
      currentVersion: json['currentVersion'] as String? ?? '',
      currentBuild: json['currentBuild'] as String? ?? '',
      remoteVersion: json['remoteVersion'] as String? ?? '',
      tagName: json['tagName'] as String? ?? '',
      releaseUrl: json['releaseUrl'] as String? ?? '',
      releaseNotes: json['releaseNotes'] as String? ?? '',
      hasUpdate: json['hasUpdate'] as bool? ?? false,
      isSkipped: json['isSkipped'] as bool? ?? false,
      matchedAsset: json['matchedAsset'] is Map
          ? ReleaseAsset.fromJson(
              Map<String, Object?>.from(json['matchedAsset'] as Map),
            )
          : null,
      assets: (json['assets'] as List? ?? const [])
          .whereType<Map>()
          .map(
            (asset) => ReleaseAsset.fromJson(Map<String, Object?>.from(asset)),
          )
          .toList(),
    );
  }
}

class UpdateDownloadProgress {
  final UpdateDownloadStatus status;
  final int progress;
  final String? error;
  final String? filePath;

  const UpdateDownloadProgress({
    required this.status,
    this.progress = 0,
    this.error,
    this.filePath,
  });
}

class UpdateState {
  final bool checking;
  final bool autoCheckEnabled;
  final UpdateInfo? info;
  final UpdateDownloadProgress download;
  final String? error;

  const UpdateState({
    this.checking = false,
    this.autoCheckEnabled = true,
    this.info,
    this.download = const UpdateDownloadProgress(
      status: UpdateDownloadStatus.idle,
    ),
    this.error,
  });

  UpdateState copyWith({
    bool? checking,
    bool? autoCheckEnabled,
    UpdateInfo? Function()? info,
    UpdateDownloadProgress? download,
    String? Function()? error,
  }) {
    return UpdateState(
      checking: checking ?? this.checking,
      autoCheckEnabled: autoCheckEnabled ?? this.autoCheckEnabled,
      info: info != null ? info() : this.info,
      download: download ?? this.download,
      error: error != null ? error() : this.error,
    );
  }
}
