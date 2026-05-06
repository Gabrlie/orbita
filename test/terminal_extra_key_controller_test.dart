import 'package:flutter_test/flutter_test.dart';
import 'package:orbita/pages/server/terminal/terminal_extra_key_controller.dart';

void main() {
  test('sends plain text and semantic keys without modifiers', () {
    final sent = <TerminalExtraKeyOutput>[];
    final controller = TerminalExtraKeyController(sent.add);

    controller.press(TerminalExtraKey.slash);
    controller.press(TerminalExtraKey.arrowUp);

    expect(sent, [
      const TerminalExtraKeyOutput.text('/'),
      const TerminalExtraKeyOutput.key(TerminalSemanticKey.arrowUp),
    ]);
  });

  test('ctrl and alt apply to the next non-modifier key then reset', () {
    final sent = <TerminalExtraKeyOutput>[];
    final controller = TerminalExtraKeyController(sent.add);

    controller.press(TerminalExtraKey.ctrl);
    controller.press(TerminalExtraKey.alt);
    controller.press(TerminalExtraKey.tab);
    controller.press(TerminalExtraKey.minus);

    expect(sent, [
      const TerminalExtraKeyOutput.key(
        TerminalSemanticKey.tab,
        ctrl: true,
        alt: true,
      ),
      const TerminalExtraKeyOutput.text('-'),
    ]);
    expect(controller.ctrlEnabled, isFalse);
    expect(controller.altEnabled, isFalse);
  });

  test('ctrl and alt can be consumed by keyboard text input', () {
    final controller = TerminalExtraKeyController((_) {});

    controller.press(TerminalExtraKey.ctrl);
    controller.press(TerminalExtraKey.alt);
    final output = controller.consumeText('c');

    expect(output, const TerminalExtraKeyOutput.text('c', ctrl: true, alt: true));
    expect(controller.ctrlEnabled, isFalse);
    expect(controller.altEnabled, isFalse);
  });
}
