enum RemoteFileKind { parent, directory, file, image, archive, symlink, other }

enum ArchiveFormat { zip, tarGz, tarXz, sevenZip }

class RemoteFileEntry {
  final String name;
  final String path;
  final int size;
  final DateTime? modifiedAt;
  final int? mode;
  final bool isDirectory;
  final bool isSymlink;
  final bool isParentLink;

  const RemoteFileEntry({
    required this.name,
    required this.path,
    this.size = 0,
    this.modifiedAt,
    this.mode,
    this.isDirectory = false,
    this.isSymlink = false,
    this.isParentLink = false,
  });

  RemoteFileKind get kind {
    if (isParentLink) return RemoteFileKind.parent;
    if (isDirectory) return RemoteFileKind.directory;
    if (isSymlink) return RemoteFileKind.symlink;
    if (isSupportedImageFileName(name)) return RemoteFileKind.image;
    if (isSupportedArchiveFileName(name)) return RemoteFileKind.archive;
    if (isLikelyTextFileName(name)) return RemoteFileKind.file;
    return RemoteFileKind.other;
  }
}

const maxEditableFileBytes = 1024 * 1024;

String normalizeRemotePath(String path) {
  final trimmed = path.trim();
  if (trimmed.isEmpty || trimmed == '~') return '/';
  final hasLeadingSlash = trimmed.startsWith('/');
  final segments = <String>[];
  for (final segment in trimmed.split('/')) {
    if (segment.isEmpty || segment == '.') continue;
    if (segment == '..') {
      if (segments.isNotEmpty) segments.removeLast();
      continue;
    }
    segments.add(segment);
  }
  final normalized = segments.join('/');
  if (normalized.isEmpty) return '/';
  return hasLeadingSlash ? '/$normalized' : normalized;
}

String joinRemotePath(String parent, String name) {
  final cleanName = validateRemoteEntryName(name);
  final normalizedParent = normalizeRemotePath(parent);
  return normalizedParent == '/'
      ? '/$cleanName'
      : '$normalizedParent/$cleanName';
}

String parentRemotePath(String path) {
  final normalized = normalizeRemotePath(path);
  if (normalized == '/') return '/';
  final index = normalized.lastIndexOf('/');
  if (index <= 0) return '/';
  return normalized.substring(0, index);
}

String validateRemoteEntryName(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) {
    throw ArgumentError('Name cannot be empty');
  }
  if (trimmed == '.' || trimmed == '..') {
    throw ArgumentError('Name cannot be . or ..');
  }
  if (trimmed.contains('/')) {
    throw ArgumentError('Name cannot contain /');
  }
  return trimmed;
}

RemoteFileEntry? createParentRemoteEntry(String path) {
  final normalized = normalizeRemotePath(path);
  if (normalized == '/') return null;
  return RemoteFileEntry(
    name: '..',
    path: parentRemotePath(normalized),
    isDirectory: true,
    isParentLink: true,
  );
}

String remoteFileExtension(String fileName) {
  final normalized = fileName.trim().toLowerCase();
  final index = normalized.lastIndexOf('.');
  if (index <= 0 || index == normalized.length - 1) return '';
  return normalized.substring(index + 1);
}

bool isSupportedImageFileName(String fileName) {
  const extensions = {
    'png',
    'jpg',
    'jpeg',
    'gif',
    'webp',
    'bmp',
    'ico',
    'svg',
    'avif',
  };
  return extensions.contains(remoteFileExtension(fileName));
}

bool isSupportedArchiveFileName(String fileName) {
  final normalized = fileName.trim().toLowerCase();
  return normalized.endsWith('.tar.gz') ||
      normalized.endsWith('.tgz') ||
      normalized.endsWith('.tar.xz') ||
      normalized.endsWith('.txz') ||
      normalized.endsWith('.tar.bz2') ||
      normalized.endsWith('.tbz2') ||
      normalized.endsWith('.tar') ||
      normalized.endsWith('.zip') ||
      normalized.endsWith('.7z') ||
      normalized.endsWith('.rar');
}

bool isLikelyTextFileName(String fileName) {
  final normalized = fileName.trim().toLowerCase();
  const names = {
    'dockerfile',
    'makefile',
    '.gitignore',
    '.gitattributes',
    '.env',
  };
  const extensions = {
    'txt',
    'log',
    'conf',
    'ini',
    'json',
    'yaml',
    'yml',
    'toml',
    'xml',
    'md',
    'sh',
    'bash',
    'zsh',
    'fish',
    'py',
    'js',
    'ts',
    'css',
    'html',
    'sql',
    'dart',
    'go',
    'rs',
    'java',
    'kt',
    'php',
    'rb',
  };
  return names.contains(normalized) ||
      extensions.contains(remoteFileExtension(normalized));
}

List<RemotePathBreadcrumb> remotePathBreadcrumbs(String path) {
  final normalized = normalizeRemotePath(path);
  if (normalized == '/') {
    return const [RemotePathBreadcrumb(label: '/', path: '/')];
  }

  final breadcrumbs = <RemotePathBreadcrumb>[
    const RemotePathBreadcrumb(label: '/', path: '/'),
  ];
  var current = '';
  for (final segment in normalized.substring(1).split('/')) {
    current = '$current/$segment';
    breadcrumbs.add(RemotePathBreadcrumb(label: segment, path: current));
  }
  return breadcrumbs;
}

bool isExtractableArchiveFileName(String fileName) {
  return isSupportedArchiveFileName(fileName);
}

String archiveExtension(ArchiveFormat format) {
  return switch (format) {
    ArchiveFormat.zip => '.zip',
    ArchiveFormat.tarGz => '.tar.gz',
    ArchiveFormat.tarXz => '.tar.xz',
    ArchiveFormat.sevenZip => '.7z',
  };
}

String archiveFormatLabel(ArchiveFormat format) {
  return switch (format) {
    ArchiveFormat.zip => 'zip',
    ArchiveFormat.tarGz => 'tar.gz',
    ArchiveFormat.tarXz => 'tar.xz',
    ArchiveFormat.sevenZip => '7z',
  };
}

String duplicateRemoteEntryName(String name, int index) {
  if (index < 1) throw ArgumentError('Duplicate index must be positive');
  final parts = _splitDuplicateName(name);
  return '${parts.stem}($index)${parts.extension}';
}

({String stem, String extension}) _splitDuplicateName(String name) {
  final trimmed = validateRemoteEntryName(name);
  final lower = trimmed.toLowerCase();
  const compoundExtensions = [
    '.tar.gz',
    '.tar.xz',
    '.tar.bz2',
    '.tgz',
    '.txz',
    '.tbz2',
  ];
  for (final extension in compoundExtensions) {
    if (lower.endsWith(extension) && trimmed.length > extension.length) {
      return (
        stem: _stripDuplicateSuffix(
          trimmed.substring(0, trimmed.length - extension.length),
        ),
        extension: trimmed.substring(trimmed.length - extension.length),
      );
    }
  }

  final dot = trimmed.lastIndexOf('.');
  if (dot <= 0 || dot == trimmed.length - 1) {
    return (stem: _stripDuplicateSuffix(trimmed), extension: '');
  }
  return (
    stem: _stripDuplicateSuffix(trimmed.substring(0, dot)),
    extension: trimmed.substring(dot),
  );
}

String _stripDuplicateSuffix(String stem) {
  return stem.replaceFirst(RegExp(r'\(\d+\)$'), '');
}

class RemotePathBreadcrumb {
  final String label;
  final String path;

  const RemotePathBreadcrumb({required this.label, required this.path});
}
