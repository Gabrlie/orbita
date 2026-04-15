import 'package:flutter/material.dart';
import 'package:orbita/l10n/app_localizations.dart';

class ScriptsLibraryPage extends StatelessWidget {
  const ScriptsLibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final mockScripts = [
      {'name': 'Clear Cache', 'desc': 'Clears system cache and temp files.'},
      {'name': 'Update Packages', 'desc': 'Runs apt-get update && upgrade.'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.scriptsTitle),
      ),
      body: ListView.builder(
        itemCount: mockScripts.length,
        itemBuilder: (context, index) {
          final script = mockScripts[index];
          return ListTile(
            leading: const Icon(Icons.code),
            title: Text(script['name']!),
            subtitle: Text(script['desc']!),
            trailing: const Icon(Icons.play_arrow),
            onTap: () {},
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
