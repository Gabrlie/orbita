import 'package:flutter/material.dart';
import 'package:orbita/l10n/app_localizations.dart';

class ScriptsPage extends StatelessWidget {
  const ScriptsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(AppLocalizations.of(context)!.scriptsDev),
    );
  }
}
