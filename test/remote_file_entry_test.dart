import 'package:flutter_test/flutter_test.dart';
import 'package:orbita/models/remote_file_entry.dart';

void main() {
  test('normalizes remote paths without escaping above root', () {
    expect(normalizeRemotePath(''), '/');
    expect(normalizeRemotePath('/var//log/../tmp'), '/var/tmp');
    expect(normalizeRemotePath('/../../etc'), '/etc');
    expect(parentRemotePath('/var/log/syslog'), '/var/log');
    expect(parentRemotePath('/var'), '/');
  });

  test('joins and validates remote entry names', () {
    expect(joinRemotePath('/', 'nginx.conf'), '/nginx.conf');
    expect(joinRemotePath('/etc', 'nginx.conf'), '/etc/nginx.conf');
    expect(() => joinRemotePath('/etc', '../passwd'), throwsArgumentError);
    expect(() => joinRemotePath('/etc', 'a/b'), throwsArgumentError);
  });

  test('classifies common file names', () {
    expect(isLikelyTextFileName('Dockerfile'), isTrue);
    expect(isLikelyTextFileName('config.yaml'), isTrue);
    expect(isSupportedImageFileName('logo.webp'), isTrue);
    expect(isSupportedArchiveFileName('backup.tar.gz'), isTrue);
    expect(isSupportedArchiveFileName('backup.7z'), isTrue);
    expect(isExtractableArchiveFileName('backup.rar'), isTrue);
  });

  test('builds clickable remote path breadcrumbs', () {
    final root = remotePathBreadcrumbs('/');
    expect(root.map((item) => item.path), ['/']);

    final nested = remotePathBreadcrumbs('/home/app/www');
    expect(nested.map((item) => item.label), ['/', 'home', 'app', 'www']);
    expect(nested.map((item) => item.path), [
      '/',
      '/home',
      '/home/app',
      '/home/app/www',
    ]);
  });

  test('builds duplicate names without stacking suffixes', () {
    expect(duplicateRemoteEntryName('app.log', 1), 'app(1).log');
    expect(duplicateRemoteEntryName('app(1).log', 2), 'app(2).log');
    expect(duplicateRemoteEntryName('backup.tar.gz', 3), 'backup(3).tar.gz');
    expect(duplicateRemoteEntryName('.env', 4), '.env(4)');
  });
}
