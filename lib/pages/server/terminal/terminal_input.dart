part of 'terminal_page.dart';

extension _TerminalInput on _TerminalPageState {
  void _writeToShell(String data) {
    if (_extraKeyController.hasModifiers) {
      final output = _extraKeyController.consumeText(data);
      _shell?.write(utf8.encode(_modifiedText(output)));
      _refreshInputState();
      return;
    }
    _shell?.write(utf8.encode(data));
  }

  String _modifiedText(TerminalExtraKeyOutput output) {
    var text = output.text ?? '';
    if (text.isEmpty) return text;
    if (output.ctrl) {
      final code = text.codeUnitAt(0);
      final lower = code >= 65 && code <= 90 ? code + 32 : code;
      text = String.fromCharCode(lower & 0x1f) + text.substring(1);
    }
    if (output.alt) {
      text = '\x1b$text';
    }
    return text;
  }

  void _resizeShell(int columns, int rows, int pixelWidth, int pixelHeight) {
    _shell?.resizeTerminal(columns, rows, pixelWidth, pixelHeight);
  }

  void _handleExtraKeyOutput(TerminalExtraKeyOutput output) {
    if (output.text != null) {
      final text = output.text!;
      if (text.length == 1 && (output.ctrl || output.alt)) {
        _terminal.charInput(
          text.codeUnitAt(0),
          ctrl: output.ctrl,
          alt: output.alt,
        );
      } else {
        _terminal.textInput(text);
      }
    } else if (output.key != null) {
      _terminal.keyInput(
        mapSemanticKey(output.key!),
        ctrl: output.ctrl,
        alt: output.alt,
      );
    }

    _refreshInputState();
  }

  void _handleExtraKey(TerminalExtraKey key) {
    _extraKeyController.press(key);
    _refreshInputState();
  }
}
