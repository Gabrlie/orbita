class BackupSettings {
  final bool localEnabled;
  final String localFolder;
  final bool webdavEnabled;
  final String webdavUrl;
  final String webdavUsername;
  final String webdavRemoteFolder;
  final bool autoBackupEnabled;
  final int retentionCount;
  final DateTime? lastBackupAt;
  final String? lastError;

  const BackupSettings({
    this.localEnabled = false,
    this.localFolder = '',
    this.webdavEnabled = false,
    this.webdavUrl = '',
    this.webdavUsername = '',
    this.webdavRemoteFolder = '/orbita',
    this.autoBackupEnabled = false,
    this.retentionCount = 3,
    this.lastBackupAt,
    this.lastError,
  });

  BackupSettings copyWith({
    bool? localEnabled,
    String? localFolder,
    bool? webdavEnabled,
    String? webdavUrl,
    String? webdavUsername,
    String? webdavRemoteFolder,
    bool? autoBackupEnabled,
    int? retentionCount,
    DateTime? Function()? lastBackupAt,
    String? Function()? lastError,
  }) {
    return BackupSettings(
      localEnabled: localEnabled ?? this.localEnabled,
      localFolder: localFolder ?? this.localFolder,
      webdavEnabled: webdavEnabled ?? this.webdavEnabled,
      webdavUrl: webdavUrl ?? this.webdavUrl,
      webdavUsername: webdavUsername ?? this.webdavUsername,
      webdavRemoteFolder: webdavRemoteFolder ?? this.webdavRemoteFolder,
      autoBackupEnabled: autoBackupEnabled ?? this.autoBackupEnabled,
      retentionCount: retentionCount ?? this.retentionCount,
      lastBackupAt: lastBackupAt != null ? lastBackupAt() : this.lastBackupAt,
      lastError: lastError != null ? lastError() : this.lastError,
    );
  }
}

enum BackupLocation { local, webdav }

class BackupEntry {
  final BackupLocation location;
  final String name;
  final String path;
  final DateTime modifiedAt;

  const BackupEntry({
    required this.location,
    required this.name,
    required this.path,
    required this.modifiedAt,
  });
}

class BackupAutoSecret {
  final String salt;
  final String wrapNonce;
  final String wrappedKey;
  final String dataKey;

  const BackupAutoSecret({
    required this.salt,
    required this.wrapNonce,
    required this.wrappedKey,
    required this.dataKey,
  });

  Map<String, Object?> toJson() => {
    'salt': salt,
    'wrapNonce': wrapNonce,
    'wrappedKey': wrappedKey,
    'dataKey': dataKey,
  };

  factory BackupAutoSecret.fromJson(Map<String, Object?> json) {
    return BackupAutoSecret(
      salt: json['salt'] as String? ?? '',
      wrapNonce: json['wrapNonce'] as String? ?? '',
      wrappedKey: json['wrappedKey'] as String? ?? '',
      dataKey: json['dataKey'] as String? ?? '',
    );
  }
}

class BackupException implements Exception {
  static const passwordRequired = 'password required';
  static const invalidPassword = 'invalid password';
  static const invalidSnapshot = 'invalid backup snapshot';
  static const noTarget = 'no backup target';

  final String message;

  const BackupException(this.message);

  @override
  String toString() => message;
}
