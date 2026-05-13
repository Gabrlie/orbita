import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dartssh2/dartssh2.dart';
import 'package:orbita/models/remote_file_entry.dart';
import 'package:orbita/models/server.dart';
import 'package:orbita/models/ssh_key.dart';
import 'package:orbita/services/ssh_connection_manager.dart';
import 'package:orbita/services/ssh_service.dart';
import 'package:orbita/services/remote_file_command_builder.dart';

part 'sftp_file_service_operations.dart';
part 'sftp_file_service_transfer_operations.dart';
part 'sftp_file_service_rsync_operations.dart';
part 'sftp_file_service_archive_operations.dart';
part 'sftp_file_service_sftp_helpers.dart';

class SftpFileService {
  final SshConnectionManager _connectionManager;

  const SftpFileService(this._connectionManager);

  Future<List<RemoteFileEntry>> listDirectory(
    Server server, {
    SshKey? key,
    String path = '/',
  }) async {
    return _withSftp(server, key: key, (sftp, _) async {
      return _listDirectoryWithClient(sftp, path);
    });
  }

  Future<String> readTextFile(
    Server server, {
    required String path,
    SshKey? key,
  }) async {
    return _withSftp(server, key: key, (sftp, _) async {
      final normalizedPath = normalizeRemotePath(path);
      final attrs = await sftp.stat(normalizedPath);
      final size = attrs.size ?? 0;
      if (size > maxEditableFileBytes) {
        throw SftpFileException.tooLarge();
      }

      final file = await sftp.open(normalizedPath);
      try {
        final bytes = await file.readBytes();
        if (_looksBinary(bytes)) {
          throw SftpFileException.binary();
        }
        return utf8.decode(bytes, allowMalformed: true);
      } finally {
        await file.close();
      }
    });
  }

  Future<void> writeTextFile(
    Server server, {
    required String path,
    required String content,
    SshKey? key,
  }) async {
    await _withSftp(server, key: key, (sftp, _) async {
      final file = await sftp.open(
        normalizeRemotePath(path),
        mode:
            SftpFileOpenMode.write |
            SftpFileOpenMode.create |
            SftpFileOpenMode.truncate,
      );
      try {
        await file.writeBytes(Uint8List.fromList(utf8.encode(content)));
      } finally {
        await file.close();
      }
    });
  }

  Future<void> createFile(
    Server server, {
    required String parentPath,
    required String name,
    SshKey? key,
  }) async {
    await _withSftp(server, key: key, (sftp, _) async {
      final file = await sftp.open(
        joinRemotePath(parentPath, name),
        mode:
            SftpFileOpenMode.write |
            SftpFileOpenMode.create |
            SftpFileOpenMode.exclusive,
      );
      await file.close();
    });
  }

  Future<void> createDirectory(
    Server server, {
    required String parentPath,
    required String name,
    SshKey? key,
  }) async {
    await _withSftp(server, key: key, (sftp, _) async {
      await sftp.mkdir(joinRemotePath(parentPath, name));
    });
  }

  Future<void> rename(
    Server server, {
    required String path,
    required String nextName,
    SshKey? key,
  }) async {
    await _withSftp(server, key: key, (sftp, _) async {
      final normalizedPath = normalizeRemotePath(path);
      await sftp.rename(
        normalizedPath,
        joinRemotePath(parentRemotePath(normalizedPath), nextName),
      );
    });
  }

  Future<void> delete(
    Server server, {
    required RemoteFileEntry entry,
    SshKey? key,
  }) async {
    if (entry.isParentLink || normalizeRemotePath(entry.path) == '/') {
      throw SftpFileException.invalidTarget();
    }

    await _withSftp(server, key: key, (sftp, _) async {
      await _removeSftpEntry(sftp, entry.path);
    });
  }

