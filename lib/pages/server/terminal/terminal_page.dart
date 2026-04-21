import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/widgets/common.dart';

class TerminalPage extends StatelessWidget {
  const TerminalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return EmptyState(icon: Ionicons.terminal_outline, title: l10n.terminalDev);
  }
}
