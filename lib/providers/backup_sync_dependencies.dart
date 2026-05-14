import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:orbita/services/backup_encryption_service.dart';
import 'package:orbita/services/backup_file_service.dart';
import 'package:orbita/services/backup_restore_service.dart';
import 'package:orbita/services/backup_target_service.dart';
import 'package:orbita/services/device_name_service.dart';
import 'package:orbita/services/webdav_backup_service.dart';

const backupSecureWebDavPasswordKey = 'backup_webdav_password';

final backupEncryptionServiceProvider = Provider<BackupEncryptionService>(
  (ref) => const BackupEncryptionService(),
);

final backupFileServiceProvider = Provider<BackupFileService>(
  (ref) => const BackupFileService(),
);

final backupRestoreServiceProvider = Provider<BackupRestoreService>((ref) {
  return BackupRestoreService(
    encryption: ref.read(backupEncryptionServiceProvider),
  );
});

final webDavBackupServiceProvider = Provider<WebDavBackupService>(
  (ref) => WebDavBackupService(),
);

final deviceNameServiceProvider = Provider<DeviceNameService>(
  (ref) => DeviceNameService(),
);

final backupTargetServiceProvider = Provider<BackupTargetService>((ref) {
  return BackupTargetService(
    fileService: ref.read(backupFileServiceProvider),
    webDavService: ref.read(webDavBackupServiceProvider),
  );
});

final secureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(),
);
