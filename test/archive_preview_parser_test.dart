import 'package:flutter_test/flutter_test.dart';
import 'package:orbita/pages/server/files/archive_preview_page.dart';

void main() {
  test('filters unzip headers and keeps real paths', () {
    const output = '''
Archive:  app.zip
  Length      Date    Time    Name
---------  ---------- -----   ----
        0  2026-05-13 10:00   app/
       12  2026-05-13 10:01   app/config.yaml
---------                     -------
       12                     1 file
''';

    final paths = parseArchivePreviewPaths(output);

    expect(paths, contains('app'));
    expect(paths, contains('app/config.yaml'));
    expect(paths, isNot(contains('Length      Date    Time    Name')));
  });

  test('normalizes tar directory entries without empty children', () {
    final entries = archivePreviewEntriesForPath(const [
      'app/',
      'app/bin/',
      'app/bin/run.sh',
    ], '/app');

    expect(entries.map((entry) => entry.name), ['bin']);
    expect(entries.single.isDirectory, isTrue);
  });

  test('filters 7z headers and summaries', () {
    const output = '''
Path = app.7z
Physical Size = 1024

   Date      Time    Attr         Size   Compressed  Name
------------------- ----- ------------ ------------  ------------------------
2026-05-13 10:00:00 D....            0            0  app
2026-05-13 10:01:00 ....A           12           12  app/readme.md
------------------- ----- ------------ ------------  ------------------------
1 files, 12 bytes
''';

    final paths = parseArchivePreviewPaths(output);

    expect(paths, contains('app/readme.md'));
    expect(paths.any((path) => path.startsWith('Date')), isFalse);
    expect(paths.any((path) => path.startsWith('1 files')), isFalse);
  });
}
