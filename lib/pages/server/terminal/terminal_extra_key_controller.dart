enum TerminalExtraKey {
  escape,
  slash,
  minus,
  home,
  arrowUp,
  end,
  pageUp,
  tab,
  ctrl,
  alt,
  arrowLeft,
  arrowDown,
  arrowRight,
  pageDown,
}

enum TerminalSemanticKey {
  escape,
  home,
  arrowUp,
  end,
  pageUp,
  tab,
  arrowLeft,
  arrowDown,
  arrowRight,
  pageDown,
}

class TerminalExtraKeyOutput {
  final String? text;
  final TerminalSemanticKey? key;
  final bool ctrl;
  final bool alt;

  const TerminalExtraKeyOutput.text(
    this.text, {
    this.ctrl = false,
    this.alt = false,
  }) : key = null;

  const TerminalExtraKeyOutput.key(
    this.key, {
    this.ctrl = false,
    this.alt = false,
  }) : text = null;

  @override
  bool operator ==(Object other) {
    return other is TerminalExtraKeyOutput &&
        other.text == text &&
        other.key == key &&
        other.ctrl == ctrl &&
        other.alt == alt;
  }

  @override
  int get hashCode => Object.hash(text, key, ctrl, alt);

  @override
  String toString() {
    if (text != null) {
      return 'TerminalExtraKeyOutput.text($text, ctrl: $ctrl, alt: $alt)';
    }
    return 'TerminalExtraKeyOutput.key($key, ctrl: $ctrl, alt: $alt)';
  }
}

class TerminalExtraKeyController {
  final void Function(TerminalExtraKeyOutput output) _send;

  bool ctrlEnabled = false;
  bool altEnabled = false;

  TerminalExtraKeyController(this._send);

  void press(TerminalExtraKey key) {
    switch (key) {
      case TerminalExtraKey.ctrl:
        ctrlEnabled = !ctrlEnabled;
      case TerminalExtraKey.alt:
        altEnabled = !altEnabled;
      case TerminalExtraKey.slash:
        _sendText('/');
      case TerminalExtraKey.minus:
        _sendText('-');
      case TerminalExtraKey.escape:
        _sendKey(TerminalSemanticKey.escape);
      case TerminalExtraKey.home:
        _sendKey(TerminalSemanticKey.home);
      case TerminalExtraKey.arrowUp:
        _sendKey(TerminalSemanticKey.arrowUp);
      case TerminalExtraKey.end:
        _sendKey(TerminalSemanticKey.end);
      case TerminalExtraKey.pageUp:
        _sendKey(TerminalSemanticKey.pageUp);
      case TerminalExtraKey.tab:
        _sendKey(TerminalSemanticKey.tab);
      case TerminalExtraKey.arrowLeft:
        _sendKey(TerminalSemanticKey.arrowLeft);
      case TerminalExtraKey.arrowDown:
        _sendKey(TerminalSemanticKey.arrowDown);
      case TerminalExtraKey.arrowRight:
        _sendKey(TerminalSemanticKey.arrowRight);
      case TerminalExtraKey.pageDown:
        _sendKey(TerminalSemanticKey.pageDown);
    }
  }

  void _sendText(String text) {
    _send(
      TerminalExtraKeyOutput.text(text, ctrl: ctrlEnabled, alt: altEnabled),
    );
    _resetModifiers();
  }

  void _sendKey(TerminalSemanticKey key) {
    _send(TerminalExtraKeyOutput.key(key, ctrl: ctrlEnabled, alt: altEnabled));
    _resetModifiers();
  }

  void _resetModifiers() {
    ctrlEnabled = false;
    altEnabled = false;
  }
}
