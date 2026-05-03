import 'package:flutter_test/flutter_test.dart';
import 'package:orbita/models/remote_file_entry.dart';
import 'package:orbita/services/remote_file_command_builder.dart';

void main() {
  test('builds compress commands for zip and tar formats', () {
    expect(
      buildCompressCommand(
        parentPath: '/var/www',
        sourceName: 'site',
        targetName: 'site.zip',
        format: ArchiveFormat.zip,
      ),
      "cd '/var/www' && zip -r -- 'site.zip' 'site'",
    );

    expect(
      buildCompressCommand(
        parentPath: '/var/www',
        sourceName: 'site',
        targetName: 'site.tar.gz',
        format: ArchiveFormat.tarGz,
      ),
      "cd '/var/www' && tar -czf 'site.tar.gz' -- 'site'",
    );
  });

  test('builds password zip and extraction commands', () {
    expect(
      buildCompressCommand(
        parentPath: '/tmp',
        sourceName: 'a b',
        targetName: 'a b.zip',
        format: ArchiveFormat.zip,
        password: 's3cret',
      ),
      "cd '/tmp' && zip -r -P 's3cret' -- 'a b.zip' 'a b'",
    );

    expect(
      buildExtractCommand(
        archivePath: '/tmp/a.zip',
        targetDirectory: '/tmp/out',
        password: 's3cret',
      ),
      "unzip -P 's3cret' -o '/tmp/a.zip' -d '/tmp/out'",
    );
  });

  test('selects required archive tools', () {
    expect(compressRequiredTools(ArchiveFormat.zip), ['zip']);
    expect(extractRequiredTools('a.zip'), ['unzip']);
    expect(extractRequiredTools('a.7z'), ['7z']);
    expect(extractRequiredTools('a.tar.xz'), ['tar']);
    expect(previewArchiveRequiredTools('a.rar'), ['7z']);
  });

  test('builds archive preview commands', () {
    expect(
      buildArchivePreviewCommand(archivePath: '/tmp/site.zip'),
      "unzip -l '/tmp/site.zip'",
    );
    expect(
      buildArchivePreviewCommand(archivePath: '/tmp/site.tar.gz'),
      "tar -tzf '/tmp/site.tar.gz'",
    );
    expect(
      buildArchivePreviewCommand(archivePath: '/tmp/site.7z'),
      "7z l '/tmp/site.7z'",
    );
  });
}
