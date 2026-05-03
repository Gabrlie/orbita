import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/pages/server/files/file_name_dialog.dart';

void main() {
  testWidgets('file name dialog can be cancelled without framework errors', (
    tester,
  ) async {
    String? result = 'pending';

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () async {
                result = await showFileNameDialog(
                  context,
                  title: 'Rename',
                  label: 'Name',
                  initialValue: 'old.txt',
                );
              },
              child: const Text('Open'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(result, isNull);
    expect(tester.takeException(), isNull);
  });
}
