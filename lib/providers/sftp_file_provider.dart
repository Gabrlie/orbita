import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbita/providers/ssh_connection_provider.dart';
import 'package:orbita/services/sftp_file_service.dart';

final sftpFileServiceProvider = Provider<SftpFileService>((ref) {
  return SftpFileService(ref.watch(sshConnectionManagerProvider));
});
