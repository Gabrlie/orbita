import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/models/ssh_key.dart';
import 'package:orbita/providers/key_provider.dart';
import 'package:orbita/widgets/common.dart';

class KeyListPage extends ConsumerWidget {
  const KeyListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final keysAsync = ref.watch(keyListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.keyListTitle)),
      body: keysAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (keys) => keys.isEmpty
            ? EmptyState(
                icon: Icons.key_outlined,
                title: l10n.noKeys,
                subtitle: l10n.noKeysSubtitle,
              )
            : ListView.builder(
                itemCount: keys.length,
                itemBuilder: (context, index) {
                  final k = keys[index];
                  return ListTile(
                    leading: Icon(
                      k.keyType == SshKeyType.rsa
                          ? Icons.security_outlined
                          : Icons.enhanced_encryption_outlined,
                      color: theme.colorScheme.primary,
                    ),
                    title: Text(k.name),
                    subtitle: Text(
                      '${k.keyType.name.toUpperCase()} · ${_formatDate(k.createdAt)}',
                      style: theme.textTheme.bodySmall,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (k.publicKey != null)
                          IconButton(
                            icon: const Icon(Icons.copy_outlined, size: 20),
                            tooltip: l10n.keyPublic,
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: k.publicKey!),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.keyCopied)),
                              );
                            },
                          ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                    onTap: () => context.go('/settings/keys/${k.id}/edit'),
                    onLongPress: () => _confirmDelete(context, ref, k),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOptions(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddOptions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.file_download_outlined),
              title: Text(l10n.importKey),
              onTap: () {
                Navigator.pop(ctx);
                context.go('/settings/keys/import');
              },
            ),
            ListTile(
              leading: const Icon(Icons.auto_fix_high_outlined),
              title: Text(l10n.generateKey),
              onTap: () {
                Navigator.pop(ctx);
                context.go('/settings/keys/generate');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, SshKey key) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.deleteKeyTitle,
      content: l10n.deleteKeyContent(key.name),
      confirmLabel: l10n.commonDelete,
      destructive: true,
    );
    if (confirmed) {
      ref.read(keyListProvider.notifier).deleteKey(key.id);
    }
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}
