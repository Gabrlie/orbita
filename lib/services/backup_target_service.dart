import 'package:orbita/models/backup_models.dart';
import 'package:orbita/services/backup_file_service.dart';
import 'package:orbita/services/webdav_backup_service.dart';

class BackupTargetService {
  final BackupFileService fileService;
  final WebDavBackupService webDavService;

  const BackupTargetService({
    required this.fileService,
    required this.webDavService,
  });

  Future<List<BackupEntry>> listLocal(BackupSettings settings) {
    return fileService.list(settings.localFolder);
  }

  Future<List<BackupEntry>> listWebDav(
    BackupSettings settings,
    String password,
  ) {
    return webDavService.listBackups(
      baseUrl: settings.webdavUrl,
      remoteFolder: settings.webdavRemoteFolder,
      username: settings.webdavUsername,
      password: password,
    );
  }

  Future<String> read(
    BackupEntry entry,
    BackupSettings settings,
    String webDavPassword,
  ) {
    return switch (entry.location) {
      BackupLocation.local => fileService.read(entry),
      BackupLocation.webdav => webDavService.download(
        baseUrl: settings.webdavUrl,
        remotePath: entry.path,
        username: settings.webdavUsername,
        password: webDavPassword,
      ),
    };
  }

  Future<void> write(
    BackupSettings settings,
    String envelope,
    String fileName,
    String webDavPassword,
  ) async {
    if (settings.localEnabled && settings.localFolder.isNotEmpty) {
      await fileService.write(
        folder: settings.localFolder,
        fileName: fileName,
        content: envelope,
      );
      await fileService.prune(settings.localFolder, settings.retentionCount);
    }
    if (settings.webdavEnabled && settings.webdavUrl.isNotEmpty) {
      await webDavService.uploadBackup(
        baseUrl: settings.webdavUrl,
        remoteFolder: settings.webdavRemoteFolder,
        fileName: fileName,
        username: settings.webdavUsername,
        password: webDavPassword,
        content: envelope,
      );
      await webDavService.pruneBackups(
        baseUrl: settings.webdavUrl,
        remoteFolder: settings.webdavRemoteFolder,
        username: settings.webdavUsername,
        password: webDavPassword,
        retentionCount: settings.retentionCount,
      );
    }
  }
}
