import 'package:orbita/models/remote_file_entry.dart';

String shellQuote(String value) {
  return "'${value.replaceAll("'", "'\\''")}'";
}

String archiveTargetName(String name, ArchiveFormat format) {
  return '$name${archiveExtension(format)}';
}

List<String> compressRequiredTools(ArchiveFormat format, {String? password}) {
  return switch (format) {
    ArchiveFormat.zip => ['zip'],
    ArchiveFormat.tarGz => ['tar'],
    ArchiveFormat.tarXz => ['tar'],
    ArchiveFormat.sevenZip => ['7z'],
  };
}

List<String> extractRequiredTools(String fileName) {
  final name = fileName.trim().toLowerCase();
  if (name.endsWith('.zip')) return ['unzip'];
  if (name.endsWith('.7z') || name.endsWith('.rar')) return ['7z'];
  return ['tar'];
}

List<String> previewArchiveRequiredTools(String fileName) {
  return extractRequiredTools(fileName);
}

String buildCompressCommand({
  required String parentPath,
  required String sourceName,
  required String targetName,
  required ArchiveFormat format,
  String? password,
}) {
  final parent = shellQuote(normalizeRemotePath(parentPath));
  final source = shellQuote(sourceName);
  final target = shellQuote(targetName);
  final cleanPassword = password?.trim();
  return switch (format) {
    ArchiveFormat.zip =>
      cleanPassword == null || cleanPassword.isEmpty
          ? 'cd $parent && zip -r -- $target $source'
          : 'cd $parent && zip -r -P ${shellQuote(cleanPassword)} -- $target $source',
    ArchiveFormat.tarGz => 'cd $parent && tar -czf $target -- $source',
    ArchiveFormat.tarXz => 'cd $parent && tar -cJf $target -- $source',
    ArchiveFormat.sevenZip => 'cd $parent && 7z a -y $target $source',
  };
}

String buildExtractCommand({
  required String archivePath,
  required String targetDirectory,
  String? password,
}) {
  final archive = shellQuote(normalizeRemotePath(archivePath));
  final target = shellQuote(normalizeRemotePath(targetDirectory));
  final name = archivePath.trim().toLowerCase();
  final cleanPassword = password?.trim();

  if (name.endsWith('.zip')) {
    final passwordArg = cleanPassword == null || cleanPassword.isEmpty
        ? ''
        : ' -P ${shellQuote(cleanPassword)}';
    return 'unzip$passwordArg -o $archive -d $target';
  }
  if (name.endsWith('.7z') || name.endsWith('.rar')) {
    final passwordArg = cleanPassword == null || cleanPassword.isEmpty
        ? ''
        : ' -p${shellQuote(cleanPassword)}';
    return '7z x -y$passwordArg -o$target $archive';
  }
  if (name.endsWith('.tar.gz') || name.endsWith('.tgz')) {
    return 'tar -xzf $archive -C $target';
  }
  if (name.endsWith('.tar.xz') || name.endsWith('.txz')) {
    return 'tar -xJf $archive -C $target';
  }
  if (name.endsWith('.tar.bz2') || name.endsWith('.tbz2')) {
    return 'tar -xjf $archive -C $target';
  }
  return 'tar -xf $archive -C $target';
}

String buildArchivePreviewCommand({required String archivePath}) {
  final archive = shellQuote(normalizeRemotePath(archivePath));
  final name = archivePath.trim().toLowerCase();
  if (name.endsWith('.zip')) return 'unzip -l $archive';
  if (name.endsWith('.7z') || name.endsWith('.rar')) return '7z l $archive';
  if (name.endsWith('.tar.gz') || name.endsWith('.tgz')) {
    return 'tar -tzf $archive';
  }
  if (name.endsWith('.tar.xz') || name.endsWith('.txz')) {
    return 'tar -tJf $archive';
  }
  if (name.endsWith('.tar.bz2') || name.endsWith('.tbz2')) {
    return 'tar -tjf $archive';
  }
  return 'tar -tf $archive';
}

String buildInstallToolsCommand(List<String> tools) {
  final names = tools.map(_packageNameForTool).toSet().join(' ');
  final packages = names;
  return '''
if [ "\$(id -u)" = "0" ]; then SUDO=""; else SUDO="sudo"; fi
if command -v apt-get >/dev/null 2>&1; then \$SUDO apt-get update && \$SUDO apt-get install -y $packages
elif command -v dnf >/dev/null 2>&1; then \$SUDO dnf install -y $packages
elif command -v yum >/dev/null 2>&1; then \$SUDO yum install -y $packages
elif command -v pacman >/dev/null 2>&1; then \$SUDO pacman -Sy --noconfirm $packages
elif command -v apk >/dev/null 2>&1; then \$SUDO apk add $packages
elif command -v zypper >/dev/null 2>&1; then \$SUDO zypper --non-interactive install $packages
else printf '__ORBITA_NO_PACKAGE_MANAGER__'; exit 127
fi
''';
}

String _packageNameForTool(String tool) {
  return switch (tool) {
    '7z' => 'p7zip-full',
    'sha256sum' => 'coreutils',
    _ => tool,
  };
}
