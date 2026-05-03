part of 'sftp_file_service.dart';

bool _isInvalidCopyTarget(String source, String target, bool isDirectory) {
  final normalizedSource = normalizeRemotePath(source);
  final normalizedTarget = normalizeRemotePath(target);
  return isDirectory && normalizedTarget.startsWith('$normalizedSource/');
}

Future<void> _copySftpEntry(
  SftpClient sftp, {
  required RemoteFileEntry entry,
  required String source,
  required String target,
  required bool overwrite,
}) async {
  if (overwrite) {
    await _removeSftpEntry(sftp, target);
  } else if (await _sftpEntryExists(sftp, target)) {
    throw SftpFileException.targetExists();
  }

  if (entry.isDirectory) {
    await _copyDirectorySftp(sftp, source, target);
  } else {
    await _copyFileSftp(sftp, source, target, overwrite: overwrite);
  }
}

Future<bool> _sftpEntryExists(SftpClient sftp, String path) async {
  try {
    await sftp.stat(normalizeRemotePath(path));
    return true;
  } on SftpStatusError catch (error) {
    if (error.code == SftpStatusCode.noSuchFile) return false;
    rethrow;
  }
}

Future<String> _resolveAvailableTarget(
  SftpClient sftp,
  String targetDirectory,
  String originalName,
) async {
  final directory = normalizeRemotePath(targetDirectory);
  var index = 1;
  while (true) {
    final candidate = joinRemotePath(
      directory,
      duplicateRemoteEntryName(originalName, index),
    );
    if (!await _sftpEntryExists(sftp, candidate)) return candidate;
    index += 1;
  }
}

Future<void> _copyDirectorySftp(
  SftpClient sftp,
  String source,
  String target,
) async {
  final sourceAttrs = await sftp.stat(source);
  await sftp.mkdir(
    target,
    SftpFileAttrs(
      mode: sourceAttrs.mode,
      accessTime: sourceAttrs.accessTime,
      modifyTime: sourceAttrs.modifyTime,
    ),
  );

  final children = await sftp.listdir(source);
  for (final child in children) {
    if (child.filename == '.' || child.filename == '..') continue;
    final childSource = joinRemotePath(source, child.filename);
    final childTarget = joinRemotePath(target, child.filename);
    if (child.attr.isDirectory) {
      await _copyDirectorySftp(sftp, childSource, childTarget);
    } else {
      await _copyFileSftp(
        sftp,
        childSource,
        childTarget,
        overwrite: false,
        attrs: child.attr,
      );
    }
  }
}

Future<void> _copyFileSftp(
  SftpClient sftp,
  String source,
  String target, {
  required bool overwrite,
  SftpFileAttrs? attrs,
}) async {
  final sourceAttrs = attrs ?? await sftp.stat(source);
  var mode =
      SftpFileOpenMode.write |
      SftpFileOpenMode.create |
      SftpFileOpenMode.truncate;
  if (!overwrite) {
    mode = mode | SftpFileOpenMode.exclusive;
  }
  SftpFile? input;
  SftpFile? output;
  try {
    input = await sftp.open(source, mode: SftpFileOpenMode.read);
    output = await sftp.open(target, mode: mode);
    var offset = 0;
    await for (final chunk in input.read()) {
      await output.writeBytes(chunk, offset: offset);
      offset += chunk.length;
    }
  } finally {
    await output?.close();
    await input?.close();
  }

  await sftp.setStat(
    target,
    SftpFileAttrs(
      mode: sourceAttrs.mode,
      accessTime: sourceAttrs.accessTime,
      modifyTime: sourceAttrs.modifyTime,
    ),
  );
}

Future<void> _removeSftpEntry(SftpClient sftp, String path) async {
  final normalizedPath = normalizeRemotePath(path);
  final attrs = await sftp.stat(normalizedPath);
  if (!attrs.isDirectory) {
    await sftp.remove(normalizedPath);
    return;
  }

  final children = await sftp.listdir(normalizedPath);
  for (final child in children) {
    if (child.filename == '.' || child.filename == '..') continue;
    await _removeSftpEntry(
      sftp,
      joinRemotePath(normalizedPath, child.filename),
    );
  }
  await sftp.rmdir(normalizedPath);
}
