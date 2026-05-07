class BackupSettings {
  final bool localEnabled;
  final String localFolder;
  final bool webdavEnabled;
  final String webdavUrl;
  final String webdavUsername;
  final String webdavRemotePath;
  final bool autoBackupEnabled;
  final DateTime? lastBackupAt;
  final String? lastError;

  const BackupSettings({
    this.localEnabled = false,
    this.localFolder = '',
    this.webdavEnabled = false,
    this.webdavUrl = '',
    this.webdavUsername = '',
    this.webdavRemotePath = '/orbita-backup.json',
    this.autoBackupEnabled = false,
    this.lastBackupAt,
    this.lastError,
  });

  BackupSettings copyWith({
    bool? localEnabled,
    String? localFolder,
    bool? webdavEnabled,
    String? webdavUrl,
    String? webdavUsername,
    String? webdavRemotePath,
    bool? autoBackupEnabled,
    DateTime? Function()? lastBackupAt,
    String? Function()? lastError,
  }) {
    return BackupSettings(
      localEnabled: localEnabled ?? this.localEnabled,
      localFolder: localFolder ?? this.localFolder,
      webdavEnabled: webdavEnabled ?? this.webdavEnabled,
      webdavUrl: webdavUrl ?? this.webdavUrl,
      webdavUsername: webdavUsername ?? this.webdavUsername,
      webdavRemotePath: webdavRemotePath ?? this.webdavRemotePath,
      autoBackupEnabled: autoBackupEnabled ?? this.autoBackupEnabled,
      lastBackupAt: lastBackupAt != null ? lastBackupAt() : this.lastBackupAt,
      lastError: lastError != null ? lastError() : this.lastError,
    );
  }
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
