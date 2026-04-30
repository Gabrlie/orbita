import 'package:flutter/foundation.dart';
import 'package:orbita/pages/server/terminal/terminal_extra_key_controller.dart';
import 'package:xterm/xterm.dart';

TerminalKey mapSemanticKey(TerminalSemanticKey key) {
  return switch (key) {
    TerminalSemanticKey.escape => TerminalKey.escape,
    TerminalSemanticKey.home => TerminalKey.home,
    TerminalSemanticKey.arrowUp => TerminalKey.arrowUp,
    TerminalSemanticKey.end => TerminalKey.end,
    TerminalSemanticKey.pageUp => TerminalKey.pageUp,
    TerminalSemanticKey.tab => TerminalKey.tab,
    TerminalSemanticKey.arrowLeft => TerminalKey.arrowLeft,
    TerminalSemanticKey.arrowDown => TerminalKey.arrowDown,
    TerminalSemanticKey.arrowRight => TerminalKey.arrowRight,
    TerminalSemanticKey.pageDown => TerminalKey.pageDown,
  };
}

bool isTouchPlatform() {
  return switch (defaultTargetPlatform) {
    TargetPlatform.android ||
    TargetPlatform.iOS ||
    TargetPlatform.fuchsia => true,
    TargetPlatform.linux ||
    TargetPlatform.macOS ||
    TargetPlatform.windows => false,
  };
}

TerminalTargetPlatform terminalPlatform() {
  return switch (defaultTargetPlatform) {
    TargetPlatform.android => TerminalTargetPlatform.android,
    TargetPlatform.iOS => TerminalTargetPlatform.ios,
    TargetPlatform.fuchsia => TerminalTargetPlatform.fuchsia,
    TargetPlatform.linux => TerminalTargetPlatform.linux,
    TargetPlatform.macOS => TerminalTargetPlatform.macos,
    TargetPlatform.windows => TerminalTargetPlatform.windows,
  };
}