  Future<T> _withSftp<T>(
    Server server,
    Future<T> Function(SftpClient sftp, SshClientSession ssh) action, {
    SshKey? key,
  }) async {
    Object? openError;
    for (var attempt = 0; attempt < 2; attempt++) {
      final lease = await _connectionManager.acquire(server, key: key);
      SftpClient? sftp;
      try {
        sftp = await lease.service.openSftp();
        return await action(sftp, lease.service);
      } catch (error) {
        if (sftp == null) {
          _connectionManager.markUnhealthy(server.id, lease.service);
          openError = error;
          if (attempt == 0) continue;
        } else if (_shouldDropConnection(error)) {
          _connectionManager.markUnhealthy(server.id, lease.service);
        }
        rethrow;
      } finally {
        sftp?.close();
        lease.release();
      }
    }
    throw openError ?? StateError('SFTP channel open failed');
  }

  Future<T> _withSsh<T>(
    Server server,
    Future<T> Function(SshClientSession ssh) action, {
    SshKey? key,
  }) async {
    final lease = await _connectionManager.acquire(server, key: key);
    try {
      return await action(lease.service);
    } catch (error) {
      if (_shouldDropConnection(error)) {
        _connectionManager.markUnhealthy(server.id, lease.service);
      }
      rethrow;
    } finally {
      lease.release();
    }
  }

  Future<void> _executeChecked(
    SshClientSession ssh,
    String command, {
    String stage = 'Remote command',
  }) async {
    final output = await ssh.executeStreaming(
      'set -e\n$command\nprintf "\\n__ORBITA_CMD_OK__"',
      onOutput: (_) {},
    );
    if (!output.contains('__ORBITA_CMD_OK__')) {
      throw _commandFailed(stage, output);
    }
  }

  SftpFileException _commandFailed(String stage, String output) {
    final details = output.trim();
    return SftpFileException.commandFailed(
      details.isEmpty
          ? '$stage failed without output'
          : '$stage failed:\n$details',
    );
  }

  Future<List<RemoteFileEntry>> _listDirectoryWithClient(
    SftpClient sftp,
    String path,
  ) async {
    final normalizedPath = normalizeRemotePath(path);
    final names = await sftp.listdir(normalizedPath);
    final entries = names
        .where((name) => name.filename != '.' && name.filename != '..')
        .map((name) => _entryFromSftpName(normalizedPath, name))
        .toList();
    entries.sort(_compareEntries);
    return entries;
  }

  RemoteFileEntry _entryFromSftpName(String parentPath, SftpName name) {
    final attrs = name.attr;
    final mode = attrs.mode;
    return RemoteFileEntry(
      name: name.filename,
      path: joinRemotePath(parentPath, name.filename),
      size: attrs.size ?? 0,
      modifiedAt: attrs.modifyTime == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(attrs.modifyTime! * 1000),
      mode: mode?.value,
      isDirectory: attrs.isDirectory,
      isSymlink: attrs.isSymbolicLink,
    );
  }

  int _compareEntries(RemoteFileEntry left, RemoteFileEntry right) {
    if (left.isDirectory != right.isDirectory) {
      return left.isDirectory ? -1 : 1;
    }
    return left.name.toLowerCase().compareTo(right.name.toLowerCase());
  }

  bool _looksBinary(Uint8List bytes) {
    final sampleLength = bytes.length > 4096 ? 4096 : bytes.length;
    for (var i = 0; i < sampleLength; i++) {
      if (bytes[i] == 0) return true;
    }
    return false;
  }

  bool _shouldDropConnection(Object error) {
    return error is SSHStateError ||
        error is SSHChannelOpenError ||
        error is SftpAbortError ||
        error is SocketException ||
        error is StateError;
  }
}

class SftpFileException implements Exception {
  final String code;
  final String? details;

  const SftpFileException(this.code, [this.details]);

  factory SftpFileException.tooLarge() => const SftpFileException('tooLarge');
  factory SftpFileException.binary() => const SftpFileException('binary');
  factory SftpFileException.invalidTarget() =>
      const SftpFileException('invalidTarget');
  factory SftpFileException.deleteFailed() =>
      const SftpFileException('deleteFailed');
  factory SftpFileException.commandFailed(String details) =>
      SftpFileException('commandFailed', details);
  factory SftpFileException.downloadStopped() =>
      const SftpFileException('downloadStopped');
  factory SftpFileException.transferStopped() =>
      const SftpFileException('transferStopped');
  factory SftpFileException.targetExists() =>
      const SftpFileException('targetExists');

  @override
  String toString() => 'SftpFileException($code)';
}
