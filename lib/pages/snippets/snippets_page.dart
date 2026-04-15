import 'package:flutter/material.dart';
import 'package:orbita/l10n/app_localizations.dart';

class SnippetsPage extends StatelessWidget {
  const SnippetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    final mockSnippets = [
      {'name': 'Show Disk Usage', 'cmd': 'df -h'},
      {'name': 'Show Memory', 'cmd': 'free -m'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.snippetsTitle),
      ),
      body: ListView.builder(
        itemCount: mockSnippets.length,
        itemBuilder: (context, index) {
          final snippet = mockSnippets[index];
          return ListTile(
            leading: const Icon(Icons.data_object),
            title: Text(snippet['name']!),
            subtitle: Text(
              snippet['cmd']!, 
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: 'monospace',
                color: theme.colorScheme.primary,
              ),
            ),
            trailing: const Icon(Icons.copy),
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
