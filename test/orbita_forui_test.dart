import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbita/widgets/orbita_forui.dart';

void main() {
  testWidgets('bottom sheet surface paints an opaque app surface', (
    tester,
  ) async {
    const surface = Color(0xFFFAFAFA);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
          ).copyWith(surface: surface),
        ),
        home: const Scaffold(
          body: OrbitaBottomSheetSurface(
            child: SizedBox(width: 120, height: 80),
          ),
        ),
      ),
    );

    final coloredBox = tester.widget<ColoredBox>(
      find.descendant(
        of: find.byType(OrbitaBottomSheetSurface),
        matching: find.byType(ColoredBox),
      ),
    );

    expect(coloredBox.color, surface);
  });
}
